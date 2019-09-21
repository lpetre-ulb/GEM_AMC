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
use work.mgt_pkg.all;

entity gtx_single_gbt is
    port (
        -- Management --
        mgt_ctrl_i   : in t_gtx_ctrl;
        mgt_status_o : out t_gtx_status;

        -- MGT I/O --
        mgt_clk_i : in std_logic;
     
        mgt_rx_p_i : in std_logic;
        mgt_rx_n_i : in std_logic;
        mgt_tx_p_o : out std_logic;
        mgt_tx_n_o : out std_logic;
     
        -- Clock --
        txusrclk_i : in std_logic;
     
        -- Words --
        tx_wordclk_o  : out std_logic;
        mgt_tx_word_i : in  std_logic_vector(WORD_WIDTH-1 downto 0);
     
        rx_wordclk_o  : out std_logic;
        mgt_rx_word_o : out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end gtx_single_gbt;

architecture structural of gtx_single_gbt is

   --===============--
   -- Resets scheme --
   --===============--

   signal txResetDone_from_gtx                       : std_logic;
   signal rxResetDone_from_gtx                       : std_logic;

   -- TX reset done synchronization registers:
   -------------------------------------------

   signal txResetDone_r                              : std_logic;
   signal txResetDone_r2_from_gtxTxRstDoneSync       : std_logic;

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

   -- TX synchronizer:
   -------------------

   signal txEnPmaPhaseAlign_from_txSync              : std_logic;
   signal txPmaSetPhase_from_txSync                  : std_logic;
   signal txDlyAlignDisable_from_txSync              : std_logic;
   signal txDlyAlignReset_from_txSync                : std_logic;
   signal txSyncDone_from_txSync                     : std_logic;
   --------------------------------------------------
   signal reset_to_txSync                            : std_logic;

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
   signal tx_wordclk_sig                         : std_logic;
   signal tx_wordclk_nobuff_sig                   : std_logic;
   signal rx_wordclk_sig                         : std_logic;
   signal rx_wordclk_nobuff_sig                   : std_logic;

   --=====================================================================================--

begin

      --=============--
      -- Assignments --
      --=============--

      mgt_status_o.tx_reset_done     <= txResetDone_r2_from_gtxTxRstDoneSync;
      mgt_status_o.rx_reset_done     <= rxResetDone_r4_from_gtxRxRstDoneSync2;
      mgt_status_o.ready             <= txSyncDone_from_txSync and rxSyncDone_from_rxSync;
      mgt_status_o.tx_mgt_ready      <= txSyncDone_from_txSync;
      mgt_status_o.rx_mgt_ready      <= rxSyncDone_from_rxSync;
      mgt_status_o.rx_word_clk_ready <= rxResetDone_from_gtx;

      --================================================--
      -- Multi-Gigabit Transceivers (latency-optimized) --
      --================================================--

      gtxLatOpt: entity work.xlx_v6_gtx_latopt
         generic map (
            GTX_SIM_GTXRESET_SPEEDUP                 => 0)
         port map (
            -----------------------------------------
            LOOPBACK_IN                              => mgt_ctrl_i.loopback,
            -----------------------------------------
            RXSLIDE_IN                               => '0',
            -----------------------------------------
            PRBSCNTRESET_IN                          => mgt_ctrl_i.prbs_reset_rx_err_cnt,
            RXENPRBSTST_IN                           => mgt_ctrl_i.prbs_pattern,
            RXPRBSERR_OUT                            => mgt_status_o.prbs_rx_err,
            -----------------------------------------
            RXDATA_OUT                               => mgt_rx_word_o,
            RXRECCLK_OUT                             => rx_wordclk_nobuff_sig,
            RXUSRCLK2_IN                             => rx_wordclk_sig,
            -----------------------------------------
            RXEQMIX_IN                               => mgt_ctrl_i.rx_eq_mix,
            RXN_IN                                   => mgt_rx_n_i,
            RXP_IN                                   => mgt_rx_p_i,
            -----------------------------------------
            RXDLYALIGNDISABLE_IN                     => rxDlyAlignDisable_from_rxSync,
            RXDLYALIGNMONENB_IN                      => '0',
            RXDLYALIGNMONITOR_OUT                    => open,
            RXDLYALIGNOVERRIDE_IN                    => rxDlyAlignOverride_from_rxSync,
            RXDLYALIGNRESET_IN                       => rxDlyAlignReset_from_rxSync,
            RXENPMAPHASEALIGN_IN                     => rxEnPmaPhaseAlign_from_rxSync,
            RXPMASETPHASE_IN                         => rxPmaSetPhase_from_rxSync,
            -----------------------------------------
            GTXRXRESET_IN                            => mgt_ctrl_i.rx_reset,
            MGTREFCLKRX_IN                           => ('0' & mgt_clk_i),
            PLLRXRESET_IN                            => '0',
            RXPLLLKDET_OUT                           => open,
            RXRESETDONE_OUT                          => rxResetDone_from_gtx,
            -----------------------------------------
            RXPOLARITY_IN                            => mgt_ctrl_i.rx_polarity,
            -----------------------------------------
            DADDR_IN                                 => (others => '0'),
            DCLK_IN                                  => '0',
            DEN_IN                                   => '0',
            DI_IN                                    => (others => '0'),
            DRDY_OUT                                 => open,
            DRPDO_OUT                                => open,
            DWE_IN                                   => '0',
            -----------------------------------------
            TXDATA_IN                                => mgt_tx_word_i,
            TXOUTCLK_OUT                             => tx_wordclk_nobuff_sig,
            TXUSRCLK2_IN                             => tx_wordclk_sig,
            -----------------------------------------
            TXDIFFCTRL_IN                            => mgt_ctrl_i.tx_conf_diff,
            TXN_OUT                                  => mgt_tx_n_o,
            TXP_OUT                                  => mgt_tx_p_o,
            TXPOSTEMPHASIS_IN                        => mgt_ctrl_i.tx_post_emph,
            -----------------------------------------
            TXPREEMPHASIS_IN                         => mgt_ctrl_i.tx_pre_emph,
            -----------------------------------------
            TXDLYALIGNDISABLE_IN                     => txDlyAlignDisable_from_txSync,
            TXDLYALIGNMONENB_IN                      => '0',
            TXDLYALIGNMONITOR_OUT                    => open,
            TXDLYALIGNRESET_IN                       => txDlyAlignReset_from_txSync,
            TXENPMAPHASEALIGN_IN                     => txEnPmaPhaseAlign_from_txSync,
            TXPMASETPHASE_IN                         => txPmaSetPhase_from_txSync,
            -----------------------------------------
            GTXTXRESET_IN                            => mgt_ctrl_i.tx_reset,
            MGTREFCLKTX_IN                           => ('0' & mgt_clk_i),
            PLLTXRESET_IN                            => '0',
            TXPLLLKDET_OUT                           => open,
            TXRESETDONE_OUT                          => txResetDone_from_gtx,
            -----------------------------------------
            TXENPRBSTST_IN                           => mgt_ctrl_i.prbs_pattern,
            TXPRBSFORCEERR_IN                        => mgt_ctrl_i.prbs_force_tx_err,
            -----------------------------------------
            TXPOLARITY_IN                            => mgt_ctrl_i.tx_polarity
         );

        rxWordClkBufg: BUFG
            port map (
                  O                                        => rx_wordclk_sig,
                  I                                        => rx_wordclk_nobuff_sig
            );

         tx_wordclk_sig <= txusrclk_i;

         tx_wordclk_o <= tx_wordclk_sig;
         rx_wordclk_o <= rx_wordclk_sig;

      --==============--
      -- Reset scheme --
      --==============--

      -- TX reset done synchronization registers:
      -------------------------------------------

      gtxTxRstDoneSync: process(txResetDone_from_gtx, tx_wordclk_sig)
      begin
         if txResetDone_from_gtx = '0' then
            txResetDone_r2_from_gtxTxRstDoneSync  <= '0';
            txResetDone_r                         <= '0';
         elsif rising_edge(tx_wordclk_sig) then
            txResetDone_r2_from_gtxTxRstDoneSync  <= txResetDone_r;
            txResetDone_r                         <= txResetDone_from_gtx;
         end if;
      end process;

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

      -- TX synchronizer:
      -------------------

      reset_to_txSync                             <= (not txResetDone_r2_from_gtxTxRstDoneSync) or mgt_ctrl_i.tx_sync_reset;

      txSync: entity work.xlx_v6_gtx_latopt_tx_sync
         generic map (
            SIM_TXPMASETPHASE_SPEEDUP                => 0)
         port map (
            TXENPMAPHASEALIGN                        => txEnPmaPhaseAlign_from_txSync,
            TXPMASETPHASE                            => txPmaSetPhase_from_txSync,
            TXDLYALIGNDISABLE                        => txDlyAlignDisable_from_txSync,
            TXDLYALIGNRESET                          => txDlyAlignReset_from_txSync,
            SYNC_DONE                                => txSyncDone_from_txSync,
            USER_CLK                                 => tx_wordclk_sig,
            RESET                                    => reset_to_txSync
         );

      -- RX synchronizer:
      -------------------

      reset_to_rxSync                             <= (not rxResetDone_r4_from_gtxRxRstDoneSync2) or mgt_ctrl_i.rx_sync_reset;

      rxSync: entity work.xlx_v6_gtx_latopt_rx_sync
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
