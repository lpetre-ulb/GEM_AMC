------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    23:40 2016-12-18
-- Module Name:    oneshot
-- Description:    given an input signal, the output is asserted high for one clock cycle when input goes from low to high.
--                 Even if the input signal stays high for longe that one clock cycle, the output is only asserted high for one cycle.
--                 Both input and output signals are on the same clock domain. Use oneshot_cross_domain if you need them to be on separate domains.
------------------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity oneshot_cross_domain is
    port(
        reset_i         : in  std_logic;
        input_clk_i     : in  std_logic;
        oneshot_clk_i   : in  std_logic;
        input_i         : in  std_logic;
        oneshot_o       : out std_logic
    );
end oneshot_cross_domain;

architecture oneshot_cross_domain_arch of oneshot_cross_domain is
    
    signal last_input       : std_logic;
    signal oneshot_req      : std_logic;
    signal oneshot_req_last : std_logic;
    signal oneshot_ack      : std_logic;
        
begin

    process (input_clk_i) is
    begin
        if rising_edge(input_clk_i) then
            if reset_i = '1' then
                last_input <= '0';
                oneshot_req <= '0';
            else
                last_input <= input_i;
                
                if (oneshot_req = '0') then
                    if ((last_input = '0') and (input_i = '1')) then
                        oneshot_req <= '1';
                    else
                        oneshot_req <= '0';
                    end if;
                elsif (oneshot_ack = '1') then
                    oneshot_req <= '0';
                else
                    oneshot_req <= '1';
                end if;
            end if;
        end if;
    end process;
    
    process (oneshot_clk_i)
    begin
        if (rising_edge(oneshot_clk_i)) then
            if (reset_i = '1') then
                oneshot_o <= '0';
                oneshot_ack <= '0';
                oneshot_req_last <= '0';
            else
                oneshot_req_last <= oneshot_req;

                if ((oneshot_req_last = '0') and (oneshot_req = '1')) then
                    oneshot_o <= '1';
                else
                    oneshot_o <= '0';
                end if;
                
                if (oneshot_req = '1') then
                    oneshot_ack <= '1';
                else
                    oneshot_ack <= '0';
                end if;
            end if;
        end if;
    end process;
    
end oneshot_cross_domain_arch;
