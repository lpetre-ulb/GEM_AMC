------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company:
-- Engineer:
-- 
-- Create Date:
-- Module Name:
-- Description:
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.gem_pkg.all;
use work.mgt_pkg.all;

entity gtx_regs is
    generic(
        g_NUM_GTX : integer := 8
    );
    port(
        ipb_clk_i        : in std_logic;
        ipb_reset_i      : in std_logic;
        ipb_mosi_i       : in ipb_wbus;
        ipb_miso_o       : out ipb_rbus;

        mgt_ctrl_arr_o   : out t_gtx_ctrl_arr(0 to g_NUM_GTX-1);
        mgt_status_arr_i : in t_gtx_status_arr(0 to g_NUM_GTX-1)
    );
end gtx_regs;

architecture gtx_regs_arch of gtx_regs is

    signal mgt_ctrl_arr         : t_gtx_ctrl_arr(0 to g_NUM_GTX-1);

    signal regs_read_arr        : t_std32_array(2*g_NUM_GTX - 1 downto 0);
    signal regs_write_arr       : t_std32_array(2*g_NUM_GTX - 1 downto 0);
    signal regs_addresses       : t_std32_array(2*g_NUM_GTX - 1 downto 0);
    signal regs_defaults        : t_std32_array(2*g_NUM_GTX - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(2*g_NUM_GTX - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(2*g_NUM_GTX - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(2*g_NUM_GTX - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(2*g_NUM_GTX - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(2*g_NUM_GTX - 1 downto 0) := (others => '0');
    
begin

    mgt_ctrl_arr_o <= mgt_ctrl_arr;

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => 2*g_NUM_GTX,
           g_ADDR_HIGH_BIT        => 3,
           g_ADDR_LOW_BIT         => 0,
           g_USE_INDIVIDUAL_ADDRS => false
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => ipb_clk_i,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => ipb_clk_i,
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

    g_connections: for i in 0 to g_NUM_GTX-1 generate

        -- Connect read signals
        -- Control
        regs_read_arr(2*i)(2 downto 0)   <= mgt_ctrl_arr(i).loopback;

        regs_read_arr(2*i)(3)            <= mgt_ctrl_arr(i).tx_reset;
        regs_read_arr(2*i)(4)            <= mgt_ctrl_arr(i).tx_sync_reset;
        regs_read_arr(2*i)(6 downto 5)   <= mgt_ctrl_arr(i).tx_pd;
        regs_read_arr(2*i)(7)            <= mgt_ctrl_arr(i).tx_polarity;

        regs_read_arr(2*i)(11 downto 8)  <= mgt_ctrl_arr(i).tx_conf_diff;
        regs_read_arr(2*i)(16 downto 12) <= mgt_ctrl_arr(i).tx_post_emph;
        regs_read_arr(2*i)(20 downto 17) <= mgt_ctrl_arr(i).tx_pre_emph;

        regs_read_arr(2*i)(18)           <= mgt_ctrl_arr(i).rx_reset;
        regs_read_arr(2*i)(19)           <= mgt_ctrl_arr(i).rx_sync_reset;
        regs_read_arr(2*i)(21 downto 20) <= mgt_ctrl_arr(i).rx_pd;
        regs_read_arr(2*i)(22)           <= mgt_ctrl_arr(i).rx_polarity;

        regs_read_arr(2*i)(25 downto 23) <= mgt_ctrl_arr(i).prbs_pattern;
        regs_read_arr(2*i)(26)           <= mgt_ctrl_arr(i).prbs_force_tx_err;
        regs_read_arr(2*i)(27)           <= mgt_ctrl_arr(i).prbs_reset_rx_err_cnt;

        -- Status
        regs_read_arr(2*i+1)(0) <= mgt_status_arr_i(i).ready;
        regs_read_arr(2*i+1)(1) <= mgt_status_arr_i(i).rx_word_clk_ready;

        regs_read_arr(2*i+1)(2) <= mgt_status_arr_i(i).tx_mgt_ready;
        regs_read_arr(2*i+1)(3) <= mgt_status_arr_i(i).tx_reset_done;

        regs_read_arr(2*i+1)(4) <= mgt_status_arr_i(i).rx_mgt_ready;
        regs_read_arr(2*i+1)(5) <= mgt_status_arr_i(i).rx_reset_done;

        regs_read_arr(2*i+1)(6) <= mgt_status_arr_i(i).prbs_rx_err;

        -- Connect write signals
        mgt_ctrl_arr(i).loopback      <= regs_write_arr(2*i)(2 downto 0);

        mgt_ctrl_arr(i).tx_reset      <= regs_write_arr(2*i)(3);
        mgt_ctrl_arr(i).tx_sync_reset <= regs_write_arr(2*i)(4);
        mgt_ctrl_arr(i).tx_pd         <= regs_write_arr(2*i)(6 downto 5);
        mgt_ctrl_arr(i).tx_polarity   <= regs_write_arr(2*i)(7);

        mgt_ctrl_arr(i).tx_conf_diff <= regs_write_arr(2*i)(11 downto 8);
        mgt_ctrl_arr(i).tx_post_emph <= regs_write_arr(2*i)(16 downto 12);
        mgt_ctrl_arr(i).tx_pre_emph  <= regs_write_arr(2*i)(20 downto 17);

        mgt_ctrl_arr(i).rx_reset      <= regs_write_arr(2*i)(18);
        mgt_ctrl_arr(i).rx_sync_reset <= regs_write_arr(2*i)(19);
        mgt_ctrl_arr(i).rx_pd         <= regs_write_arr(2*i)(21 downto 20);
        mgt_ctrl_arr(i).rx_polarity   <= regs_write_arr(2*i)(22);

        mgt_ctrl_arr(i).prbs_pattern          <= regs_write_arr(2*i)(25 downto 23);
        mgt_ctrl_arr(i).prbs_force_tx_err     <= regs_write_arr(2*i)(26);
        mgt_ctrl_arr(i).prbs_reset_rx_err_cnt <= regs_write_arr(2*i)(27);

        -- Connect write pulse signals

        -- Connect write done signals

        -- Connect read pulse signals

        -- Connect read ready signals

        -- Defaults
        regs_defaults(2*i) <= (others => '0');

        -- Define writable regs
        regs_writable_arr(2*i)   <= '1';
        regs_writable_arr(2*i+1) <= '0';

    end generate;

end gtx_regs_arch;
