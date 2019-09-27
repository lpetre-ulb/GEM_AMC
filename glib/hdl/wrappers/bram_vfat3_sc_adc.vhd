library ieee;
use ieee.std_logic_1164.all;

entity bram_vfat3_sc_adc is
    port(
        clka  : in std_logic;
        ena   : in std_logic;
        wea   : in std_logic;
        addra : in std_logic_vector(9 downto 0);
        dina  : in std_logic_vector(9 downto 0);
        douta : out std_logic_vector(9 downto 0)
    );
end entity;

architecture wrapper of bram_vfat3_sc_adc is

begin

    i_bram_vfat3_sc_adc_glib : entity work.bram_vfat3_sc_adc_glib
        port map (
            clka   => clka,
            ena    => ena,
            wea(0) => wea,
            addra  => addra,
            dina   => dina,
            douta  => douta
        );

end architecture;
