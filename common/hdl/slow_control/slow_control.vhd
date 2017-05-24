------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    14:19 2016-10-05
-- Module Name:    slow_control
-- Description:    This module is mainly responsible for communication with Optohybrid SCA and reading/writing GBTx registers
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.gem_pkg.all;
use work.sca_pkg.all;
use work.ttc_pkg.all;
use work.ipbus.all;
use work.registers.all;

entity slow_control is
    generic(
        g_NUM_OF_OHs    : integer := 1;
        g_USE_GBT       : boolean := true;  -- if this is false then SCA module won't be instantiated
        g_DEBUG         : boolean := false -- if this is set to true, some chipscope cores will be inserted
    );
    port(
        -- reset
        reset_i                 : in  std_logic;

        -- TTC
        ttc_clk_i               : in  t_ttc_clks;
        ttc_cmds_i              : in  t_ttc_cmds;
        
        -- SCA elinks
        gbt_rx_ready_i          : in  std_logic_vector(g_NUM_OF_OHs - 1 downto 0); 
        gbt_rx_sca_elinks_i     : in  t_std2_array(g_NUM_OF_OHs - 1 downto 0);
        gbt_tx_sca_elinks_o     : out t_std2_array(g_NUM_OF_OHs - 1 downto 0);
        
        -- GBTx IC elinks
        gbt_rx_ic_elinks_i      : in  t_std2_array(g_NUM_OF_OHs - 1 downto 0);
        gbt_tx_ic_elinks_o      : out t_std2_array(g_NUM_OF_OHs - 1 downto 0);
        
        -- IPbus
        ipb_reset_i            : in  std_logic;
        ipb_clk_i              : in  std_logic;
        ipb_miso_o             : out ipb_rbus;
        ipb_mosi_i             : in  ipb_wbus
        
    );
end slow_control;

