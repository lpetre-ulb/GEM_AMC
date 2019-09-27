library ieee;
use ieee.std_logic_1164.all;

entity vfat3_sc_tx_fifo is
    port(
        clk   : in std_logic;
        srst  : in std_logic;
        din   : in std_logic;
        wr_en : in std_logic;
        rd_en : in std_logic;
        dout  : out std_logic;
        full  : out std_logic;
        empty : out std_logic
    );
end entity;

architecture wrapper of vfat3_sc_tx_fifo is

begin

    i_vfat3_sc_tx_fifo_glib : entity work.vfat3_sc_tx_fifo_glib
        port map (
            clk     => clk,
            srst    => srst,
            din(0)  => din,
            wr_en   => wr_en,
            rd_en   => rd_en,
            dout(0) => dout,
            full    => full,
            empty   => empty
        );

end architecture;
