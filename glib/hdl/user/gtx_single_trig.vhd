-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

use work.mgt_pkg.all;
use work.gem_pkg.all;

entity gtx_single_trig is
    port (
        -- Management --
        mgt_ctrl_i   : in t_gtx_ctrl;
        mgt_status_o : out t_gtx_status;

        -- MGT I/O --
        mgt_clk_i : in std_logic;

        mgt_rx_p_i : in std_logic;
        mgt_rx_n_i : in std_logic;

        -- Words --
        rx_wordclk_o  : out std_logic;
        mgt_rx_word_o : out t_gt_8b10b_rx_data
     );
end gtx_single_trig;

architecture structural of gtx_single_trig is

   --===============--
   -- Resets scheme --
   --===============--

   signal rxResetDone_from_gtx                       : std_logic;

   -- RX reset done synchronization registers:
   -------------------------------------------

   signal rxResetDone_r_from_gtxRxRstDoneSync1       : std_logic;
   signal rxResetDone_r2                             : std_logic;
   --------------------------------------------------
   signal rxResetDone_r3                             : std_logic;
   signal rxResetDone_r4_from_gtxRxRstDoneSync2      : std_logic;

   --==============================--
   -- MGT internal phase alignment --
   --==============================--

   -- RX synchronizer:
   -------------------

   signal rxEnPmaPhaseAlign_from_rxSync              : std_logic;
   signal rxPmaSetPhase_from_rxSync                  : std_logic;
   signal rxDlyAlignDisable_from_rxSync              : std_logic;
   signal rxDlyAlignOverride_from_rxSync             : std_logic;
   signal rxDlyAlignReset_from_rxSync                : std_logic;
   signal rxSyncDone_from_rxSync                     : std_logic;
   --------------------------------------------------
   signal reset_to_rxSync                            : std_logic;


   --============--
   -- Clocks     --
   --============--

   signal rx_wordclk_sig                         : std_logic;
   signal rx_wordclk_nobuff_sig                   : std_logic;

   --=====================================================================================--