architecture slow_control_arch of slow_control is

    --------------------------------- signals ---------------------------------    

    -- only handle one SCA for now, this constant defines the elink to use for that one SCA controller
    constant ELINK_IDX          : integer := 1;

    --============ SCA ============--
    
    -- general
    signal sca_reset                : std_logic;
    signal sca_ready_arr            : std_logic_vector(31 downto 0);
    signal sca_critical_error_arr   : std_logic_vector(31 downto 0);
    signal sca_ttc_hr_enable        : std_logic;
    
    -- manual commands
    signal manual_hard_reset            : std_logic;
    signal sca_user_command             : t_sca_command;
    signal sca_user_command_en          : std_logic;
    signal sca_user_command_en_mask     : std_logic_vector(31 downto 0); -- command_en signal will only be sent to the channels that are enabled in this bitmask
    signal sca_user_command_done_arr    : std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
    signal sca_user_command_done_latch  : std_logic_vector(g_NUM_OF_OHs - 1 downto 0) := (others => '0');
    signal sca_user_command_done_all    : std_logic;
    signal sca_user_reply_arr           : t_sca_reply_array(g_NUM_OF_OHs - 1 downto 0);
    
    -- core monitoring
    signal sca_not_ready_cnt_arr: t_std16_array(g_NUM_OF_OHs - 1 downto 0);
    signal sca_rx_err_cnt       : std_logic_vector(15 downto 0);
    signal sca_seq_num_err_cnt  : std_logic_vector(15 downto 0);
    signal sca_crc_err_cnt      : std_logic_vector(15 downto 0);
    signal sca_tr_timeout_cnt   : std_logic_vector(15 downto 0);
    signal sca_tr_fail_cnt      : std_logic_vector(15 downto 0);
    signal sca_tr_done_cnt      : std_logic_vector(31 downto 0);
    signal sca_last_sca_error   : std_logic_vector(6 downto 0);
    
    -- adc
    signal sca_adc_monitor_off_arr  : std_logic_vector(31 downto 0);
    signal sca_adc_readings_arr     : t_sca_adc_value_arr_arr(g_NUM_OF_OHs - 1 downto 0);
    
    -- jtag
    signal jtag_enabled_mask        : std_logic_vector(31 downto 0);
    signal jtag_cmd_length          : std_logic_vector(6 downto 0);
    signal jtag_tdo                 : std_logic_vector(31 downto 0);
    signal jtag_tms                 : std_logic_vector(31 downto 0);
    signal jtag_tdi_arr             : t_std32_array(g_NUM_OF_OHs - 1 downto 0);
    signal jtag_shift_tdo_en        : std_logic; 
    signal jtag_shift_tms_en        : std_logic;
    signal jtag_shift_tdi_en_arr    : std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
    signal jtag_shift_done_arr      : std_logic_vector(g_NUM_OF_OHs - 1 downto 0); 
    signal jtag_shift_done_latch    : std_logic_vector(g_NUM_OF_OHs - 1 downto 0) := (others => '0'); 
    signal jtag_shift_done_all      : std_logic; 
    signal jtag_shift_msb_first     : std_logic; -- tell SCA to shift out MSB first instead of the default LSB first
    signal jtag_exec_on_every_tdo   : std_logic; -- EXPERT ONLY: used to optimize firmware downloading, when set high the controller will execute JTAG_GO after every TDO shift (even if length is higher than 32)
    signal jtag_no_length_update    : std_logic; -- EXPERT ONLY: used to optimize firmware downloading, when set high the controller will assume that SCA already has the correct length and will not update it before each JTAG_GO
    signal jtag_shift_tdo_async     : std_logic; -- kindof expert: if this is set high then JTAG controller will assert jtag_shift_done_o immediately after TDO shift command, but if the second command is received while it's still busy it won't assert jtag_shift_done_o until the previous command is done
    
            
    -- debug
    signal sca_tx_raw_last_cmd  : std_logic_vector(95 downto 0);
    signal sca_rx_raw_last_reply: std_logic_vector(95 downto 0);
    signal sca_rx_last_calc_crc : std_logic_vector(15 downto 0);

    ------------- GBTx IC -------------

    signal ic_address           : std_logic_vector(15 downto 0);
    signal ic_write_data        : std_logic_vector(31 downto 0);
    signal ic_rw_length         : std_logic_vector(2 downto 0);
    signal ic_write_req         : std_logic;
    signal ic_write_done        : std_logic;
    signal ic_read_req          : std_logic; 
    signal ic_gbtx_i2c_addr     : std_logic_vector(3 downto 0);

    ------ Register signals begin (this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_SLOW_CONTROL_NUM_REGS - 1 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    --======== SCA controller ========--
    
    g_sca_controllers : for i in 0 to g_NUM_OF_OHs - 1 generate
        i_sca_controller : entity work.sca_controller
            port map(
                reset_i                     => reset_i or sca_reset,
                gbt_clk_40_i                => ttc_clk_i.clk_40,
                clk_80_i                    => ttc_clk_i.clk_80,
            
                gbt_rx_ready_i              => gbt_rx_ready_i(i),
                gbt_rx_sca_elink_i          => gbt_rx_sca_elinks_i(i),
                gbt_tx_sca_elink_o          => gbt_tx_sca_elinks_o(i),
            
                hard_reset_i                => manual_hard_reset or (ttc_cmds_i.hard_reset and sca_ttc_hr_enable),
            
                user_command_i              => sca_user_command,
                user_command_en_i           => sca_user_command_en and sca_user_command_en_mask(i),
                user_reply_o                => sca_user_reply_arr(i),
                user_reply_valid_o          => sca_user_command_done_arr(i),
            
                adc_monitoring_off_i        => sca_adc_monitor_off_arr(i),
                adc_readings_o              => sca_adc_readings_arr(i),
            
                jtag_enabled_i              => jtag_enabled_mask(i),
                jtag_cmd_length_i           => unsigned(jtag_cmd_length),
                jtag_tdo_i                  => jtag_tdo,
                jtag_tms_i                  => jtag_tms,
                jtag_tdi_o                  => jtag_tdi_arr(i),
                jtag_shift_tdo_en_i         => jtag_shift_tdo_en,
                jtag_shift_tms_en_i         => jtag_shift_tms_en,
                jtag_shift_tdi_en_i         => jtag_shift_tdi_en_arr(i),
                jtag_shift_done_o           => jtag_shift_done_arr(i),            
                jtag_shift_msb_first_i      => jtag_shift_msb_first,
                
                jtag_exec_on_every_tdo_i    => jtag_exec_on_every_tdo,
                jtag_no_length_update_i     => jtag_no_length_update,
                jtag_shift_tdo_async_i      => jtag_shift_tdo_async,
                                    
                ready_o                     => sca_ready_arr(i),
                critical_error_o            => sca_critical_error_arr(i),
                not_ready_cnt_o             => sca_not_ready_cnt_arr(i),
                rx_err_cnt_o                => open, --sca_rx_err_cnt,
                rx_seq_num_err_cnt_o        => open, --sca_seq_num_err_cnt,
                rx_crc_err_cnt_o            => open, --sca_crc_err_cnt,
                trans_timeout_cnt_o         => open, --sca_tr_timeout_cnt,
                trans_fail_cnt_o            => open, --sca_tr_fail_cnt,
                trans_done_cnt_o            => open, --sca_tr_done_cnt,
                last_sca_error_o            => open, --sca_last_sca_error,
                tx_raw_last_cmd_o           => open, --sca_tx_raw_last_cmd,
                rx_raw_last_reply_o         => open, --sca_rx_raw_last_reply,
                rx_last_calc_crc_o          => open  --sca_rx_last_calc_crc
            );
    end generate;

    ------------------- SCA done signal aggregation based on enabled channels -------------------
    
    -- manual command
    process(ttc_clk_i.clk_40)
    begin
        if (rising_edge(ttc_clk_i.clk_40)) then
            if (sca_user_command_en = '1') then
                sca_user_command_done_latch <= (others => '0');
            else
                sca_user_command_done_latch <= sca_user_command_done_latch or sca_user_command_done_arr;
            end if;
            
            if (sca_user_command_done_latch = sca_user_command_en_mask(g_NUM_OF_OHs - 1 downto 0)) then
                sca_user_command_done_all <= '1';
                sca_user_command_done_latch <= (others => '0');
            else
                sca_user_command_done_all <= '0';
            end if;
        end if;
    end process; 

    -- JTAG command
    process(ttc_clk_i.clk_40)
    begin
        if (rising_edge(ttc_clk_i.clk_40)) then
            if ((jtag_shift_tdo_en = '1') or (jtag_shift_tms_en = '1')) then
                jtag_shift_done_latch <= (others => '0');
            else
                jtag_shift_done_latch <= jtag_shift_done_latch or jtag_shift_done_arr;
            end if;
            
            if (jtag_shift_done_latch = jtag_enabled_mask(g_NUM_OF_OHs - 1 downto 0)) then
                jtag_shift_done_all <= '1';
                jtag_shift_done_latch <= (others => '0');
            else
                jtag_shift_done_all <= '0';
            end if;
        end if;
    end process; 

    
    --======== GBTx IC ========--
    
    i_ic_controller : entity work.gbtx_ic_controller
--        generic map(
--            g_GBTX_I2C_ADDRESS => x"1"
--        )
        port map(
            reset_i           => reset_i,
            gbt_clk_i         => ttc_clk_i.clk_40,
            gbtx_i2c_address  => ic_gbtx_i2c_addr,
            gbt_rx_ic_elink_i => gbt_rx_ic_elinks_i(ELINK_IDX),
            gbt_tx_ic_elink_o => gbt_tx_ic_elinks_o(ELINK_IDX),
            ic_rw_address_i   => ic_address,
            ic_w_data_i       => ic_write_data,
            ic_rw_length_i    => ic_rw_length,
            ic_write_req_i    => ic_write_req,
            ic_write_done_o   => ic_write_done,
            ic_read_req_i     => ic_read_req
        );
    
    --===============================================================================================
    -- this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py (do not edit) 
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_SLOW_CONTROL_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_SLOW_CONTROL_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_SLOW_CONTROL_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => ipb_clk_i,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => ttc_clk_i.clk_40,
           regs_read_arr_i        => regs_read_arr,
           regs_write_arr_o       => regs_write_arr,
           read_pulse_arr_o       => regs_read_pulse_arr,
           write_pulse_arr_o      => regs_write_pulse_arr,
           regs_read_ready_arr_i  => regs_read_ready_arr,
           regs_write_done_arr_i  => regs_write_done_arr,
           individual_addrs_arr_i => regs_addresses,
           regs_defaults_arr_i    => regs_defaults,
           writable_regs_i        => regs_writable_arr
      );

    -- Addresses
    regs_addresses(0)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0000";
    regs_addresses(1)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0001";
    regs_addresses(2)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0002";
    regs_addresses(3)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0100";
    regs_addresses(4)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0101";
    regs_addresses(5)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0102";
    regs_addresses(6)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0103";
    regs_addresses(7)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0104";
    regs_addresses(8)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0105";
    regs_addresses(9)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0106";
    regs_addresses(10)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0107";
    regs_addresses(11)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0108";
    regs_addresses(12)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"0109";
    regs_addresses(13)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"010a";
    regs_addresses(14)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"010b";
    regs_addresses(15)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"010c";
    regs_addresses(16)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"010d";
    regs_addresses(17)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1000";
    regs_addresses(18)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1001";
    regs_addresses(19)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1002";
    regs_addresses(20)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1003";
    regs_addresses(21)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1004";
    regs_addresses(22)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1005";
    regs_addresses(23)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1006";
    regs_addresses(24)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1007";
    regs_addresses(25)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1008";
    regs_addresses(26)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1009";
    regs_addresses(27)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"100a";
    regs_addresses(28)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"100b";
    regs_addresses(29)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"100c";
    regs_addresses(30)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"100d";
    regs_addresses(31)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"100e";
    regs_addresses(32)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"100f";
    regs_addresses(33)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1010";
    regs_addresses(34)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1011";
    regs_addresses(35)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1012";
    regs_addresses(36)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1013";
    regs_addresses(37)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1014";
    regs_addresses(38)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1015";
    regs_addresses(39)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1016";
    regs_addresses(40)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1017";
    regs_addresses(41)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1018";
    regs_addresses(42)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"1019";
    regs_addresses(43)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"101a";
    regs_addresses(44)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"101b";
    regs_addresses(45)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2000";
    regs_addresses(46)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2001";
    regs_addresses(47)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2002";
    regs_addresses(48)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2003";
    regs_addresses(49)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2004";
    regs_addresses(50)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2005";
    regs_addresses(51)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2006";
    regs_addresses(52)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2007";
    regs_addresses(53)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2008";
    regs_addresses(54)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2009";
    regs_addresses(55)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"200a";
    regs_addresses(56)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2010";
    regs_addresses(57)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2011";
    regs_addresses(58)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2012";
    regs_addresses(59)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2013";
    regs_addresses(60)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2014";
    regs_addresses(61)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2015";
    regs_addresses(62)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2016";
    regs_addresses(63)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2017";
    regs_addresses(64)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2018";
    regs_addresses(65)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2019";
    regs_addresses(66)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"201f";
    regs_addresses(67)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2020";
    regs_addresses(68)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2021";
    regs_addresses(69)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2022";
    regs_addresses(70)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2023";
    regs_addresses(71)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2024";
    regs_addresses(72)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2025";
    regs_addresses(73)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2026";
    regs_addresses(74)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2027";
    regs_addresses(75)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2028";
    regs_addresses(76)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"202e";
    regs_addresses(77)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"202f";
    regs_addresses(78)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2030";
    regs_addresses(79)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2031";
    regs_addresses(80)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2032";
    regs_addresses(81)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2033";
    regs_addresses(82)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2034";
    regs_addresses(83)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2035";
    regs_addresses(84)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2036";
    regs_addresses(85)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2037";
    regs_addresses(86)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"203d";
    regs_addresses(87)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"203e";
    regs_addresses(88)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"203f";
    regs_addresses(89)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2040";
    regs_addresses(90)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2041";
    regs_addresses(91)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2042";
    regs_addresses(92)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2043";
    regs_addresses(93)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2044";
    regs_addresses(94)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2045";
    regs_addresses(95)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2046";
    regs_addresses(96)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"204c";
    regs_addresses(97)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"204d";
    regs_addresses(98)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"204e";
    regs_addresses(99)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"204f";
    regs_addresses(100)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2050";
    regs_addresses(101)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2051";
    regs_addresses(102)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2052";
    regs_addresses(103)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2053";
    regs_addresses(104)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2054";
    regs_addresses(105)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2055";
    regs_addresses(106)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"205b";
    regs_addresses(107)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"205c";
    regs_addresses(108)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"205d";
    regs_addresses(109)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"205e";
    regs_addresses(110)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"205f";
    regs_addresses(111)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2060";
    regs_addresses(112)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2061";
    regs_addresses(113)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2062";
    regs_addresses(114)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2063";
    regs_addresses(115)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2064";
    regs_addresses(116)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"206a";
    regs_addresses(117)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"206b";
    regs_addresses(118)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"206c";
    regs_addresses(119)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"206d";
    regs_addresses(120)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"206e";
    regs_addresses(121)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"206f";
    regs_addresses(122)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2070";
    regs_addresses(123)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2071";
    regs_addresses(124)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2072";
    regs_addresses(125)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2073";
    regs_addresses(126)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2079";
    regs_addresses(127)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"207a";
    regs_addresses(128)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"207b";
    regs_addresses(129)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"207c";
    regs_addresses(130)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"207d";
    regs_addresses(131)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"207e";
    regs_addresses(132)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"207f";
    regs_addresses(133)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2080";
    regs_addresses(134)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2081";
    regs_addresses(135)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2082";
    regs_addresses(136)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2088";
    regs_addresses(137)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2089";
    regs_addresses(138)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"208a";
    regs_addresses(139)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"208b";
    regs_addresses(140)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"208c";
    regs_addresses(141)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"208d";
    regs_addresses(142)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"208e";
    regs_addresses(143)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"208f";
    regs_addresses(144)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2090";
    regs_addresses(145)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2091";
    regs_addresses(146)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2097";
    regs_addresses(147)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2098";
    regs_addresses(148)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2099";
    regs_addresses(149)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"209a";
    regs_addresses(150)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"209b";
    regs_addresses(151)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"209c";
    regs_addresses(152)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"209d";
    regs_addresses(153)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"209e";
    regs_addresses(154)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"209f";
    regs_addresses(155)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20a0";
    regs_addresses(156)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20a6";
    regs_addresses(157)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20a7";
    regs_addresses(158)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20a8";
    regs_addresses(159)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20a9";
    regs_addresses(160)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20aa";
    regs_addresses(161)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20ab";
    regs_addresses(162)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20ac";
    regs_addresses(163)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20ad";
    regs_addresses(164)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20ae";
    regs_addresses(165)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"20af";
    regs_addresses(166)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2500";
    regs_addresses(167)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2501";
    regs_addresses(168)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2502";
    regs_addresses(169)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2503";
    regs_addresses(170)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2504";
    regs_addresses(171)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2505";
    regs_addresses(172)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2506";
    regs_addresses(173)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2507";
    regs_addresses(174)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2508";
    regs_addresses(175)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2509";
    regs_addresses(176)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"250a";
    regs_addresses(177)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"250b";
    regs_addresses(178)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"250c";
    regs_addresses(179)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"250d";
    regs_addresses(180)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"250e";
    regs_addresses(181)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"250f";
    regs_addresses(182)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '0' & x"2510";
    regs_addresses(183)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '1' & x"0000";
    regs_addresses(184)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '1' & x"0001";
    regs_addresses(185)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '1' & x"0002";
    regs_addresses(186)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '1' & x"0003";
    regs_addresses(187)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '1' & x"0004";
    regs_addresses(188)(REG_SLOW_CONTROL_ADDRESS_MSB downto REG_SLOW_CONTROL_ADDRESS_LSB) <= '1' & x"0005";

    -- Connect read signals
    regs_read_arr(2)(REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT) <= sca_ttc_hr_enable;
    regs_read_arr(3)(REG_SLOW_CONTROL_SCA_STATUS_READY_MSB downto REG_SLOW_CONTROL_SCA_STATUS_READY_LSB) <= sca_ready_arr;
    regs_read_arr(4)(REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_MSB downto REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_LSB) <= sca_critical_error_arr;
    regs_read_arr(5)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_LSB) <= sca_not_ready_cnt_arr(0);
    regs_read_arr(6)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH1_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH1_LSB) <= sca_not_ready_cnt_arr(1);
    regs_read_arr(7)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH2_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH2_LSB) <= sca_not_ready_cnt_arr(2);
    regs_read_arr(8)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH3_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH3_LSB) <= sca_not_ready_cnt_arr(3);
    regs_read_arr(9)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH4_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH4_LSB) <= sca_not_ready_cnt_arr(4);
    regs_read_arr(10)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH5_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH5_LSB) <= sca_not_ready_cnt_arr(5);
    regs_read_arr(11)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH6_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH6_LSB) <= sca_not_ready_cnt_arr(6);
    regs_read_arr(12)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH7_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH7_LSB) <= sca_not_ready_cnt_arr(7);
    regs_read_arr(13)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH8_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH8_LSB) <= sca_not_ready_cnt_arr(8);
    regs_read_arr(14)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH9_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH9_LSB) <= sca_not_ready_cnt_arr(9);
    regs_read_arr(15)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH10_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH10_LSB) <= sca_not_ready_cnt_arr(10);
    regs_read_arr(16)(REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH11_MSB downto REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH11_LSB) <= sca_not_ready_cnt_arr(11);
    regs_read_arr(17)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB) <= sca_user_command_en_mask;
    regs_read_arr(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB) <= sca_user_command.channel;
    regs_read_arr(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB) <= sca_user_command.command;
    regs_read_arr(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB) <= sca_user_command.length;
    regs_read_arr(19)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB) <= sca_user_command.data;
    regs_read_arr(21)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(0).channel;
    regs_read_arr(21)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(0).error;
    regs_read_arr(21)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(0).length;
    regs_read_arr(22)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(0).data;
    regs_read_arr(23)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(1).channel;
    regs_read_arr(23)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(1).error;
    regs_read_arr(23)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(1).length;
    regs_read_arr(24)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(1).data;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(2).channel;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(2).error;
    regs_read_arr(25)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(2).length;
    regs_read_arr(26)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH2_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(2).data;
    regs_read_arr(27)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(3).channel;
    regs_read_arr(27)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(3).error;
    regs_read_arr(27)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(3).length;
    regs_read_arr(28)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH3_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(3).data;
    regs_read_arr(29)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(4).channel;
    regs_read_arr(29)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(4).error;
    regs_read_arr(29)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(4).length;
    regs_read_arr(30)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH4_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(4).data;
    regs_read_arr(31)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(5).channel;
    regs_read_arr(31)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(5).error;
    regs_read_arr(31)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(5).length;
    regs_read_arr(32)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH5_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(5).data;
    regs_read_arr(33)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(6).channel;
    regs_read_arr(33)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(6).error;
    regs_read_arr(33)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(6).length;
    regs_read_arr(34)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH6_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(6).data;
    regs_read_arr(35)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(7).channel;
    regs_read_arr(35)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(7).error;
    regs_read_arr(35)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(7).length;
    regs_read_arr(36)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH7_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(7).data;
    regs_read_arr(37)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(8).channel;
    regs_read_arr(37)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(8).error;
    regs_read_arr(37)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(8).length;
    regs_read_arr(38)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH8_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(8).data;
    regs_read_arr(39)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(9).channel;
    regs_read_arr(39)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(9).error;
    regs_read_arr(39)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(9).length;
    regs_read_arr(40)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH9_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(9).data;
    regs_read_arr(41)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(10).channel;
    regs_read_arr(41)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(10).error;
    regs_read_arr(41)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(10).length;
    regs_read_arr(42)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH10_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(10).data;
    regs_read_arr(43)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_CHANNEL_LSB) <= sca_user_reply_arr(11).channel;
    regs_read_arr(43)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_ERROR_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_ERROR_LSB) <= sca_user_reply_arr(11).error;
    regs_read_arr(43)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_LENGTH_LSB) <= sca_user_reply_arr(11).length;
    regs_read_arr(44)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH11_SCA_RPY_DATA_LSB) <= sca_user_reply_arr(11).data;
    regs_read_arr(45)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB) <= sca_adc_monitor_off_arr;
    regs_read_arr(46)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_LSB) <= sca_adc_readings_arr(0)(0);
    regs_read_arr(46)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_LSB) <= sca_adc_readings_arr(0)(1);
    regs_read_arr(47)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_LSB) <= sca_adc_readings_arr(0)(2);
    regs_read_arr(47)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_LSB) <= sca_adc_readings_arr(0)(3);
    regs_read_arr(48)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_LSB) <= sca_adc_readings_arr(0)(4);
    regs_read_arr(48)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_LSB) <= sca_adc_readings_arr(0)(5);
    regs_read_arr(49)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_LSB) <= sca_adc_readings_arr(0)(6);
    regs_read_arr(49)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_LSB) <= sca_adc_readings_arr(0)(7);
    regs_read_arr(50)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(0)(8);
    regs_read_arr(50)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(0)(9);
    regs_read_arr(51)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_LSB) <= sca_adc_readings_arr(0)(10);
    regs_read_arr(51)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(0)(11);
    regs_read_arr(52)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(0)(12);
    regs_read_arr(52)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(0)(13);
    regs_read_arr(53)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(0)(14);
    regs_read_arr(53)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(0)(15);
    regs_read_arr(54)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(0)(16);
    regs_read_arr(54)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(0)(17);
    regs_read_arr(55)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(0)(18);
    regs_read_arr(55)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(0)(19);
    regs_read_arr(56)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVCCN_LSB) <= sca_adc_readings_arr(1)(0);
    regs_read_arr(56)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVTTN_LSB) <= sca_adc_readings_arr(1)(1);
    regs_read_arr(57)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V0_INT_LSB) <= sca_adc_readings_arr(1)(2);
    regs_read_arr(57)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8F_LSB) <= sca_adc_readings_arr(1)(3);
    regs_read_arr(58)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V5_LSB) <= sca_adc_readings_arr(1)(4);
    regs_read_arr(58)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_2V5_IO_LSB) <= sca_adc_readings_arr(1)(5);
    regs_read_arr(59)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_3V0_LSB) <= sca_adc_readings_arr(1)(6);
    regs_read_arr(59)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8_LSB) <= sca_adc_readings_arr(1)(7);
    regs_read_arr(60)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(1)(8);
    regs_read_arr(60)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(1)(9);
    regs_read_arr(61)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_SCA_TEMP_LSB) <= sca_adc_readings_arr(1)(10);
    regs_read_arr(61)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(1)(11);
    regs_read_arr(62)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(1)(12);
    regs_read_arr(62)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(1)(13);
    regs_read_arr(63)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(1)(14);
    regs_read_arr(63)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(1)(15);
    regs_read_arr(64)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(1)(16);
    regs_read_arr(64)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(1)(17);
    regs_read_arr(65)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(1)(18);
    regs_read_arr(65)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(1)(19);
    regs_read_arr(66)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_AVCCN_LSB) <= sca_adc_readings_arr(2)(0);
    regs_read_arr(66)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_AVTTN_LSB) <= sca_adc_readings_arr(2)(1);
    regs_read_arr(67)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V0_INT_LSB) <= sca_adc_readings_arr(2)(2);
    regs_read_arr(67)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V8F_LSB) <= sca_adc_readings_arr(2)(3);
    regs_read_arr(68)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V5_LSB) <= sca_adc_readings_arr(2)(4);
    regs_read_arr(68)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_2V5_IO_LSB) <= sca_adc_readings_arr(2)(5);
    regs_read_arr(69)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_3V0_LSB) <= sca_adc_readings_arr(2)(6);
    regs_read_arr(69)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_1V8_LSB) <= sca_adc_readings_arr(2)(7);
    regs_read_arr(70)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(2)(8);
    regs_read_arr(70)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(2)(9);
    regs_read_arr(71)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_SCA_TEMP_LSB) <= sca_adc_readings_arr(2)(10);
    regs_read_arr(71)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(2)(11);
    regs_read_arr(72)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(2)(12);
    regs_read_arr(72)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(2)(13);
    regs_read_arr(73)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(2)(14);
    regs_read_arr(73)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(2)(15);
    regs_read_arr(74)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(2)(16);
    regs_read_arr(74)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(2)(17);
    regs_read_arr(75)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(2)(18);
    regs_read_arr(75)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH2_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(2)(19);
    regs_read_arr(76)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_AVCCN_LSB) <= sca_adc_readings_arr(3)(0);
    regs_read_arr(76)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_AVTTN_LSB) <= sca_adc_readings_arr(3)(1);
    regs_read_arr(77)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V0_INT_LSB) <= sca_adc_readings_arr(3)(2);
    regs_read_arr(77)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V8F_LSB) <= sca_adc_readings_arr(3)(3);
    regs_read_arr(78)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V5_LSB) <= sca_adc_readings_arr(3)(4);
    regs_read_arr(78)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_2V5_IO_LSB) <= sca_adc_readings_arr(3)(5);
    regs_read_arr(79)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_3V0_LSB) <= sca_adc_readings_arr(3)(6);
    regs_read_arr(79)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_1V8_LSB) <= sca_adc_readings_arr(3)(7);
    regs_read_arr(80)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(3)(8);
    regs_read_arr(80)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(3)(9);
    regs_read_arr(81)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_SCA_TEMP_LSB) <= sca_adc_readings_arr(3)(10);
    regs_read_arr(81)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(3)(11);
    regs_read_arr(82)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(3)(12);
    regs_read_arr(82)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(3)(13);
    regs_read_arr(83)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(3)(14);
    regs_read_arr(83)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(3)(15);
    regs_read_arr(84)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(3)(16);
    regs_read_arr(84)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(3)(17);
    regs_read_arr(85)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(3)(18);
    regs_read_arr(85)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH3_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(3)(19);
    regs_read_arr(86)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_AVCCN_LSB) <= sca_adc_readings_arr(4)(0);
    regs_read_arr(86)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_AVTTN_LSB) <= sca_adc_readings_arr(4)(1);
    regs_read_arr(87)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V0_INT_LSB) <= sca_adc_readings_arr(4)(2);
    regs_read_arr(87)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V8F_LSB) <= sca_adc_readings_arr(4)(3);
    regs_read_arr(88)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V5_LSB) <= sca_adc_readings_arr(4)(4);
    regs_read_arr(88)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_2V5_IO_LSB) <= sca_adc_readings_arr(4)(5);
    regs_read_arr(89)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_3V0_LSB) <= sca_adc_readings_arr(4)(6);
    regs_read_arr(89)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_1V8_LSB) <= sca_adc_readings_arr(4)(7);
    regs_read_arr(90)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(4)(8);
    regs_read_arr(90)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(4)(9);
    regs_read_arr(91)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_SCA_TEMP_LSB) <= sca_adc_readings_arr(4)(10);
    regs_read_arr(91)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(4)(11);
    regs_read_arr(92)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(4)(12);
    regs_read_arr(92)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(4)(13);
    regs_read_arr(93)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(4)(14);
    regs_read_arr(93)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(4)(15);
    regs_read_arr(94)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(4)(16);
    regs_read_arr(94)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(4)(17);
    regs_read_arr(95)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(4)(18);
    regs_read_arr(95)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH4_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(4)(19);
    regs_read_arr(96)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_AVCCN_LSB) <= sca_adc_readings_arr(5)(0);
    regs_read_arr(96)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_AVTTN_LSB) <= sca_adc_readings_arr(5)(1);
    regs_read_arr(97)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V0_INT_LSB) <= sca_adc_readings_arr(5)(2);
    regs_read_arr(97)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V8F_LSB) <= sca_adc_readings_arr(5)(3);
    regs_read_arr(98)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V5_LSB) <= sca_adc_readings_arr(5)(4);
    regs_read_arr(98)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_2V5_IO_LSB) <= sca_adc_readings_arr(5)(5);
    regs_read_arr(99)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_3V0_LSB) <= sca_adc_readings_arr(5)(6);
    regs_read_arr(99)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_1V8_LSB) <= sca_adc_readings_arr(5)(7);
    regs_read_arr(100)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(5)(8);
    regs_read_arr(100)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(5)(9);
    regs_read_arr(101)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_SCA_TEMP_LSB) <= sca_adc_readings_arr(5)(10);
    regs_read_arr(101)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(5)(11);
    regs_read_arr(102)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(5)(12);
    regs_read_arr(102)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(5)(13);
    regs_read_arr(103)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(5)(14);
    regs_read_arr(103)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(5)(15);
    regs_read_arr(104)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(5)(16);
    regs_read_arr(104)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(5)(17);
    regs_read_arr(105)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(5)(18);
    regs_read_arr(105)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH5_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(5)(19);
    regs_read_arr(106)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_AVCCN_LSB) <= sca_adc_readings_arr(6)(0);
    regs_read_arr(106)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_AVTTN_LSB) <= sca_adc_readings_arr(6)(1);
    regs_read_arr(107)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V0_INT_LSB) <= sca_adc_readings_arr(6)(2);
    regs_read_arr(107)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V8F_LSB) <= sca_adc_readings_arr(6)(3);
    regs_read_arr(108)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V5_LSB) <= sca_adc_readings_arr(6)(4);
    regs_read_arr(108)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_2V5_IO_LSB) <= sca_adc_readings_arr(6)(5);
    regs_read_arr(109)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_3V0_LSB) <= sca_adc_readings_arr(6)(6);
    regs_read_arr(109)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_1V8_LSB) <= sca_adc_readings_arr(6)(7);
    regs_read_arr(110)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(6)(8);
    regs_read_arr(110)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(6)(9);
    regs_read_arr(111)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_SCA_TEMP_LSB) <= sca_adc_readings_arr(6)(10);
    regs_read_arr(111)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(6)(11);
    regs_read_arr(112)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(6)(12);
    regs_read_arr(112)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(6)(13);
    regs_read_arr(113)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(6)(14);
    regs_read_arr(113)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(6)(15);
    regs_read_arr(114)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(6)(16);
    regs_read_arr(114)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(6)(17);
    regs_read_arr(115)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(6)(18);
    regs_read_arr(115)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH6_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(6)(19);
    regs_read_arr(116)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_AVCCN_LSB) <= sca_adc_readings_arr(7)(0);
    regs_read_arr(116)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_AVTTN_LSB) <= sca_adc_readings_arr(7)(1);
    regs_read_arr(117)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V0_INT_LSB) <= sca_adc_readings_arr(7)(2);
    regs_read_arr(117)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V8F_LSB) <= sca_adc_readings_arr(7)(3);
    regs_read_arr(118)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V5_LSB) <= sca_adc_readings_arr(7)(4);
    regs_read_arr(118)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_2V5_IO_LSB) <= sca_adc_readings_arr(7)(5);
    regs_read_arr(119)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_3V0_LSB) <= sca_adc_readings_arr(7)(6);
    regs_read_arr(119)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_1V8_LSB) <= sca_adc_readings_arr(7)(7);
    regs_read_arr(120)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(7)(8);
    regs_read_arr(120)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(7)(9);
    regs_read_arr(121)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_SCA_TEMP_LSB) <= sca_adc_readings_arr(7)(10);
    regs_read_arr(121)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(7)(11);
    regs_read_arr(122)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(7)(12);
    regs_read_arr(122)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(7)(13);
    regs_read_arr(123)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(7)(14);
    regs_read_arr(123)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(7)(15);
    regs_read_arr(124)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(7)(16);
    regs_read_arr(124)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(7)(17);
    regs_read_arr(125)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(7)(18);
    regs_read_arr(125)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH7_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(7)(19);
    regs_read_arr(126)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_AVCCN_LSB) <= sca_adc_readings_arr(8)(0);
    regs_read_arr(126)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_AVTTN_LSB) <= sca_adc_readings_arr(8)(1);
    regs_read_arr(127)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V0_INT_LSB) <= sca_adc_readings_arr(8)(2);
    regs_read_arr(127)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V8F_LSB) <= sca_adc_readings_arr(8)(3);
    regs_read_arr(128)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V5_LSB) <= sca_adc_readings_arr(8)(4);
    regs_read_arr(128)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_2V5_IO_LSB) <= sca_adc_readings_arr(8)(5);
    regs_read_arr(129)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_3V0_LSB) <= sca_adc_readings_arr(8)(6);
    regs_read_arr(129)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_1V8_LSB) <= sca_adc_readings_arr(8)(7);
    regs_read_arr(130)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(8)(8);
    regs_read_arr(130)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(8)(9);
    regs_read_arr(131)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_SCA_TEMP_LSB) <= sca_adc_readings_arr(8)(10);
    regs_read_arr(131)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(8)(11);
    regs_read_arr(132)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(8)(12);
    regs_read_arr(132)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(8)(13);
    regs_read_arr(133)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(8)(14);
    regs_read_arr(133)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(8)(15);
    regs_read_arr(134)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(8)(16);
    regs_read_arr(134)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(8)(17);
    regs_read_arr(135)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(8)(18);
    regs_read_arr(135)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH8_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(8)(19);
    regs_read_arr(136)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_AVCCN_LSB) <= sca_adc_readings_arr(9)(0);
    regs_read_arr(136)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_AVTTN_LSB) <= sca_adc_readings_arr(9)(1);
    regs_read_arr(137)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V0_INT_LSB) <= sca_adc_readings_arr(9)(2);
    regs_read_arr(137)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V8F_LSB) <= sca_adc_readings_arr(9)(3);
    regs_read_arr(138)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V5_LSB) <= sca_adc_readings_arr(9)(4);
    regs_read_arr(138)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_2V5_IO_LSB) <= sca_adc_readings_arr(9)(5);
    regs_read_arr(139)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_3V0_LSB) <= sca_adc_readings_arr(9)(6);
    regs_read_arr(139)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_1V8_LSB) <= sca_adc_readings_arr(9)(7);
    regs_read_arr(140)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(9)(8);
    regs_read_arr(140)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(9)(9);
    regs_read_arr(141)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_SCA_TEMP_LSB) <= sca_adc_readings_arr(9)(10);
    regs_read_arr(141)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(9)(11);
    regs_read_arr(142)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(9)(12);
    regs_read_arr(142)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(9)(13);
    regs_read_arr(143)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(9)(14);
    regs_read_arr(143)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(9)(15);
    regs_read_arr(144)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(9)(16);
    regs_read_arr(144)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(9)(17);
    regs_read_arr(145)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(9)(18);
    regs_read_arr(145)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH9_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(9)(19);
    regs_read_arr(146)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_AVCCN_LSB) <= sca_adc_readings_arr(10)(0);
    regs_read_arr(146)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_AVTTN_LSB) <= sca_adc_readings_arr(10)(1);
    regs_read_arr(147)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V0_INT_LSB) <= sca_adc_readings_arr(10)(2);
    regs_read_arr(147)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V8F_LSB) <= sca_adc_readings_arr(10)(3);
    regs_read_arr(148)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V5_LSB) <= sca_adc_readings_arr(10)(4);
    regs_read_arr(148)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_2V5_IO_LSB) <= sca_adc_readings_arr(10)(5);
    regs_read_arr(149)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_3V0_LSB) <= sca_adc_readings_arr(10)(6);
    regs_read_arr(149)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_1V8_LSB) <= sca_adc_readings_arr(10)(7);
    regs_read_arr(150)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(10)(8);
    regs_read_arr(150)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(10)(9);
    regs_read_arr(151)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_SCA_TEMP_LSB) <= sca_adc_readings_arr(10)(10);
    regs_read_arr(151)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(10)(11);
    regs_read_arr(152)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(10)(12);
    regs_read_arr(152)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(10)(13);
    regs_read_arr(153)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(10)(14);
    regs_read_arr(153)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(10)(15);
    regs_read_arr(154)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(10)(16);
    regs_read_arr(154)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(10)(17);
    regs_read_arr(155)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(10)(18);
    regs_read_arr(155)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH10_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(10)(19);
    regs_read_arr(156)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_AVCCN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_AVCCN_LSB) <= sca_adc_readings_arr(11)(0);
    regs_read_arr(156)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_AVTTN_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_AVTTN_LSB) <= sca_adc_readings_arr(11)(1);
    regs_read_arr(157)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V0_INT_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V0_INT_LSB) <= sca_adc_readings_arr(11)(2);
    regs_read_arr(157)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V8F_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V8F_LSB) <= sca_adc_readings_arr(11)(3);
    regs_read_arr(158)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V5_LSB) <= sca_adc_readings_arr(11)(4);
    regs_read_arr(158)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_2V5_IO_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_2V5_IO_LSB) <= sca_adc_readings_arr(11)(5);
    regs_read_arr(159)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_3V0_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_3V0_LSB) <= sca_adc_readings_arr(11)(6);
    regs_read_arr(159)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_1V8_LSB) <= sca_adc_readings_arr(11)(7);
    regs_read_arr(160)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_VTRX_RSSI2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_VTRX_RSSI2_LSB) <= sca_adc_readings_arr(11)(8);
    regs_read_arr(160)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_VTRX_RSSI1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_VTRX_RSSI1_LSB) <= sca_adc_readings_arr(11)(9);
    regs_read_arr(161)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_SCA_TEMP_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_SCA_TEMP_LSB) <= sca_adc_readings_arr(11)(10);
    regs_read_arr(161)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP1_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP1_LSB) <= sca_adc_readings_arr(11)(11);
    regs_read_arr(162)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP2_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP2_LSB) <= sca_adc_readings_arr(11)(12);
    regs_read_arr(162)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP3_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP3_LSB) <= sca_adc_readings_arr(11)(13);
    regs_read_arr(163)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP4_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP4_LSB) <= sca_adc_readings_arr(11)(14);
    regs_read_arr(163)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP5_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP5_LSB) <= sca_adc_readings_arr(11)(15);
    regs_read_arr(164)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP6_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP6_LSB) <= sca_adc_readings_arr(11)(16);
    regs_read_arr(164)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP7_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP7_LSB) <= sca_adc_readings_arr(11)(17);
    regs_read_arr(165)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP8_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP8_LSB) <= sca_adc_readings_arr(11)(18);
    regs_read_arr(165)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP9_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH11_BOARD_TEMP9_LSB) <= sca_adc_readings_arr(11)(19);
    regs_read_arr(166)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB) <= jtag_enabled_mask;
    regs_read_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT) <= jtag_shift_msb_first;
    regs_read_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT) <= jtag_exec_on_every_tdo;
    regs_read_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT) <= jtag_no_length_update;
    regs_read_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT) <= jtag_shift_tdo_async;
    regs_read_arr(168)(REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB) <= jtag_cmd_length;
    regs_read_arr(171)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_LSB) <= jtag_tdi_arr(0);
    regs_read_arr(172)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH1_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH1_LSB) <= jtag_tdi_arr(1);
    regs_read_arr(173)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH2_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH2_LSB) <= jtag_tdi_arr(2);
    regs_read_arr(174)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH3_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH3_LSB) <= jtag_tdi_arr(3);
    regs_read_arr(175)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH4_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH4_LSB) <= jtag_tdi_arr(4);
    regs_read_arr(176)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH5_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH5_LSB) <= jtag_tdi_arr(5);
    regs_read_arr(177)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH6_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH6_LSB) <= jtag_tdi_arr(6);
    regs_read_arr(178)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH7_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH7_LSB) <= jtag_tdi_arr(7);
    regs_read_arr(179)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH8_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH8_LSB) <= jtag_tdi_arr(8);
    regs_read_arr(180)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH9_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH9_LSB) <= jtag_tdi_arr(9);
    regs_read_arr(181)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH10_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH10_LSB) <= jtag_tdi_arr(10);
    regs_read_arr(182)(REG_SLOW_CONTROL_SCA_JTAG_TDI_OH11_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDI_OH11_LSB) <= jtag_tdi_arr(11);
    regs_read_arr(183)(REG_SLOW_CONTROL_IC_ADDRESS_MSB downto REG_SLOW_CONTROL_IC_ADDRESS_LSB) <= ic_address;
    regs_read_arr(184)(REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB downto REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB) <= ic_rw_length;
    regs_read_arr(185)(REG_SLOW_CONTROL_IC_WRITE_DATA_MSB downto REG_SLOW_CONTROL_IC_WRITE_DATA_LSB) <= ic_write_data;
    regs_read_arr(188)(REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB downto REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB) <= ic_gbtx_i2c_addr;

    -- Connect write signals
    sca_ttc_hr_enable <= regs_write_arr(2)(REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT);
    sca_user_command_en_mask <= regs_write_arr(17)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB);
    sca_user_command.channel <= regs_write_arr(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB);
    sca_user_command.command <= regs_write_arr(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB);
    sca_user_command.length <= regs_write_arr(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB);
    sca_user_command.data <= regs_write_arr(19)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB);
    sca_adc_monitor_off_arr <= regs_write_arr(45)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB);
    jtag_enabled_mask <= regs_write_arr(166)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB);
    jtag_shift_msb_first <= regs_write_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT);
    jtag_exec_on_every_tdo <= regs_write_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT);
    jtag_no_length_update <= regs_write_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT);
    jtag_shift_tdo_async <= regs_write_arr(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT);
    jtag_cmd_length <= regs_write_arr(168)(REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB);
    jtag_tms <= regs_write_arr(169)(REG_SLOW_CONTROL_SCA_JTAG_TMS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TMS_LSB);
    jtag_tdo <= regs_write_arr(170)(REG_SLOW_CONTROL_SCA_JTAG_TDO_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDO_LSB);
    ic_address <= regs_write_arr(183)(REG_SLOW_CONTROL_IC_ADDRESS_MSB downto REG_SLOW_CONTROL_IC_ADDRESS_LSB);
    ic_rw_length <= regs_write_arr(184)(REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB downto REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB);
    ic_write_data <= regs_write_arr(185)(REG_SLOW_CONTROL_IC_WRITE_DATA_MSB downto REG_SLOW_CONTROL_IC_WRITE_DATA_LSB);
    ic_gbtx_i2c_addr <= regs_write_arr(188)(REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB downto REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB);

    -- Connect write pulse signals
    sca_reset <= regs_write_pulse_arr(0);
    manual_hard_reset <= regs_write_pulse_arr(1);
    sca_user_command_en <= regs_write_pulse_arr(20);
    jtag_shift_tms_en <= regs_write_pulse_arr(169);
    jtag_shift_tdo_en <= regs_write_pulse_arr(170);
    ic_write_req <= regs_write_pulse_arr(186);
    ic_read_req <= regs_write_pulse_arr(187);

    -- Connect write done signals
    regs_write_done_arr(20) <= sca_user_command_done_all;
    regs_write_done_arr(169) <= jtag_shift_done_all;
    regs_write_done_arr(170) <= jtag_shift_done_all;
    regs_write_done_arr(186) <= ic_write_done;

    -- Connect read pulse signals
    jtag_shift_tdi_en_arr(0) <= regs_read_pulse_arr(171);
    jtag_shift_tdi_en_arr(1) <= regs_read_pulse_arr(172);
    jtag_shift_tdi_en_arr(2) <= regs_read_pulse_arr(173);
    jtag_shift_tdi_en_arr(3) <= regs_read_pulse_arr(174);
    jtag_shift_tdi_en_arr(4) <= regs_read_pulse_arr(175);
    jtag_shift_tdi_en_arr(5) <= regs_read_pulse_arr(176);
    jtag_shift_tdi_en_arr(6) <= regs_read_pulse_arr(177);
    jtag_shift_tdi_en_arr(7) <= regs_read_pulse_arr(178);
    jtag_shift_tdi_en_arr(8) <= regs_read_pulse_arr(179);
    jtag_shift_tdi_en_arr(9) <= regs_read_pulse_arr(180);
    jtag_shift_tdi_en_arr(10) <= regs_read_pulse_arr(181);
    jtag_shift_tdi_en_arr(11) <= regs_read_pulse_arr(182);

    -- Connect read ready signals
    regs_read_ready_arr(171) <= jtag_shift_done_arr(0);
    regs_read_ready_arr(172) <= jtag_shift_done_arr(1);
    regs_read_ready_arr(173) <= jtag_shift_done_arr(2);
    regs_read_ready_arr(174) <= jtag_shift_done_arr(3);
    regs_read_ready_arr(175) <= jtag_shift_done_arr(4);
    regs_read_ready_arr(176) <= jtag_shift_done_arr(5);
    regs_read_ready_arr(177) <= jtag_shift_done_arr(6);
    regs_read_ready_arr(178) <= jtag_shift_done_arr(7);
    regs_read_ready_arr(179) <= jtag_shift_done_arr(8);
    regs_read_ready_arr(180) <= jtag_shift_done_arr(9);
    regs_read_ready_arr(181) <= jtag_shift_done_arr(10);
    regs_read_ready_arr(182) <= jtag_shift_done_arr(11);

    -- Defaults
    regs_defaults(2)(REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT) <= REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_DEFAULT;
    regs_defaults(17)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_DEFAULT;
    regs_defaults(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_DEFAULT;
    regs_defaults(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_DEFAULT;
    regs_defaults(18)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_DEFAULT;
    regs_defaults(19)(REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB downto REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB) <= REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_DEFAULT;
    regs_defaults(45)(REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB downto REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB) <= REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_DEFAULT;
    regs_defaults(166)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB downto REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_DEFAULT;
    regs_defaults(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_DEFAULT;
    regs_defaults(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_DEFAULT;
    regs_defaults(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_DEFAULT;
    regs_defaults(167)(REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT) <= REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_DEFAULT;
    regs_defaults(168)(REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_DEFAULT;
    regs_defaults(169)(REG_SLOW_CONTROL_SCA_JTAG_TMS_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TMS_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_TMS_DEFAULT;
    regs_defaults(170)(REG_SLOW_CONTROL_SCA_JTAG_TDO_MSB downto REG_SLOW_CONTROL_SCA_JTAG_TDO_LSB) <= REG_SLOW_CONTROL_SCA_JTAG_TDO_DEFAULT;
    regs_defaults(183)(REG_SLOW_CONTROL_IC_ADDRESS_MSB downto REG_SLOW_CONTROL_IC_ADDRESS_LSB) <= REG_SLOW_CONTROL_IC_ADDRESS_DEFAULT;
    regs_defaults(184)(REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB downto REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB) <= REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_DEFAULT;
    regs_defaults(185)(REG_SLOW_CONTROL_IC_WRITE_DATA_MSB downto REG_SLOW_CONTROL_IC_WRITE_DATA_LSB) <= REG_SLOW_CONTROL_IC_WRITE_DATA_DEFAULT;
    regs_defaults(188)(REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB downto REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB) <= REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_DEFAULT;

    -- Define writable regs
    regs_writable_arr(2) <= '1';
    regs_writable_arr(17) <= '1';
    regs_writable_arr(18) <= '1';
    regs_writable_arr(19) <= '1';
    regs_writable_arr(45) <= '1';
    regs_writable_arr(166) <= '1';
    regs_writable_arr(167) <= '1';
    regs_writable_arr(168) <= '1';
    regs_writable_arr(169) <= '1';
    regs_writable_arr(170) <= '1';
    regs_writable_arr(183) <= '1';
    regs_writable_arr(184) <= '1';
    regs_writable_arr(185) <= '1';
    regs_writable_arr(188) <= '1';

    --==== Registers end ============================================================================
        
end slow_control_arch;
