------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    23:45:21 2016-04-20
-- Module Name:    GEM_AMC 
-- Description:    This is the top module of all the common GEM AMC logic. It is board-agnostic and can be used in different FPGA / board designs 
--                 Note: the GBT MGT data and clocks must be ordered in groups of 3 for each OH: OH0 GBT0, OH0 GBT1, OH0 GBT2, OH1 GBT0, OH1 GTB1, OH1 GBT2, OH2 GBT0, etc... 
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

use work.gem_pkg.all;
use work.gem_board_config_package.all;
use work.ipb_addr_decode.all;
use work.ipbus.all;
use work.ttc_pkg.all;
use work.vendor_specific_gbt_bank_package.all;
use work.lpgbtfpga_package.all;

entity gem_amc is
    generic(
        g_GEM_STATION        : integer;
        g_NUM_OF_OHs         : integer;
        g_NUM_GBTS_PER_OH    : integer;
        g_NUM_VFATS_PER_OH   : integer;
        g_USE_TRIG_TX_LINKS  : boolean := true;  -- if true, then trigger output links will be instantiated
        g_NUM_TRIG_TX_LINKS  : integer;
        
        g_NUM_IPB_SLAVES     : integer;
        g_DAQ_CLK_FREQ       : integer
    );
    port(
        reset_i                 : in   std_logic;
        reset_pwrup_o           : out  std_logic;

        -- TTC
        ttc_clocks_i            : in t_ttc_clks;
        ttc_clocks_locked_i     : in  std_logic;
        ttc_data_p_i            : in  std_logic;      -- TTC protocol backplane signals
        ttc_data_n_i            : in  std_logic;
        
        -- Trigger RX GTX / GTH links (3.2Gbs, 16bit @ 160MHz w/ 8b10b encoding)
        gt_trig0_rx_clk_arr_i   : in  std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
        gt_trig0_rx_data_arr_i  : in  t_gt_8b10b_rx_data_arr(g_NUM_OF_OHs - 1 downto 0);
        gt_trig1_rx_clk_arr_i   : in  std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
        gt_trig1_rx_data_arr_i  : in  t_gt_8b10b_rx_data_arr(g_NUM_OF_OHs - 1 downto 0);

        -- Trigger TX GTH links (3.2Gbs, 16bit @ 160MHz w/ 8b10b encoding) -- this is just for testing right now, will be changed to (9.6Gbs, 32bit @ 240MHz w/ 8b10b encoding)
        gt_trig_tx_data_arr_o   : out t_gt_8b10b_tx_data_arr(g_NUM_TRIG_TX_LINKS - 1 downto 0);
        gt_trig_tx_clk_i        : in  std_logic;

        -- GBT DAQ + Control GTX / GTH links (4.8Gbs, 40bit @ 120MHz without encoding when using GBTX, and 10.24Gbp, lower 32bit @ 320MHz without encoding when using LpGBT)
        gt_gbt_rx_data_arr_i    : in  t_gt_gbt_data_arr(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
        gt_gbt_tx_data_arr_o    : out t_gt_gbt_data_arr(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
        gt_gbt_rx_clk_arr_i     : in  std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
        gt_gbt_tx_clk_arr_i     : in  std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
        gt_gbt_rx_common_clk_i  : in  std_logic;
        
        gt_gbt_status_arr_i     : in  t_mgt_status_arr(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
        gt_gbt_ctrl_arr_o       : out t_mgt_ctrl_arr(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);

        -- IPbus
        ipb_reset_i             : in  std_logic;
        ipb_clk_i               : in  std_logic;
        ipb_miso_arr_o          : out ipb_rbus_array(g_NUM_IPB_SLAVES - 1 downto 0);
        ipb_mosi_arr_i          : in  ipb_wbus_array(g_NUM_IPB_SLAVES - 1 downto 0);
        
        -- LEDs
        led_l1a_o               : out std_logic;
        led_trigger_o           : out std_logic;
        
        -- DAQLink
        daq_data_clk_i          : in  std_logic;
        daq_data_clk_locked_i   : in  std_logic;
        daq_to_daqlink_o        : out t_daq_to_daqlink;
        daqlink_to_daq_i        : in  t_daqlink_to_daq;
        
        -- Board serial number
        board_id_i              : in std_logic_vector(15 downto 0);
      
        -- GEM loader
        to_gem_loader_o         : out t_to_gem_loader;
        from_gem_loader_i       : in  t_from_gem_loader
        
    );
end gem_amc;

architecture gem_amc_arch of gem_amc is

    --================================--
    -- Signals
    --================================--

    --== General ==--
    signal reset                : std_logic;
    signal reset_pwrup          : std_logic;
    signal ipb_reset            : std_logic;
    signal link_reset           : std_logic;
    signal manual_link_reset    : std_logic;

    --== TTC signals ==--
    signal ttc_cmd              : t_ttc_cmds;
    signal ttc_counters         : t_ttc_daq_cntrs;
    signal ttc_status           : t_ttc_status;

    --== Trigger signals ==--    
    signal sbit_clusters_arr        : t_oh_sbits_arr(g_NUM_OF_OHs - 1 downto 0);
    signal sbit_links_status_arr    : t_oh_sbit_links_arr(g_NUM_OF_OHs - 1 downto 0);
    
    --== GBT ==--
    signal gbt_tx_data_arr              : t_gbt_frame_array(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);    
    signal lpgbt_tx_data_arr            : t_lpgbt_tx_frame_array(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);    
    signal gbt_tx_gearbox_aligned_arr   : std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal gbt_tx_gearbox_align_done_arr: std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
            
    signal gbt_rx_data_arr              : t_gbt_frame_array(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);    
    signal lpgbt_rx_data_arr            : t_lpgbt_rx_frame_array(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);    
    signal gbt_rx_valid_arr             : std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal gbt_rx_header                : std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal gbt_rx_header_locked         : std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal gbt_rx_bitslip_nbr           : rxBitSlipNbr_mxnbit_A(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    
    signal gbt_link_status_arr          : t_gbt_link_status_arr(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal gbt_ready_arr                : std_logic_vector(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    
    signal lpgbt_reset_tx               : std_logic;
    signal lpgbt_reset_rx               : std_logic;

    --== GBT elinks ==--
    signal sca_tx_data_arr              : t_std2_array(g_NUM_OF_OHs - 1 downto 0);
    signal sca_rx_data_arr              : t_std2_array(g_NUM_OF_OHs - 1 downto 0);
    signal gbt_ic_tx_data_arr           : t_std2_array(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal gbt_ic_rx_data_arr           : t_std2_array(g_NUM_OF_OHs * g_NUM_GBTS_PER_OH - 1 downto 0);
    signal promless_tx_data             : std_logic_vector(15 downto 0);
    signal oh_fpga_tx_data_arr          : t_std8_array(g_NUM_OF_OHs - 1 downto 0);
    signal oh_fpga_rx_data_arr          : t_std8_array(g_NUM_OF_OHs - 1 downto 0);
    signal vfat3_tx_data_arr            : t_vfat3_elinks_arr(g_NUM_OF_OHs - 1 downto 0);
    signal vfat3_rx_data_arr            : t_vfat3_elinks_arr(g_NUM_OF_OHs - 1 downto 0);
    
    --== VFAT3 ==--
    signal vfat3_sc_only_mode           : std_logic;
    signal vfat3_tx_stream              : std_logic_vector(7 downto 0);
    signal vfat3_tx_idle                : std_logic;
    signal vfat3_sync                   : std_logic;
    signal vfat3_sync_verify            : std_logic;
    signal vfat3_link_status_arr        : t_oh_vfat_link_status_arr(g_NUM_OF_OHs - 1 downto 0);
    
    signal vfat3_sc_tx_data             : std_logic;
    signal vfat3_sc_tx_rd_en            : std_logic;
    signal vfat3_sc_tx_rd_en_per_oh     : std_logic_vector(g_NUM_OF_OHs - 1 downto 0);
    signal vfat3_sc_tx_empty            : std_logic;
    signal vfat3_sc_tx_oh_idx           : std_logic_vector(3 downto 0);
    signal vfat3_sc_tx_vfat_idx         : std_logic_vector(4 downto 0);
    signal vfat3_sc_rx_data             : t_std24_array(g_NUM_OF_OHs - 1 downto 0);
    signal vfat3_sc_rx_data_en          : t_std24_array(g_NUM_OF_OHs - 1 downto 0);
    signal vfat3_sc_status              : t_vfat_slow_control_status;    
    
    signal vfat3_daq_link_arr           : t_oh_vfat_daq_link_arr(g_NUM_OF_OHs - 1 downto 0);
    signal vfat3_gbt_ready_arr          : t_std24_array(g_NUM_OF_OHs - 1 downto 0);
    
    signal vfat_mask_arr                : t_std24_array(g_NUM_OF_OHs - 1 downto 0);
    
    signal use_v3b_elink_mapping        : std_logic;

    -- test module links
    signal test_gbt_rx_data_arr         : t_gbt_frame_array((g_NUM_OF_OHs * g_NUM_GBTS_PER_OH) - 1 downto 0);
    signal test_gbt_tx_data_arr         : t_gbt_frame_array((g_NUM_OF_OHs * g_NUM_GBTS_PER_OH) - 1 downto 0);
    signal test_gbt_ready_arr           : std_logic_vector((g_NUM_OF_OHs * g_NUM_GBTS_PER_OH) - 1 downto 0);
        
    --== TEST module ==--
    signal loopback_gbt_test_en         : std_logic; 
    
    --== Other ==--
    signal ipb_miso_arr                 : ipb_rbus_array(g_NUM_IPB_SLAVES - 1 downto 0) := (others => (ipb_rdata => (others => '0'), ipb_ack => '0', ipb_err => '0'));
    
    --== Debug ==--
    signal dbg_lpgbt_tx_data            : t_lpgbt_tx_frame;
    signal dbg_lpgbt_rx_data            : t_lpgbt_rx_frame;
    signal dbg_gbt_tx_data              : std_logic_vector(83 downto 0);
    signal dbg_gbt_rx_data              : std_logic_vector(83 downto 0);
    signal dbg_gbt_tx_gearbox_aligned   : std_logic;
    signal dbg_gbt_tx_gearbox_align_done: std_logic;
    signal dbg_gbt_rx_ready             : std_logic;
    signal dbg_gbt_rx_header            : std_logic;
    signal dbg_gbt_rx_header_locked     : std_logic;
    signal dbg_gbt_rx_valid             : std_logic;
    signal dbg_gbt_rx_bitslip_nbr       : std_logic_vector(GBTRX_BITSLIP_NBR_MSB downto 0);
    signal dbg_gbt_link_status          : t_gbt_link_status;

    signal dbg_gbt_link_select          : std_logic_vector(5 downto 0);
    signal dbg_vfat_link_select         : std_logic_vector(4 downto 0);

begin

    --================================--
    -- Wiring
    --================================--
    
    reset_pwrup_o <= reset_pwrup;
    reset <= reset_i or reset_pwrup; -- TODO: Add a global reset from IPbus
    ipb_reset <= ipb_reset_i or reset_pwrup;
    ipb_miso_arr_o <= ipb_miso_arr;
    link_reset <= manual_link_reset or ttc_cmd.hard_reset;

    -- select the GBT link to debug
    dbg_gbt_tx_data               <= gbt_tx_data_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_rx_data               <= gbt_rx_data_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_lpgbt_tx_data             <= lpgbt_tx_data_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_lpgbt_rx_data             <= lpgbt_rx_data_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_tx_gearbox_aligned    <= gbt_tx_gearbox_aligned_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_tx_gearbox_align_done <= gbt_tx_gearbox_align_done_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_rx_ready              <= gbt_link_status_arr(to_integer(unsigned(dbg_gbt_link_select))).gbt_rx_ready;
    dbg_gbt_rx_header             <= gbt_rx_header(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_rx_header_locked      <= gbt_rx_header_locked(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_rx_valid              <= gbt_rx_valid_arr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_rx_bitslip_nbr        <= gbt_rx_bitslip_nbr(to_integer(unsigned(dbg_gbt_link_select)));
    dbg_gbt_link_status           <= gbt_link_status_arr(to_integer(unsigned(dbg_gbt_link_select)));
    
    --================================--
    -- Power-on reset  
    --================================--
    
    process(ttc_clocks_i.clk_40) -- NOTE: using TTC clock, no nothing will work if there's no TTC clock
        variable countdown : integer := 40_000_000; -- 1s - probably way too long, but ok for now (this is only used after powerup)
    begin
        if (rising_edge(ttc_clocks_i.clk_40)) then
            if (countdown > 0) then
              reset_pwrup <= '1';
              countdown := countdown - 1;
            else
              reset_pwrup <= '0';
            end if;
        end if;
    end process;    
    
    --================================--
    -- TTC  
    --================================--

    i_ttc : entity work.ttc
        port map(
            reset_i             => reset,
            ttc_clks_i          => ttc_clocks_i,
            ttc_clks_locked_i   => ttc_clocks_locked_i,
            ttc_data_p_i        => ttc_data_p_i,
            ttc_data_n_i        => ttc_data_n_i,
            ttc_cmds_o          => ttc_cmd,
            ttc_daq_cntrs_o     => ttc_counters,
            ttc_status_o        => ttc_status,
            l1a_led_o           => led_l1a_o,
            ipb_reset_i         => ipb_reset,
            ipb_clk_i           => ipb_clk_i,
            ipb_mosi_i          => ipb_mosi_arr_i(C_IPB_SLV.ttc),
            ipb_miso_o          => ipb_miso_arr(C_IPB_SLV.ttc)
        );
    
    --================================--
    -- VFAT3 TX stream  
    --================================--

    i_vfat3_tx_stream : entity work.vfat3_tx_stream
        port map(
            reset_i        => reset or link_reset,
            ttc_clk_i      => ttc_clocks_i,
            ttc_cmds_i     => ttc_cmd,
            sc_only_mode_i => vfat3_sc_only_mode,
            data_o         => vfat3_tx_stream,
            idle_o         => vfat3_tx_idle,
            sync_o         => vfat3_sync,
            sync_verify_o  => vfat3_sync_verify
        );

    --================================--
    -- VFAT3 Slow Control    TODO: move into slow control module 
    --================================--
    
    i_vfat3_slow_control : entity work.vfat3_slow_control
        generic map (
            g_NUM_OF_OHs => g_NUM_OF_OHs
        )
        port map(
            reset_i       => reset or link_reset,
            ttc_clk_i     => ttc_clocks_i,
            ipb_clk_i     => ipb_clk_i,
            ipb_mosi_i    => ipb_mosi_arr_i(C_IPB_SLV.vfat3),
            ipb_miso_o    => ipb_miso_arr(C_IPB_SLV.vfat3),
            tx_data_o     => vfat3_sc_tx_data,
            tx_rd_en_i    => vfat3_sc_tx_rd_en,
            tx_empty_o    => vfat3_sc_tx_empty,
            tx_oh_idx_o   => vfat3_sc_tx_oh_idx,
            tx_vfat_idx_o => vfat3_sc_tx_vfat_idx,
            rx_data_en_i  => vfat3_sc_rx_data_en,
            rx_data_i     => vfat3_sc_rx_data,
            status_o      => vfat3_sc_status
        );

    --================================--
    -- Optohybrids  
    --================================--
    
    i_optohybrids : for i in 0 to g_NUM_OF_OHs - 1 generate

        i_optohybrid_single : entity work.optohybrid
            generic map(
                g_GEM_STATION   => g_GEM_STATION,
                g_OH_IDX        => std_logic_vector(to_unsigned(i, 4)),
                g_DEBUG         => i = 0
            )
            port map(
                reset_i                 => reset or link_reset,
                ttc_clk_i               => ttc_clocks_i,
                ttc_cmds_i              => ttc_cmd,

                vfat3_tx_datastream_i   => vfat3_tx_stream,
                vfat3_tx_idle_i         => vfat3_tx_idle,
                vfat3_sync_i            => vfat3_sync,
                vfat3_sync_verify_i     => vfat3_sync_verify,

                fpga_tx_data_o          => oh_fpga_tx_data_arr(i),
                fpga_rx_data_i          => oh_fpga_rx_data_arr(i),

                vfat3_tx_data_o         => vfat3_tx_data_arr(i),
                vfat3_rx_data_i         => vfat3_rx_data_arr(i),
                vfat3_link_status_o     => vfat3_link_status_arr(i),
                vfat_mask_arr_i         => vfat_mask_arr(i),
                vfat_gbt_ready_arr_i    => vfat3_gbt_ready_arr(i),

                vfat3_sc_tx_data_i      => vfat3_sc_tx_data,
                vfat3_sc_tx_empty_i     => vfat3_sc_tx_empty,
                vfat3_sc_tx_oh_idx_i    => vfat3_sc_tx_oh_idx,
                vfat3_sc_tx_vfat_idx_i  => vfat3_sc_tx_vfat_idx,
                vfat3_sc_tx_rd_en_o     => vfat3_sc_tx_rd_en_per_oh(i),
                
                vfat3_sc_rx_data_o      => vfat3_sc_rx_data(i),
                vfat3_sc_rx_data_en_o   => vfat3_sc_rx_data_en(i),

                vfat3_daq_links_o       => vfat3_daq_link_arr(i),
                                
                sbit_clusters_o         => sbit_clusters_arr(i), 
                sbit_links_status_o     => sbit_links_status_arr(i), 
                gth_rx_trig_data_i      => (gt_trig0_rx_data_arr_i(i), gt_trig1_rx_data_arr_i(i)),
                gth_rx_trig_usrclk_i    => (gt_trig0_rx_clk_arr_i(i), gt_trig1_rx_clk_arr_i(i)),

                oh_reg_ipb_reset_i      => ipb_reset,
                oh_reg_ipb_clk_i        => ipb_clk_i,
                oh_reg_ipb_miso_o       => ipb_miso_arr(C_IPB_SLV.oh_reg(i)),
                oh_reg_ipb_mosi_i       => ipb_mosi_arr_i(C_IPB_SLV.oh_reg(i)),
                
                debug_vfat_select_i     => dbg_vfat_link_select
            );    
    
    end generate;

    vfat3_sc_tx_rd_en <= or_reduce(vfat3_sc_tx_rd_en_per_oh);

    --================================--
    -- Trigger  
    --================================--

    i_trigger : entity work.trigger
        generic map(
            g_NUM_OF_OHs => g_NUM_OF_OHs,
            g_NUM_TRIG_TX_LINKS => g_NUM_TRIG_TX_LINKS,
            g_USE_TRIG_TX_LINKS => g_USE_TRIG_TX_LINKS
        )
        port map(
            reset_i            => reset or link_reset,
            ttc_clk_i          => ttc_clocks_i,
            ttc_cmds_i         => ttc_cmd,
            sbit_clusters_i    => sbit_clusters_arr,
            sbit_link_status_i => sbit_links_status_arr,
            trig_led_o         => led_trigger_o,
            tx_link_clk_i      => gt_trig_tx_clk_i,
            trig_tx_data_arr_o => gt_trig_tx_data_arr_o,      
            ipb_reset_i        => ipb_reset,
            ipb_clk_i          => ipb_clk_i,
            ipb_miso_o         => ipb_miso_arr(C_IPB_SLV.trigger),
            ipb_mosi_i         => ipb_mosi_arr_i(C_IPB_SLV.trigger)
        );

    --================================--
    -- DAQ  
    --================================--

    i_daq : entity work.daq
        generic map(
            g_NUM_OF_OHs => g_NUM_OF_OHs,
            g_DAQ_CLK_FREQ => g_DAQ_CLK_FREQ,
            g_INCLUDE_SPY_FIFO => false,
            g_DEBUG => true
        )
        port map(
            reset_i                 => reset,
            daq_clk_i               => daq_data_clk_i,
            daq_clk_locked_i        => daq_data_clk_locked_i,
            daq_to_daqlink_o        => daq_to_daqlink_o,
            daqlink_to_daq_i        => daqlink_to_daq_i,
            ttc_clks_i              => ttc_clocks_i,
            ttc_cmds_i              => ttc_cmd,
            ttc_daq_cntrs_i         => ttc_counters,
            ttc_status_i            => ttc_status,
            vfat3_daq_clk_i         => ttc_clocks_i.clk_40,
            vfat3_daq_links_arr_i   => vfat3_daq_link_arr,
            ipb_reset_i             => ipb_reset_i,
            ipb_clk_i               => ipb_clk_i,
            ipb_mosi_i              => ipb_mosi_arr_i(C_IPB_SLV.daq),
            ipb_miso_o              => ipb_miso_arr(C_IPB_SLV.daq),
            board_sn_i              => board_id_i
        );    

    ------------ DEBUG - fanout DAQ data from OH1 to all DAQ inputs --------------
--    g_fake_daq_links : for i in 0 to g_NUM_OF_OHs - 1 generate
--        fake_tk_data_links(i) <= tk_data_links(1);
--    end generate;

    --================================--
    -- GEM System
    --================================--

    i_gem_system : entity work.gem_system_regs
        port map(
            ttc_clks_i                  => ttc_clocks_i,            
            reset_i                     => reset,
            ipb_clk_i                   => ipb_clk_i,
            ipb_reset_i                 => ipb_reset_i,
            ipb_mosi_i                  => ipb_mosi_arr_i(C_IPB_SLV.system),
            ipb_miso_o                  => ipb_miso_arr(C_IPB_SLV.system),
            board_id_o                  => open,
            loopback_gbt_test_en_o      => loopback_gbt_test_en,
            vfat3_sc_only_mode_o        => vfat3_sc_only_mode,
            use_v3b_elink_mapping_o     => use_v3b_elink_mapping,
            manual_link_reset_o         => manual_link_reset
        );

    --===============================--
    -- OH Link Counters and settings --
    --===============================--

    i_oh_link_registers : entity work.oh_link_regs
        generic map(
            g_NUM_OF_OHs        => g_NUM_OF_OHs,
            g_NUM_GBTS_PER_OH   => g_NUM_GBTS_PER_OH
        )
        port map(
            reset_i                 => reset,
            clk_i                   => ttc_clocks_i.clk_40,

            gbt_link_status_arr_i   => gbt_link_status_arr,
            vfat3_link_status_arr_i => vfat3_link_status_arr,

            vfat_mask_arr_o         => vfat_mask_arr,

            ipb_reset_i             => ipb_reset_i,
            ipb_clk_i               => ipb_clk_i,
            ipb_miso_o              => ipb_miso_arr(C_IPB_SLV.oh_links),
            ipb_mosi_i              => ipb_mosi_arr_i(C_IPB_SLV.oh_links)
        );

    --===================--
    --    Slow Control   --
    --===================--

    i_slow_control : entity work.slow_control
        generic map(
            g_NUM_OF_OHs        => g_NUM_OF_OHs,
            g_NUM_GBTS_PER_OH   => g_NUM_GBTS_PER_OH,
            g_DEBUG             => false
        )
        port map(
            reset_i             => reset,
            ttc_clk_i           => ttc_clocks_i,
            ttc_cmds_i          => ttc_cmd,
            gbt_rx_ready_i      => gbt_ready_arr,
            gbt_rx_sca_elinks_i => sca_rx_data_arr,
            gbt_tx_sca_elinks_o => sca_tx_data_arr,
            gbt_rx_ic_elinks_i  => gbt_ic_rx_data_arr,
            gbt_tx_ic_elinks_o  => gbt_ic_tx_data_arr,
            vfat3_sc_status_i   => vfat3_sc_status,
            ipb_reset_i         => ipb_reset_i,
            ipb_clk_i           => ipb_clk_i,
            ipb_miso_o          => ipb_miso_arr(C_IPB_SLV.slow_control),
            ipb_mosi_i          => ipb_mosi_arr_i(C_IPB_SLV.slow_control)
        );

    --=============--
    --    Tests    --
    --=============--
    
    i_gem_tests : entity work.gem_tests
        generic map(
            g_NUM_GBT_LINKS => g_NUM_OF_OHs * g_NUM_GBTS_PER_OH,
            g_NUM_OF_OHs    => g_NUM_OF_OHs,
            g_GEM_STATION   => g_GEM_STATION
        )
        port map(
            reset_i                     => reset_i,
            ttc_clk_i                   => ttc_clocks_i,
            ttc_cmds_i                  => ttc_cmd,
            loopback_gbt_test_en_i      => loopback_gbt_test_en,
            gbt_link_ready_i            => test_gbt_ready_arr,
            gbt_tx_data_arr_o           => test_gbt_tx_data_arr,
            gbt_rx_data_arr_i           => test_gbt_rx_data_arr,
            vfat3_daq_links_arr_i       => vfat3_daq_link_arr,
            ipb_reset_i                 => ipb_reset,
            ipb_clk_i                   => ipb_clk_i,
            ipb_mosi_i                  => ipb_mosi_arr_i(C_IPB_SLV.test),
            ipb_miso_o                  => ipb_miso_arr(C_IPB_SLV.test)
        );
        
    --==========--
    --    GBT   --
    --==========--
    
    g_gbtx : if (g_GEM_STATION = 1) or (g_GEM_STATION = 2) generate
        i_gbt : entity work.gbt
            generic map(
                GBT_BANK_ID     => 0,
                NUM_LINKS       => g_NUM_OF_OHs * g_NUM_GBTS_PER_OH,
                TX_OPTIMIZATION => 1,
                RX_OPTIMIZATION => 0,
                TX_ENCODING     => 0,
                RX_ENCODING     => 0
            )
            port map(
                reset_i                     => reset,
                cnt_reset_i                 => link_reset,
                tx_frame_clk_i              => ttc_clocks_i.clk_40,
                rx_frame_clk_i              => ttc_clocks_i.clk_40,
                rx_word_common_clk_i        => gt_gbt_rx_common_clk_i,
                tx_word_clk_arr_i           => gt_gbt_tx_clk_arr_i,
                rx_word_clk_arr_i           => gt_gbt_rx_clk_arr_i,
                tx_ready_arr_i              => (others => '1'),
                tx_we_arr_i                 => (others => '1'),
                tx_data_arr_i               => gbt_tx_data_arr,
                tx_gearbox_aligned_arr_o    => gbt_tx_gearbox_aligned_arr,
                tx_gearbox_align_done_arr_o => gbt_tx_gearbox_align_done_arr,
                rx_frame_clk_rdy_arr_i      => (others => '1'),
                rx_word_clk_rdy_arr_i       => (others => '1'),
                rx_bitslip_nbr_arr_o        => gbt_rx_bitslip_nbr,
                rx_header_arr_o             => gbt_rx_header,
                rx_header_locked_arr_o      => gbt_rx_header_locked,
                rx_data_valid_arr_o         => gbt_rx_valid_arr,
                rx_data_arr_o               => gbt_rx_data_arr,
                mgt_rx_rdy_arr_i            => (others => '1'),
                mgt_tx_data_arr_o           => gt_gbt_tx_data_arr_o,
                mgt_rx_data_arr_i           => gt_gbt_rx_data_arr_i,
                link_status_arr_o           => gbt_link_status_arr
            );
    end generate;

    g_lbgbt : if g_GEM_STATION = 0 generate

        component lpgbt is
            generic(
                g_NUM_LINKS             : integer;
                g_SKIP_ODD_TX           : boolean := true;
                g_RX_RATE               : integer := DATARATE_10G24;
                g_RX_ENCODING           : integer := FEC5;
                g_RESET_MGT_ON_EVEN     : integer := 0;
                g_USE_RX_SYNC_FIFOS     : boolean := true;
                g_USE_RX_CORRECTION_CNT : boolean := true
            );
            port(
                reset_i                     : in  std_logic;
                reset_tx_i                  : in  std_logic;
                reset_rx_i                  : in  std_logic;
                cnt_reset_i                 : in  std_logic;
                tx_frame_clk_i              : in  std_logic;
                rx_frame_clk_i              : in  std_logic;
                tx_word_clk_arr_i           : in  std_logic_vector(g_NUM_LINKS - 1 downto 0);
                rx_word_clk_arr_i           : in  std_logic_vector(g_NUM_LINKS - 1 downto 0);
                rx_word_common_clk_i        : in  std_logic;
                mgt_status_arr_i            : in  t_mgt_status_arr(g_NUM_LINKS - 1 downto 0);
                mgt_ctrl_arr_o              : out t_mgt_ctrl_arr(g_NUM_LINKS - 1 downto 0);
                mgt_tx_data_arr_o           : out t_gt_gbt_data_arr(g_NUM_LINKS - 1 downto 0);
                mgt_rx_data_arr_i           : in  t_gt_gbt_data_arr(g_NUM_LINKS - 1 downto 0);
                tx_data_arr_i               : in  t_lpgbt_tx_frame_array(g_NUM_LINKS - 1 downto 0);
                rx_data_arr_o               : out t_lpgbt_rx_frame_array(g_NUM_LINKS - 1 downto 0);
                link_status_arr_o           : out t_gbt_link_status_arr(g_NUM_LINKS - 1 downto 0)
            );
        end component lpgbt;

    begin

        i_gbt : component lpgbt
            generic map(
                g_NUM_LINKS             => g_NUM_OF_OHs * g_NUM_GBTS_PER_OH,
                g_SKIP_ODD_TX           => false,
                g_RX_RATE               => DATARATE_10G24,
                g_RX_ENCODING           => FEC5,
                g_RESET_MGT_ON_EVEN     => 0,
                g_USE_RX_SYNC_FIFOS     => true,
                g_USE_RX_CORRECTION_CNT => true
            )
            port map(
                reset_i              => reset_i,
                reset_tx_i           => lpgbt_reset_tx,
                reset_rx_i           => lpgbt_reset_rx,
                cnt_reset_i          => link_reset,
                tx_frame_clk_i       => ttc_clocks_i.clk_40,
                rx_frame_clk_i       => ttc_clocks_i.clk_40,
                tx_word_clk_arr_i    => gt_gbt_tx_clk_arr_i,
                rx_word_clk_arr_i    => gt_gbt_rx_clk_arr_i,
                rx_word_common_clk_i => gt_gbt_rx_common_clk_i,
                mgt_status_arr_i     => gt_gbt_status_arr_i,
                mgt_ctrl_arr_o       => gt_gbt_ctrl_arr_o,
                mgt_tx_data_arr_o    => gt_gbt_tx_data_arr_o,
                mgt_rx_data_arr_i    => gt_gbt_rx_data_arr_i,
                tx_data_arr_i        => lpgbt_tx_data_arr,
                rx_data_arr_o        => lpgbt_rx_data_arr,
                link_status_arr_o    => gbt_link_status_arr
            );
    end generate;

    g_gbt_link_mux_ge11 : if g_GEM_STATION = 1 generate
        i_gbt_link_mux : entity work.gbt_link_mux(gbt_link_mux_ge11)
            generic map(
                g_NUM_OF_OHs        => g_NUM_OF_OHs,
                g_NUM_GBTS_PER_OH   => g_NUM_GBTS_PER_OH
            )
            port map(
                gbt_frame_clk_i             => ttc_clocks_i.clk_40,
                
                gbt_rx_data_arr_i           => gbt_rx_data_arr,
                gbt_tx_data_arr_o           => gbt_tx_data_arr,
                gbt_link_status_arr_i       => gbt_link_status_arr,
    
                link_test_mode_i            => loopback_gbt_test_en,
                use_v3b_mapping_i           => use_v3b_elink_mapping,
    
                sca_tx_data_arr_i           => sca_tx_data_arr,
                sca_rx_data_arr_o           => sca_rx_data_arr,
                gbt_ic_tx_data_arr_i        => gbt_ic_tx_data_arr,
                gbt_ic_rx_data_arr_o        => gbt_ic_rx_data_arr,
                promless_tx_data_i          => promless_tx_data,
                oh_fpga_tx_data_arr_i       => oh_fpga_tx_data_arr,
                oh_fpga_rx_data_arr_o       => oh_fpga_rx_data_arr,
                vfat3_tx_data_arr_i         => vfat3_tx_data_arr,
                vfat3_rx_data_arr_o         => vfat3_rx_data_arr,
                gbt_ready_arr_o             => gbt_ready_arr,
                vfat3_gbt_ready_arr_o       => vfat3_gbt_ready_arr,
                
                tst_gbt_rx_data_arr_o       => test_gbt_rx_data_arr,
                tst_gbt_tx_data_arr_i       => test_gbt_tx_data_arr,
                tst_gbt_ready_arr_o         => test_gbt_ready_arr
            );    
    end generate;

    g_gbt_link_mux_ge21 : if g_GEM_STATION = 2 generate
        i_gbt_link_mux : entity work.gbt_link_mux(gbt_link_mux_ge21)
            generic map(
                g_NUM_OF_OHs        => g_NUM_OF_OHs,
                g_NUM_GBTS_PER_OH   => g_NUM_GBTS_PER_OH
            )
            port map(
                gbt_frame_clk_i             => ttc_clocks_i.clk_40,
                
                gbt_rx_data_arr_i           => gbt_rx_data_arr,
                gbt_tx_data_arr_o           => gbt_tx_data_arr,
                gbt_link_status_arr_i       => gbt_link_status_arr,
    
                link_test_mode_i            => loopback_gbt_test_en,
                use_v3b_mapping_i           => use_v3b_elink_mapping,
    
                sca_tx_data_arr_i           => sca_tx_data_arr,
                sca_rx_data_arr_o           => sca_rx_data_arr,
                gbt_ic_tx_data_arr_i        => gbt_ic_tx_data_arr,
                gbt_ic_rx_data_arr_o        => gbt_ic_rx_data_arr,
                promless_tx_data_i          => promless_tx_data,
                oh_fpga_tx_data_arr_i       => oh_fpga_tx_data_arr,
                oh_fpga_rx_data_arr_o       => oh_fpga_rx_data_arr,
                vfat3_tx_data_arr_i         => vfat3_tx_data_arr,
                vfat3_rx_data_arr_o         => vfat3_rx_data_arr,
                gbt_ready_arr_o             => gbt_ready_arr,
                vfat3_gbt_ready_arr_o       => vfat3_gbt_ready_arr,
                
                tst_gbt_rx_data_arr_o       => test_gbt_rx_data_arr,
                tst_gbt_tx_data_arr_i       => test_gbt_tx_data_arr,
                tst_gbt_ready_arr_o         => test_gbt_ready_arr
            );    
    end generate;

    g_gbt_link_mux_me0 : if g_GEM_STATION = 0 generate
        i_lpgbt_link_mux : entity work.lpgbt_link_mux
            generic map(
                g_NUM_OF_OHs      => g_NUM_OF_OHs,
                g_NUM_GBTS_PER_OH => g_NUM_GBTS_PER_OH
            )
            port map(
                gbt_frame_clk_i       => ttc_clocks_i.clk_40,
                
                gbt_rx_data_arr_i     => lpgbt_rx_data_arr,
                gbt_tx_data_arr_o     => lpgbt_tx_data_arr,
                gbt_link_status_arr_i => gbt_link_status_arr,
                
                gbt_ic_tx_data_arr_i  => gbt_ic_tx_data_arr,
                gbt_ic_rx_data_arr_o  => gbt_ic_rx_data_arr,
                vfat3_tx_data_arr_i   => vfat3_tx_data_arr,
                vfat3_rx_data_arr_o   => vfat3_rx_data_arr,
                gbt_ready_arr_o       => gbt_ready_arr,
                vfat3_gbt_ready_arr_o => vfat3_gbt_ready_arr
            );
    end generate;
    
    --===========================--
    --    OH FPGA programming    --
    --===========================--

    g_use_oh_fpga_loader : if (g_GEM_STATION = 1) or (g_GEM_STATION = 2) generate
        i_oh_fpga_loader : entity work.oh_fpga_loader
                generic map (
                    g_LOADER_CLK_80_MHZ => true
                )
            port map(
                reset_i           => reset_i,
                gbt_clk_i         => ttc_clocks_i.clk_40,
                loader_clk_i      => ttc_clocks_i.clk_80,
                to_gem_loader_o   => to_gem_loader_o,
                from_gem_loader_i => from_gem_loader_i,
                elink_data_o      => promless_tx_data,
                hard_reset_i      => ttc_cmd.hard_reset
            );
    end generate;
        
    --================================--
    -- Configuration Blaster  
    --================================--

    i_config_blaster : entity work.config_blaster
        generic map(
            g_NUM_OF_OHs => g_NUM_OF_OHs,
            g_DEBUG      => false
        )
        port map(
            reset_i     => reset,
            ttc_clks_i  => ttc_clocks_i,
            ttc_cmds_i  => ttc_cmd,
            ipb_reset_i => ipb_reset,
            ipb_clk_i   => ipb_clk_i,
            ipb_miso_o  => ipb_miso_arr(C_IPB_SLV.config_blaster),
            ipb_mosi_i  => ipb_mosi_arr_i(C_IPB_SLV.config_blaster)
        );

    --=============--
    --    Debug    --
    --=============--
    gen_debug:
    if CFG_USE_CHIPSCOPE generate

        component vio_debug_link_selector
            port(
                clk        : in  std_logic;
                probe_out0 : out std_logic_vector(5 downto 0);
                probe_out1 : out std_logic_vector(4 downto 0);
                probe_out2 : out std_logic;
                probe_out3 : out std_logic
            );
        end component;

        component ila_gbt
            port(
                clk     : in std_logic;
                probe0  : in std_logic_vector(83 downto 0);
                probe1  : in std_logic_vector(83 downto 0);
                probe2  : in std_logic;
                probe3  : in std_logic;
                probe4  : in std_logic;
                probe5  : in std_logic;
                probe6  : in std_logic;
                probe7  : in std_logic;
                probe8  : in std_logic_vector(5 downto 0)
            );
        end component;

        component ila_lpgbt
            port(
                clk     : in std_logic;
                probe0  : in std_logic_vector(31 downto 0);
                probe1  : in std_logic_vector(223 downto 0);
                probe2  : in std_logic;
                probe3  : in std_logic;
                probe4  : in std_logic;
                probe5  : in std_logic;
                probe6  : in std_logic;
                probe7  : in std_logic_vector(1 downto 0);
                probe8  : in std_logic_vector(1 downto 0);
                probe9  : in std_logic_vector(1 downto 0);
                probe10 : in std_logic_vector(1 downto 0);
                probe11  : in std_logic
            );
        end component;

    begin

        i_debug_link_selector : component vio_debug_link_selector
            port map(
                clk        => ttc_clocks_i.clk_40,
                probe_out0 => dbg_gbt_link_select,
                probe_out1 => dbg_vfat_link_select,
                probe_out2 => lpgbt_reset_tx,
                probe_out3 => lpgbt_reset_rx
            );

        g_gbt_debug : if CFG_GBT_DEBUG generate
            g_gbtx_ila : if (g_GEM_STATION = 1) or (g_GEM_STATION = 2) generate
                i_ila_gbt : component ila_gbt
                    port map(
                        clk     => ttc_clocks_i.clk_40,
                        probe0  => dbg_gbt_tx_data,
                        probe1  => dbg_gbt_rx_data,
                        probe2  => dbg_gbt_tx_gearbox_aligned,
                        probe3  => dbg_gbt_tx_gearbox_align_done,
                        probe4  => dbg_gbt_rx_ready,
                        probe5  => dbg_gbt_rx_header,
                        probe6  => dbg_gbt_rx_header_locked,
                        probe7  => dbg_gbt_rx_valid,
                        probe8  => dbg_gbt_rx_bitslip_nbr
                    );
            end generate;

            g_lpgbt_ila : if g_GEM_STATION = 0 generate
                i_ila_lpgbt : component ila_lpgbt
                    port map(
                        clk     => ttc_clocks_i.clk_40,
                        probe0  => dbg_lpgbt_tx_data.tx_data,
                        probe1  => dbg_lpgbt_rx_data.rx_data,
                        probe2  => dbg_gbt_link_status.gbt_rx_ready,
                        probe3  => dbg_gbt_link_status.gbt_rx_gearbox_ready,
                        probe4  => dbg_gbt_link_status.gbt_rx_header_locked,
                        probe5  => dbg_gbt_link_status.gbt_tx_ready,
                        probe6  => dbg_gbt_link_status.gbt_tx_gearbox_ready,
                        probe7  => dbg_lpgbt_tx_data.tx_ic_data,
                        probe8  => dbg_lpgbt_tx_data.tx_ec_data,
                        probe9  => dbg_lpgbt_rx_data.rx_ic_data,
                        probe10 => dbg_lpgbt_rx_data.rx_ec_data,
                        probe11 => dbg_gbt_link_status.gbt_rx_correction_flag
                    );
            end generate;
        end generate;

    end generate;

end gem_amc_arch;
