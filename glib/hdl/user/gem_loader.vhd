library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gem_loader is
    port (
        clk_i : in std_logic;
        en_i  : in std_logic;

        sram_rdata_i : in  std_logic_vector(31 downto 0);
        sram_addr_o  : out std_logic_vector(20 downto 0);
        sram_cs_o    : out std_logic;

        ready_o : out std_logic;
        data_o  : out std_logic_vector(7 downto 0);
        valid_o : out std_logic;
        first_o : out std_logic;
        last_o  : out std_logic;
        error_o : out std_logic
    );
end gem_loader;

architecture behavioral of gem_loader is

    -- GEM loader
    signal data    : std_logic_vector(7 downto 0);
    signal valid   : std_logic;
    signal valid_d : std_logic;
    signal last    : std_logic;
    signal error   : std_logic;

    -- SRAM
    signal addr  : unsigned(20 downto 0);
    signal rdata : std_logic_vector(31 downto 0);

    -- FSM
    type t_state is (IDLE, SENDING);
    signal state : t_state := IDLE;

    signal strobe_sr  : std_logic_vector(3 downto 0);

    constant LATENCY   : unsigned(2 downto 0) := "101";
    signal latency_cnt : unsigned(2 downto 0);

    constant BITSTREAM_SIZE : unsigned(23 downto 0) := x"53638c";
    signal octet_cnt        : unsigned(23 downto 0);

    signal data_latch : std_logic_vector(31 downto 0);

begin

    -- GEM loader
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            valid_d <= valid;
        end if;
    end process;

    ready_o <= '1';
    data_o  <= data;
    valid_o <= valid;
    first_o <= valid and not valid_d;
    last_o  <= last;
    error_o <= error;

    -- SRAM
--   sram_cs_o   <= strobe_sr(0);
    sram_addr_o <= std_logic_vector(addr);
    rdata       <= sram_rdata_i;

    -- Read FSM
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if state = IDLE then
                -- GEM loader
                data <= x"00";
                valid <= '0';
                last  <= '0';
                error <= '0';

                -- SRAM
                addr <= (others => '0');

sram_cs_o <= '0';

                -- State
                strobe_sr   <= "1000";
                latency_cnt <= "000";
                octet_cnt   <= (others => '0');

                if en_i = '1' then
                    state <= SENDING;
                else
                    state <= IDLE;
                end if;
            else
       sram_cs_o <= '1';
                -- Ask for a new word every 4 clock cycle
                strobe_sr <= strobe_sr(2 downto 0) & strobe_sr(3);

                -- Increase the address after each strobe
                if strobe_sr(1) = '1' then
                    addr <= addr + 1;
                end if;

                -- Wait latency clock cycles before reading
                if latency_cnt = LATENCY then
                    latency_cnt <= latency_cnt;
                else
                    latency_cnt <= latency_cnt + 1;
                end if;

                -- Read 1 word after 1 cycle after strobe once the latency is passed
                -- Split the word in octets
                if latency_cnt = LATENCY then
                    valid <= '1';

                    case strobe_sr is
                        when "0001" =>
                                data_latch <= rdata;
                                data       <= rdata(31 downto 24);
                        when "0010" =>
                                data <= data_latch(23 downto 16);
                        when "0100" =>
                                data <= data_latch(15 downto 8);
                        when "1000" =>
                                data <= data_latch(7 downto 0);
                        when others =>
                                error <= '1';
                                state <= IDLE;
                    end case;
                end if;

                -- Count the number of octets sent
                if latency_cnt = LATENCY then
                    octet_cnt <= octet_cnt + 1;

                    -- The last octet is emitted
                    if octet_cnt = BITSTREAM_SIZE - 1 then
                        state <= IDLE;
                        last  <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;


end Behavioral;

