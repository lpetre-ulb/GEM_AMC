----------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date: 12/13/2016 14:27:30
-- Module Name: CLK_PHASE_CHECK_V7
-- Project Name: GEM_AMC
-- Description: This module is a tool to inspect clock phase alignment of two clocks of the same frequency, using ILA.
--              It samples both clocks with a third clock that is phase shifted in steps of ~19ps and records the results in ILA.
--              Note that this module is using Virtex7 primitives, so it won't work on Virtex6
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

entity clk_phase_check_v7 is
    generic (
        FREQ_MHZ     : real := 40.000 -- please give a round number e.g. even if the TTC clock is not exactly 40MHz, you should still specify 40.000 here 
    );
    port (
        reset       : in  std_logic;
        clk1        : in  std_logic;
        clk2        : in  std_logic
    );

end clk_phase_check_v7;

architecture Behavioral of clk_phase_check_v7 is

    -------------- ILA --------------
    component ila_clk_phase_check
        port (
            clk : IN STD_LOGIC;
            probe0 : IN STD_LOGIC; 
            probe1 : IN STD_LOGIC;
            probe2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    end component;

    ---------------- SIGNALS -----------------
    constant VCO_FREQ           : real := 960.000;
    constant SAMPLE_TIMEOUT     : unsigned(3 downto 0) := x"a"; -- sample 10 clock cycles for each phase
    type t_state is (WAIT_SAMPLE, SHIFT_PHASE, WAIT_SHIFT_DONE);
        
    signal clkfb                : std_logic;
    signal sampling_clk         : std_logic;
    signal sampling_clk_bufg    : std_logic;
    
    signal mmcm_ps_clk          : std_logic;
    signal mmcm_ps_en           : std_logic := '0';
    signal mmcm_ps_done         : std_logic;
    signal mmcm_locked          : std_logic;    

    signal state                : t_state := WAIT_SAMPLE;
    signal sample_timer         : unsigned(3 downto 0) := (others => '0');

begin

    mmcm_ps_clk <= clk1;

    mmcm_adv_inst : MMCME2_ADV
        generic map(
            BANDWIDTH            => "OPTIMIZED",
            CLKOUT4_CASCADE      => false,
            COMPENSATION         => "ZHOLD",
            STARTUP_WAIT         => false,
            DIVCLK_DIVIDE        => 1,
            CLKFBOUT_MULT_F      => VCO_FREQ / FREQ_MHZ,
            CLKFBOUT_PHASE       => 0.000,
            CLKFBOUT_USE_FINE_PS => true,
            CLKOUT0_DIVIDE_F     => VCO_FREQ / FREQ_MHZ,
            CLKOUT0_PHASE        => 0.000,
            CLKOUT0_DUTY_CYCLE   => 0.500,
            CLKOUT0_USE_FINE_PS  => false,
            CLKOUT1_DIVIDE       => integer(VCO_FREQ / FREQ_MHZ),
            CLKOUT1_PHASE        => 0.000,
            CLKOUT1_DUTY_CYCLE   => 0.500,
            CLKOUT1_USE_FINE_PS  => false,
            CLKOUT2_DIVIDE       => integer(VCO_FREQ / FREQ_MHZ),
            CLKOUT2_PHASE        => 0.000,
            CLKOUT2_DUTY_CYCLE   => 0.500,
            CLKOUT2_USE_FINE_PS  => false,
            CLKOUT3_DIVIDE       => integer(VCO_FREQ / FREQ_MHZ),
            CLKOUT3_PHASE        => 0.000,
            CLKOUT3_DUTY_CYCLE   => 0.500,
            CLKOUT3_USE_FINE_PS  => false,
            CLKOUT4_DIVIDE       => integer(VCO_FREQ / FREQ_MHZ),
            CLKOUT4_PHASE        => 0.000,
            CLKOUT4_DUTY_CYCLE   => 0.500,
            CLKOUT4_USE_FINE_PS  => false,
            CLKIN1_PERIOD        => 1000.000 / FREQ_MHZ,
            REF_JITTER1          => 0.010)
        port map(
            -- Output clocks
            CLKFBOUT     => clkfb,
            CLKFBOUTB    => open,
            CLKOUT0      => sampling_clk,
            CLKOUT0B     => open,
            CLKOUT1      => open,
            CLKOUT1B     => open,
            CLKOUT2      => open,
            CLKOUT2B     => open,
            CLKOUT3      => open,
            CLKOUT3B     => open,
            CLKOUT4      => open,
            CLKOUT5      => open,
            CLKOUT6      => open,
            -- Input clock control
            CLKFBIN      => clkfb,
            CLKIN1       => clk1,
            CLKIN2       => '0',
            -- Tied to always select the primary input clock
            CLKINSEL     => '1',

            -- Ports for dynamic reconfiguration
            DADDR        => (others => '0'),
            DCLK         => '0',
            DEN          => '0',
            DI           => (others => '0'),
            DO           => open,
            DRDY         => open,
            DWE          => '0',
            -- Ports for dynamic phase shift
            PSCLK        => mmcm_ps_clk,
            PSEN         => mmcm_ps_en,
            PSINCDEC     => '1',
            PSDONE       => mmcm_ps_done,
            -- Other control and status signals
            LOCKED       => mmcm_locked,
            CLKINSTOPPED => open,
            CLKFBSTOPPED => open,
            PWRDWN       => '0',
            RST          => reset
        );

    i_bufg_clk_40 : BUFG
        port map(
            O => sampling_clk_bufg,
            I => sampling_clk
        );
        
    process(clk1)
    begin
        if (rising_edge(clk1)) then
            if ((reset = '1') or (mmcm_locked = '0')) then
                state <= WAIT_SAMPLE;
                mmcm_ps_en <= '0';
                sample_timer <= (others => '0');
            else
                case state is
                    when WAIT_SAMPLE =>
                        mmcm_ps_en <= '0';    
                        if (sample_timer = SAMPLE_TIMEOUT) then
                            state <= SHIFT_PHASE;
                            sample_timer <= (others => '0');
                        else
                            state <= WAIT_SAMPLE;
                            sample_timer <= sample_timer + 1;
                        end if;
                        
                    when SHIFT_PHASE =>
                        mmcm_ps_en <= '1';
                        state <= WAIT_SHIFT_DONE;
                        sample_timer <= (others => '0');
                        
                    when WAIT_SHIFT_DONE =>
                        mmcm_ps_en <= '0';
                        sample_timer <= (others => '0');
                        if (mmcm_ps_done = '1') then
                            state <= WAIT_SAMPLE;
                        else
                            state <= WAIT_SHIFT_DONE;
                        end if;

                    when others =>
                        state <= WAIT_SAMPLE;
                        sample_timer <= (others => '0');
                        mmcm_ps_en <= '0';
                        
                end case;
            end if;
        end if;
    end process;

    i_ila : component ila_clk_phase_check
        port map(
            clk    => sampling_clk_bufg,
            probe0 => clk1,
            probe1 => clk2,
            probe2 => std_logic_vector(to_unsigned(t_state'pos(state), 2))
        );

end Behavioral;
