-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;
use work.gbt_banks_user_setup.all;

-- GEM packages
use work.gem_pkg.all;
use work.mgt_pkg.all;

entity gtx_bank_trig is
    generic (
        g_NUM_GTX : integer := 4
    );
    port (
        -- Management --
        mgt_ctrl_arr_i   : in t_gtx_ctrl_arr(0 to g_NUM_GTX-1);
        mgt_status_arr_o : out t_gtx_status_arr(0 to g_NUM_GTX-1);

        -- MGT I/O
        mgt_clk_p_i : in std_logic;
        mgt_clk_n_i : in std_logic;

        mgt_rx_arr_i : in t_mgt_rx_serial_arr(0 to g_NUM_GTX-1);

        -- Words --
        rx_word_clk_arr_o : out std_logic_vector(0 to g_NUM_GTX-1);
        mgt_rx_word_arr_o : out t_gt_8b10b_rx_data_arr(0 to g_NUM_GTX-1)
    );
end gtx_bank_trig;

architecture structural of gtx_bank_trig is

    signal mgt_clk : std_logic;

begin

    i_ibufds_gtxe1 : ibufds_gtxe1
    port map(
        o       => mgt_clk,
        odiv2   => open,
        ceb     => '0',
        i       => mgt_clk_p_i,
        ib      => mgt_clk_n_i
    );

    g_gtx_single_trig : for i in 0 to g_NUM_GTX-1 generate

        i_gtx_single_trig : entity work.gtx_single_trig
        port map(
            -- Management
            mgt_ctrl_i   => mgt_ctrl_arr_i(i),
            mgt_status_o => mgt_status_arr_o(i),

            -- MGT I/O
            mgt_clk_i => mgt_clk,

            mgt_rx_p_i => mgt_rx_arr_i(i).rxp,
            mgt_rx_n_i => mgt_rx_arr_i(i).rxn,

            -- Words
            rx_wordclk_o  => rx_word_clk_arr_o(i),
            mgt_rx_word_o => mgt_rx_word_arr_o(i)
        );

    end generate;

end structural;
