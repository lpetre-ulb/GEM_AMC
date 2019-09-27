library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity config_blaster_bram is
    generic(
        MEMORY_WORDS : integer := 64
    );
    port(
        -- R/W port A
        clka  : in  std_logic;
        wea   : in  std_logic_vector(0 downto 0);
        addra : in  std_logic_vector(15 downto 0);
        dina  : in  std_logic_vector(31 downto 0);
        douta : out std_logic_vector(31 downto 0);
        -- R/O port B
        clkb  : in  std_logic;
        addrb : in  std_logic_vector(15 downto 0);
        doutb : out std_logic_vector(31 downto 0)
    );
end entity;

architecture infer of config_blaster_bram is

    type ram_type is array (MEMORY_WORDS-1 downto 0) of std_logic_vector (31 downto 0);
    signal RAM: ram_type;

    signal douta_reg, doutb_reg : std_logic_vector(31 downto 0);

begin

    process (clka)
    begin
        if rising_edge(clka) then
            if wea(0) = '1' then
                RAM(to_integer(unsigned(addra))) <= dina;
            else
                douta_reg <= RAM(to_integer(unsigned(addra)));
            end if;

            douta <= douta_reg;
        end if;
    end process;

    process (clkb)
    begin
        if rising_edge(clkb) then
            doutb_reg <= RAM(to_integer(unsigned(addrb)));
            doutb     <= doutb_reg;
        end if;
    end process;

end architecture;