begin

      --=============--
      -- Assignments --
      --=============--

      mgt_status_o.rx_reset_done     <= rxResetDone_r4_from_gtxRxRstDoneSync2;
      mgt_status_o.ready             <= rxSyncDone_from_rxSync;
      mgt_status_o.rx_mgt_ready      <= rxSyncDone_from_rxSync;
      mgt_status_o.rx_word_clk_ready <= rxResetDone_from_gtx;

      --================================================--
      -- Multi-Gigabit Transceivers (latency-optimized) --
      --================================================--

    i_gtx_trig_gtx: entity work.gtx_trig_gtx
    generic map (
        GTX_SIM_GTXRESET_SPEEDUP                 => 0)
    port map (
        ----------------------- Receive Ports - 8b10b Decoder ----------------------
        RXCHARISCOMMA_OUT               => mgt_rx_word_o.rxchariscomma(1 downto 0),
        RXCHARISK_OUT                   => mgt_rx_word_o.rxcharisk(1 downto 0),
        RXDISPERR_OUT                   => open,
        RXNOTINTABLE_OUT                => open,
        --------------- Receive Ports - Comma Detection and Alignment --------------
        RXBYTEISALIGNED_OUT             => open,
        RXBYTEREALIGN_OUT               => open,
        RXCOMMADET_OUT                  => open,
        ----------------------- Receive Ports - PRBS Detection ---------------------
        PRBSCNTRESET_IN                 => '0',
        RXENPRBSTST_IN                  => "000",
        RXPRBSERR_OUT                   => open,
        ------------------- Receive Ports - RX Data Path interface -----------------
        RXDATA_OUT                      => mgt_rx_word_o.rxdata(15 downto 0),
        RXRECCLK_OUT                    => rx_wordclk_nobuff_sig,
        RXRESET_IN                      => '0',
        RXUSRCLK2_IN                    => rx_wordclk_sig,
        ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        RXCDRRESET_IN                   => '0',
        RXEQMIX_IN                               => mgt_ctrl_i.rx_eq_mix,
        RXN_IN                                   => mgt_rx_n_i,
        RXP_IN                                   => mgt_rx_p_i,
        -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        RXDLYALIGNDISABLE_IN                     => rxDlyAlignDisable_from_rxSync,
        RXDLYALIGNMONENB_IN                      => '0',
        RXDLYALIGNMONITOR_OUT                    => open,
        RXDLYALIGNOVERRIDE_IN                    => rxDlyAlignOverride_from_rxSync,
        RXDLYALIGNRESET_IN                       => rxDlyAlignReset_from_rxSync,
        RXENPMAPHASEALIGN_IN                     => rxEnPmaPhaseAlign_from_rxSync,
        RXPMASETPHASE_IN                         => rxPmaSetPhase_from_rxSync,
        ------------------------ Receive Ports - RX PLL Ports ----------------------
        GTXRXRESET_IN                            => mgt_ctrl_i.rx_reset,
        MGTREFCLKRX_IN                           => ('0' & mgt_clk_i),
        PLLRXRESET_IN                            => '0',
        RXPLLLKDET_OUT                           => open,
        RXRESETDONE_OUT                          => rxResetDone_from_gtx,
        ----------------- Receive Ports - RX Polarity Control Ports ----------------
        RXPOLARITY_IN                            => mgt_ctrl_i.rx_polarity,
        ------------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        DADDR_IN             => x"00",
        DCLK_IN              => '0',
        DEN_IN               => '0',
        DI_IN                => x"0000",
        DRDY_OUT             => open,
        DRPDO_OUT            => open,
        DWE_IN               => '0',
        ---------------- Transmit Ports - TX Driver and OOB signaling --------------
        TXN_OUT           => open,
        TXP_OUT           => open
    );

    rxWordClkBufg: BUFG
    port map (
        O                                        => rx_wordclk_sig,
        I                                        => rx_wordclk_nobuff_sig
    );

    RX_WORDCLK_O <= rx_wordclk_sig;

      --==============--
      -- Reset scheme --
      --==============--

      -- RX reset done synchronization registers:
      -------------------------------------------

      gtxRxRstDoneSync1: process(rx_wordclk_sig)
      begin
         if rising_edge(rx_wordclk_sig) then
            rxResetDone_r_from_gtxRxRstDoneSync1  <= rxResetDone_from_gtx;
         end if;
      end process;

      gtxRxRstDoneSync2: process(rxResetDone_r_from_gtxRxRstDoneSync1, rx_wordclk_sig)
      begin
         if rxResetDone_r_from_gtxRxRstDoneSync1 = '0' then
            rxResetDone_r4_from_gtxRxRstDoneSync2 <= '0';
            rxResetDone_r3                        <= '0';
            rxResetDone_r2                        <= '0';
         elsif rising_edge(rx_wordclk_sig) then
            rxResetDone_r4_from_gtxRxRstDoneSync2 <= rxResetDone_r3;
            rxResetDone_r3                        <= rxResetDone_r2;
            rxResetDone_r2                        <= rxResetDone_r_from_gtxRxRstDoneSync1;
         end if;
      end process;

      --==============================--
      -- MGT internal phase alignment --
      --==============================--

      -- Comment: The internal clock domains of the GTX must be synchronized due to the elastic buffer bypassing.

      -- RX synchronizer:
      -------------------

      reset_to_rxSync                             <= (not rxResetDone_r4_from_gtxRxRstDoneSync2) or mgt_ctrl_i.rx_sync_reset;

    i_gtx_trig_tx_sync: entity work.gtx_trig_rx_sync
    port map (
        RXENPMAPHASEALIGN                        => rxEnPmaPhaseAlign_from_rxSync,
        RXPMASETPHASE                            => rxPmaSetPhase_from_rxSync,
        RXDLYALIGNDISABLE                        => rxDlyAlignDisable_from_rxSync,
        RXDLYALIGNOVERRIDE                       => rxDlyAlignOverride_from_rxSync,
        RXDLYALIGNRESET                          => rxDlyAlignReset_from_rxSync,
        SYNC_DONE                                => rxSyncDone_from_rxSync,
        USER_CLK                                 => rx_wordclk_sig,
        RESET                                    => reset_to_rxSync
    );

end structural;

