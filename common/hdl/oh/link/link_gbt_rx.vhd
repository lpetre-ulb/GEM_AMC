------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    02:35 2016-05-31
-- Module Name:    link_gbt_rx
-- Description:    this module provides GBT RX link decoding
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.gem_pkg.all;

entity link_gbt_rx is
port(

    ttc_clk_40_i            : in std_logic;   
    ttc_clk_80_i            : in std_logic;
    reset_i                 : in std_logic;
    
    req_en_o                : out std_logic;
    req_data_o              : out std_logic_vector(31 downto 0);

    evt_en_o                : out std_logic;
    evt_data_o              : out std_logic_vector(15 downto 0);
    
    tk_error_o              : out std_logic;
    evt_rcvd_o              : out std_logic;
    
    gbt_rx_data_i           : in std_logic_vector(83 downto 0);
    gbt_rx_ready_i          : in std_logic
    
);
end link_gbt_rx;

architecture link_gbt_rx_arch of link_gbt_rx is    

    component gbt_tk_data_fifo
        port(
            rst    : IN  STD_LOGIC;
            wr_clk : IN  STD_LOGIC;
            rd_clk : IN  STD_LOGIC;
            din    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en  : IN  STD_LOGIC;
            rd_en  : IN  STD_LOGIC;
            dout   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full   : OUT STD_LOGIC;
            empty  : OUT STD_LOGIC;
            valid  : OUT STD_LOGIC
        );
    end component;

    type state_t is (HEADER, TK_DATA, REG_DATA);
    
    signal state            : state_t;
    
    signal tk_counter       : integer range 0 to 13;
    signal tk_fifo_wr_en    : std_logic;
    signal tk_fifo_din      : std_logic_vector(31 downto 0);
        
    signal evt_valid        : std_logic;
    signal req_valid        : std_logic;
    
    signal oh_data          : std_logic_vector(31 downto 0);
    
begin  
    
    -- on OH v2b elinks 0, 16, 24, 32 are connected to the FPGA
    oh_data <= gbt_rx_data_i(71 downto 64) & gbt_rx_data_i(55 downto 48) & gbt_rx_data_i(39 downto 32) & gbt_rx_data_i(7 downto 0);
    
    --== STATE ==--

    process(ttc_clk_40_i)
    begin
        if (rising_edge(ttc_clk_40_i)) then
            if (reset_i = '1') then
                state <= HEADER;
                tk_counter <= 0;
            else
                case state is
                    when HEADER =>
                        if (oh_data(15 downto 0) = x"BCBC") then
                            state <= TK_DATA;
                        end if;
                        tk_counter <= 0;
                    when TK_DATA =>
                        if (tk_counter = 6) then
                            state <= REG_DATA;
                        else
                            tk_counter <= tk_counter + 1;
                        end if;
                    when REG_DATA => state <= HEADER;
                    when others => 
                        state <= HEADER;
                        tk_counter <= 0;
                end case;
            end if;
        end if;
    end process;
    
    --== ERROR ==--    
    
    process(ttc_clk_40_i)
    begin
        if (rising_edge(ttc_clk_40_i)) then
            if (reset_i = '1') then
                tk_error_o <= '0';
            else
                if (gbt_rx_ready_i = '0') then
                    tk_error_o <= '1';
                else
                    tk_error_o <= '0';
                end if;
            end if;
        end if;
    end process;
    
    --== REQUEST ==--
    
    process(ttc_clk_40_i)
    begin
        if (rising_edge(ttc_clk_40_i)) then
            if (reset_i = '1') then
                req_en_o <= '0';
                req_data_o <= (others => '0');
                req_valid <= '0';
            else
                case state is    
                    when HEADER => 
                        req_en_o <= '0';
                        req_valid <= oh_data(31);    
                    when REG_DATA => 
                        req_en_o <= req_valid;
                        req_data_o <= oh_data;
                    when others => req_en_o <= '0';
                end case;
            end if;
        end if;
    end process;   
    
    --== TRACKING DATA ==--
    
    process(ttc_clk_40_i)
    begin
        if (rising_edge(ttc_clk_40_i)) then
            if (reset_i = '1') then
                evt_rcvd_o <= '0';
                evt_valid <= '0';
            else
                case state is   
                    when HEADER => 
                        evt_rcvd_o <= oh_data(30);
                        evt_valid <= oh_data(30);
                    when TK_DATA =>                         
                        tk_fifo_wr_en <= evt_valid;
                        tk_fifo_din <= oh_data;
                        evt_rcvd_o <= '0';
                    when others => 
                        tk_fifo_wr_en <= '0';
                        evt_rcvd_o <= '0';
                        evt_valid <= '0';
                end case;
            end if;
        end if;
    end process;   
    
    i_gbt_tk_data_fifo : component gbt_tk_data_fifo
        port map(
            rst    => reset_i,
            wr_clk => ttc_clk_40_i,
            rd_clk => ttc_clk_80_i,
            din    => tk_fifo_din,
            wr_en  => tk_fifo_wr_en,
            rd_en  => '1',
            dout   => evt_data_o,
            full   => open,
            empty  => open,
            valid  => evt_en_o
        );
    
end link_gbt_rx_arch;
