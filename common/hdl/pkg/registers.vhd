library IEEE;
use IEEE.STD_LOGIC_1164.all;

-----> !! This package is auto-generated from an address table file using <repo_root>/scripts/generate_registers.py !! <-----
package registers is

    --============================================================================
    --       >>> TTC Module <<<    base address: 0x00300000
    --
    -- TTC control and monitoring. It takes care of locking to the TTC clock
    -- coming from the                        backplane as well as decoding TTC
    -- commands and forwarding that to all other modules in
    -- the design. It also provides several control and monitoring registers
    -- (resets, command                        decoding configuration, clock and
    -- data status, bc0 status, command counters and a small spy buffer)
    --============================================================================

    constant REG_TTC_NUM_REGS : integer := 34;
    constant REG_TTC_ADDRESS_MSB : integer := 5;
    constant REG_TTC_ADDRESS_LSB : integer := 0;
    constant REG_TTC_CTRL_MODULE_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"0";
    constant REG_TTC_CTRL_MODULE_RESET_MSB    : integer := 31;
    constant REG_TTC_CTRL_MODULE_RESET_LSB     : integer := 0;

    constant REG_TTC_CTRL_MMCM_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"1";
    constant REG_TTC_CTRL_MMCM_RESET_MSB    : integer := 31;
    constant REG_TTC_CTRL_MMCM_RESET_LSB     : integer := 0;

    constant REG_TTC_CTRL_CNT_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"2";
    constant REG_TTC_CTRL_CNT_RESET_MSB    : integer := 31;
    constant REG_TTC_CTRL_CNT_RESET_LSB     : integer := 0;

    constant REG_TTC_CTRL_MMCM_PHASE_SHIFT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"3";
    constant REG_TTC_CTRL_MMCM_PHASE_SHIFT_MSB    : integer := 31;
    constant REG_TTC_CTRL_MMCM_PHASE_SHIFT_LSB     : integer := 0;

    constant REG_TTC_CTRL_L1A_ENABLE_ADDR    : std_logic_vector(5 downto 0) := "00" & x"4";
    constant REG_TTC_CTRL_L1A_ENABLE_BIT    : integer := 0;
    constant REG_TTC_CTRL_L1A_ENABLE_DEFAULT : std_logic := '1';

    constant REG_TTC_CONFIG_CMD_BC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_BC0_MSB    : integer := 7;
    constant REG_TTC_CONFIG_CMD_BC0_LSB     : integer := 0;
    constant REG_TTC_CONFIG_CMD_BC0_DEFAULT : std_logic_vector(7 downto 0) := x"01";

    constant REG_TTC_CONFIG_CMD_EC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_EC0_MSB    : integer := 15;
    constant REG_TTC_CONFIG_CMD_EC0_LSB     : integer := 8;
    constant REG_TTC_CONFIG_CMD_EC0_DEFAULT : std_logic_vector(15 downto 8) := x"02";

    constant REG_TTC_CONFIG_CMD_RESYNC_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_RESYNC_MSB    : integer := 23;
    constant REG_TTC_CONFIG_CMD_RESYNC_LSB     : integer := 16;
    constant REG_TTC_CONFIG_CMD_RESYNC_DEFAULT : std_logic_vector(23 downto 16) := x"04";

    constant REG_TTC_CONFIG_CMD_OC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_OC0_MSB    : integer := 31;
    constant REG_TTC_CONFIG_CMD_OC0_LSB     : integer := 24;
    constant REG_TTC_CONFIG_CMD_OC0_DEFAULT : std_logic_vector(31 downto 24) := x"08";

    constant REG_TTC_CONFIG_CMD_HARD_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_HARD_RESET_MSB    : integer := 7;
    constant REG_TTC_CONFIG_CMD_HARD_RESET_LSB     : integer := 0;
    constant REG_TTC_CONFIG_CMD_HARD_RESET_DEFAULT : std_logic_vector(7 downto 0) := x"10";

    constant REG_TTC_CONFIG_CMD_CALPULSE_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_CALPULSE_MSB    : integer := 15;
    constant REG_TTC_CONFIG_CMD_CALPULSE_LSB     : integer := 8;
    constant REG_TTC_CONFIG_CMD_CALPULSE_DEFAULT : std_logic_vector(15 downto 8) := x"14";

    constant REG_TTC_CONFIG_CMD_START_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_START_MSB    : integer := 23;
    constant REG_TTC_CONFIG_CMD_START_LSB     : integer := 16;
    constant REG_TTC_CONFIG_CMD_START_DEFAULT : std_logic_vector(23 downto 16) := x"18";

    constant REG_TTC_CONFIG_CMD_STOP_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_STOP_MSB    : integer := 31;
    constant REG_TTC_CONFIG_CMD_STOP_LSB     : integer := 24;
    constant REG_TTC_CONFIG_CMD_STOP_DEFAULT : std_logic_vector(31 downto 24) := x"1c";

    constant REG_TTC_CONFIG_CMD_TEST_SYNC_ADDR    : std_logic_vector(5 downto 0) := "00" & x"7";
    constant REG_TTC_CONFIG_CMD_TEST_SYNC_MSB    : integer := 7;
    constant REG_TTC_CONFIG_CMD_TEST_SYNC_LSB     : integer := 0;
    constant REG_TTC_CONFIG_CMD_TEST_SYNC_DEFAULT : std_logic_vector(7 downto 0) := x"20";

    constant REG_TTC_STATUS_MMCM_LOCKED_ADDR    : std_logic_vector(5 downto 0) := "00" & x"8";
    constant REG_TTC_STATUS_MMCM_LOCKED_BIT    : integer := 0;

    constant REG_TTC_STATUS_MMCM_UNLOCK_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"8";
    constant REG_TTC_STATUS_MMCM_UNLOCK_CNT_MSB    : integer := 31;
    constant REG_TTC_STATUS_MMCM_UNLOCK_CNT_LSB     : integer := 16;

    constant REG_TTC_STATUS_TTC_SINGLE_ERROR_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"9";
    constant REG_TTC_STATUS_TTC_SINGLE_ERROR_CNT_MSB    : integer := 15;
    constant REG_TTC_STATUS_TTC_SINGLE_ERROR_CNT_LSB     : integer := 0;

    constant REG_TTC_STATUS_TTC_DOUBLE_ERROR_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"9";
    constant REG_TTC_STATUS_TTC_DOUBLE_ERROR_CNT_MSB    : integer := 31;
    constant REG_TTC_STATUS_TTC_DOUBLE_ERROR_CNT_LSB     : integer := 16;

    constant REG_TTC_STATUS_BC0_LOCKED_ADDR    : std_logic_vector(5 downto 0) := "00" & x"a";
    constant REG_TTC_STATUS_BC0_LOCKED_BIT    : integer := 0;

    constant REG_TTC_STATUS_BC0_UNLOCK_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"b";
    constant REG_TTC_STATUS_BC0_UNLOCK_CNT_MSB    : integer := 15;
    constant REG_TTC_STATUS_BC0_UNLOCK_CNT_LSB     : integer := 0;

    constant REG_TTC_STATUS_BC0_OVERFLOW_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"c";
    constant REG_TTC_STATUS_BC0_OVERFLOW_CNT_MSB    : integer := 15;
    constant REG_TTC_STATUS_BC0_OVERFLOW_CNT_LSB     : integer := 0;

    constant REG_TTC_STATUS_BC0_UNDERFLOW_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"c";
    constant REG_TTC_STATUS_BC0_UNDERFLOW_CNT_MSB    : integer := 31;
    constant REG_TTC_STATUS_BC0_UNDERFLOW_CNT_LSB     : integer := 16;

    constant REG_TTC_CMD_COUNTERS_L1A_ADDR    : std_logic_vector(5 downto 0) := "00" & x"d";
    constant REG_TTC_CMD_COUNTERS_L1A_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_L1A_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_BC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"e";
    constant REG_TTC_CMD_COUNTERS_BC0_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_BC0_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_EC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"f";
    constant REG_TTC_CMD_COUNTERS_EC0_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_EC0_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_RESYNC_ADDR    : std_logic_vector(5 downto 0) := "01" & x"0";
    constant REG_TTC_CMD_COUNTERS_RESYNC_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_RESYNC_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_OC0_ADDR    : std_logic_vector(5 downto 0) := "01" & x"1";
    constant REG_TTC_CMD_COUNTERS_OC0_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_OC0_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_HARD_RESET_ADDR    : std_logic_vector(5 downto 0) := "01" & x"2";
    constant REG_TTC_CMD_COUNTERS_HARD_RESET_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_HARD_RESET_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_CALPULSE_ADDR    : std_logic_vector(5 downto 0) := "01" & x"3";
    constant REG_TTC_CMD_COUNTERS_CALPULSE_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_CALPULSE_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_START_ADDR    : std_logic_vector(5 downto 0) := "01" & x"4";
    constant REG_TTC_CMD_COUNTERS_START_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_START_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_STOP_ADDR    : std_logic_vector(5 downto 0) := "01" & x"5";
    constant REG_TTC_CMD_COUNTERS_STOP_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_STOP_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_TEST_SYNC_ADDR    : std_logic_vector(5 downto 0) := "01" & x"6";
    constant REG_TTC_CMD_COUNTERS_TEST_SYNC_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_TEST_SYNC_LSB     : integer := 0;

    constant REG_TTC_L1A_ID_ADDR    : std_logic_vector(5 downto 0) := "01" & x"7";
    constant REG_TTC_L1A_ID_MSB    : integer := 23;
    constant REG_TTC_L1A_ID_LSB     : integer := 0;

    constant REG_TTC_L1A_RATE_ADDR    : std_logic_vector(5 downto 0) := "01" & x"8";
    constant REG_TTC_L1A_RATE_MSB    : integer := 31;
    constant REG_TTC_L1A_RATE_LSB     : integer := 0;

    constant REG_TTC_TTC_SPY_BUFFER_ADDR    : std_logic_vector(5 downto 0) := "01" & x"9";
    constant REG_TTC_TTC_SPY_BUFFER_MSB    : integer := 31;
    constant REG_TTC_TTC_SPY_BUFFER_LSB     : integer := 0;

    constant REG_TTC_GENERATOR_RESET_ADDR    : std_logic_vector(5 downto 0) := "10" & x"0";
    constant REG_TTC_GENERATOR_RESET_MSB    : integer := 31;
    constant REG_TTC_GENERATOR_RESET_LSB     : integer := 0;

    constant REG_TTC_GENERATOR_ENABLE_ADDR    : std_logic_vector(5 downto 0) := "10" & x"1";
    constant REG_TTC_GENERATOR_ENABLE_BIT    : integer := 0;
    constant REG_TTC_GENERATOR_ENABLE_DEFAULT : std_logic := '0';

    constant REG_TTC_GENERATOR_CYCLIC_RUNNING_ADDR    : std_logic_vector(5 downto 0) := "10" & x"1";
    constant REG_TTC_GENERATOR_CYCLIC_RUNNING_BIT    : integer := 1;

    constant REG_TTC_GENERATOR_ENABLE_CALPULSE_ONLY_ADDR    : std_logic_vector(5 downto 0) := "10" & x"1";
    constant REG_TTC_GENERATOR_ENABLE_CALPULSE_ONLY_BIT    : integer := 2;
    constant REG_TTC_GENERATOR_ENABLE_CALPULSE_ONLY_DEFAULT : std_logic := '0';

    constant REG_TTC_GENERATOR_CYCLIC_L1A_GAP_ADDR    : std_logic_vector(5 downto 0) := "10" & x"1";
    constant REG_TTC_GENERATOR_CYCLIC_L1A_GAP_MSB    : integer := 19;
    constant REG_TTC_GENERATOR_CYCLIC_L1A_GAP_LSB     : integer := 4;
    constant REG_TTC_GENERATOR_CYCLIC_L1A_GAP_DEFAULT : std_logic_vector(19 downto 4) := x"0190";

    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_TO_L1A_GAP_ADDR    : std_logic_vector(5 downto 0) := "10" & x"1";
    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_TO_L1A_GAP_MSB    : integer := 31;
    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_TO_L1A_GAP_LSB     : integer := 20;
    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_TO_L1A_GAP_DEFAULT : std_logic_vector(31 downto 20) := x"000";

    constant REG_TTC_GENERATOR_SINGLE_HARD_RESET_ADDR    : std_logic_vector(5 downto 0) := "10" & x"2";
    constant REG_TTC_GENERATOR_SINGLE_HARD_RESET_MSB    : integer := 31;
    constant REG_TTC_GENERATOR_SINGLE_HARD_RESET_LSB     : integer := 0;

    constant REG_TTC_GENERATOR_SINGLE_RESYNC_ADDR    : std_logic_vector(5 downto 0) := "10" & x"3";
    constant REG_TTC_GENERATOR_SINGLE_RESYNC_MSB    : integer := 31;
    constant REG_TTC_GENERATOR_SINGLE_RESYNC_LSB     : integer := 0;

    constant REG_TTC_GENERATOR_SINGLE_EC0_ADDR    : std_logic_vector(5 downto 0) := "10" & x"4";
    constant REG_TTC_GENERATOR_SINGLE_EC0_MSB    : integer := 31;
    constant REG_TTC_GENERATOR_SINGLE_EC0_LSB     : integer := 0;

    constant REG_TTC_GENERATOR_CYCLIC_L1A_COUNT_ADDR    : std_logic_vector(5 downto 0) := "10" & x"5";
    constant REG_TTC_GENERATOR_CYCLIC_L1A_COUNT_MSB    : integer := 23;
    constant REG_TTC_GENERATOR_CYCLIC_L1A_COUNT_LSB     : integer := 0;
    constant REG_TTC_GENERATOR_CYCLIC_L1A_COUNT_DEFAULT : std_logic_vector(23 downto 0) := x"002710";

    constant REG_TTC_GENERATOR_CYCLIC_START_ADDR    : std_logic_vector(5 downto 0) := "10" & x"6";
    constant REG_TTC_GENERATOR_CYCLIC_START_MSB    : integer := 31;
    constant REG_TTC_GENERATOR_CYCLIC_START_LSB     : integer := 0;

    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_PRESCALE_ADDR    : std_logic_vector(5 downto 0) := "10" & x"7";
    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_PRESCALE_MSB    : integer := 11;
    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_PRESCALE_LSB     : integer := 0;
    constant REG_TTC_GENERATOR_CYCLIC_CALPULSE_PRESCALE_DEFAULT : std_logic_vector(11 downto 0) := x"000";


    --============================================================================
    --       >>> TRIGGER Module <<<    base address: 0x00800000
    --
    -- Trigger module handles everything related to sbit cluster data
    -- (link synchronization, monitoring, local triggering, matching to L1A and
    -- reporting data to DAQ)
    --============================================================================

    constant REG_TRIGGER_NUM_REGS : integer := 66;
    constant REG_TRIGGER_ADDRESS_MSB : integer := 12;
    constant REG_TRIGGER_ADDRESS_LSB : integer := 0;
    constant REG_TRIGGER_CTRL_MODULE_RESET_ADDR    : std_logic_vector(12 downto 0) := '0' & x"000";
    constant REG_TRIGGER_CTRL_MODULE_RESET_MSB    : integer := 31;
    constant REG_TRIGGER_CTRL_MODULE_RESET_LSB     : integer := 0;

    constant REG_TRIGGER_CTRL_CNT_RESET_ADDR    : std_logic_vector(12 downto 0) := '0' & x"001";
    constant REG_TRIGGER_CTRL_CNT_RESET_MSB    : integer := 31;
    constant REG_TRIGGER_CTRL_CNT_RESET_LSB     : integer := 0;

    constant REG_TRIGGER_CTRL_OH_KILL_MASK_ADDR    : std_logic_vector(12 downto 0) := '0' & x"002";
    constant REG_TRIGGER_CTRL_OH_KILL_MASK_MSB    : integer := 23;
    constant REG_TRIGGER_CTRL_OH_KILL_MASK_LSB     : integer := 0;
    constant REG_TRIGGER_CTRL_OH_KILL_MASK_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_TRIGGER_STATUS_OR_TRIGGER_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"010";
    constant REG_TRIGGER_STATUS_OR_TRIGGER_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_STATUS_OR_TRIGGER_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_STATUS_OR_TRIGGER_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"011";
    constant REG_TRIGGER_STATUS_OR_TRIGGER_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_STATUS_OR_TRIGGER_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_RESET_ADDR    : std_logic_vector(12 downto 0) := '0' & x"080";
    constant REG_TRIGGER_SBIT_MONITOR_RESET_MSB    : integer := 31;
    constant REG_TRIGGER_SBIT_MONITOR_RESET_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_OH_SELECT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"081";
    constant REG_TRIGGER_SBIT_MONITOR_OH_SELECT_MSB    : integer := 3;
    constant REG_TRIGGER_SBIT_MONITOR_OH_SELECT_LSB     : integer := 0;
    constant REG_TRIGGER_SBIT_MONITOR_OH_SELECT_DEFAULT : std_logic_vector(3 downto 0) := x"0";

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER0_ADDR    : std_logic_vector(12 downto 0) := '0' & x"082";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER0_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER0_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER1_ADDR    : std_logic_vector(12 downto 0) := '0' & x"083";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER1_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER1_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER2_ADDR    : std_logic_vector(12 downto 0) := '0' & x"084";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER2_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER2_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER3_ADDR    : std_logic_vector(12 downto 0) := '0' & x"085";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER3_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER3_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER4_ADDR    : std_logic_vector(12 downto 0) := '0' & x"086";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER4_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER4_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER5_ADDR    : std_logic_vector(12 downto 0) := '0' & x"087";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER5_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER5_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER6_ADDR    : std_logic_vector(12 downto 0) := '0' & x"088";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER6_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER6_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER7_ADDR    : std_logic_vector(12 downto 0) := '0' & x"089";
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER7_MSB    : integer := 15;
    constant REG_TRIGGER_SBIT_MONITOR_CLUSTER7_LSB     : integer := 0;

    constant REG_TRIGGER_SBIT_MONITOR_L1A_DELAY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"08a";
    constant REG_TRIGGER_SBIT_MONITOR_L1A_DELAY_MSB    : integer := 31;
    constant REG_TRIGGER_SBIT_MONITOR_L1A_DELAY_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_TRIGGER_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_TRIGGER_OH0_TRIGGER_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_TRIGGER_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_TRIGGER_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"101";
    constant REG_TRIGGER_OH0_TRIGGER_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_TRIGGER_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_0_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"110";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_0_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_0_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_1_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"111";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_1_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_1_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_2_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"112";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_2_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_2_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_3_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"113";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_3_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_3_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_4_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"114";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_4_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_4_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_5_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"115";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_5_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_5_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_6_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"116";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_6_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_6_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_7_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"117";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_7_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_7_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_8_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"118";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_8_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_8_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_0_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"120";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_0_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_0_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_1_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"121";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_1_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_1_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_2_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"122";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_2_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_2_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_3_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"123";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_3_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_3_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_4_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"124";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_4_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_4_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_5_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"125";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_5_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_5_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_6_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"126";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_6_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_6_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_7_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"127";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_7_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_7_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_CLUSTER_SIZE_8_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"128";
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_8_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_CLUSTER_SIZE_8_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_LINK0_SBIT_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a0";
    constant REG_TRIGGER_OH0_LINK0_SBIT_OVERFLOW_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH0_LINK0_SBIT_OVERFLOW_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_LINK1_SBIT_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a0";
    constant REG_TRIGGER_OH0_LINK1_SBIT_OVERFLOW_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_LINK1_SBIT_OVERFLOW_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH0_LINK0_MISSED_COMMA_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a1";
    constant REG_TRIGGER_OH0_LINK0_MISSED_COMMA_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH0_LINK0_MISSED_COMMA_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_LINK1_MISSED_COMMA_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a1";
    constant REG_TRIGGER_OH0_LINK1_MISSED_COMMA_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_LINK1_MISSED_COMMA_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH0_LINK0_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a3";
    constant REG_TRIGGER_OH0_LINK0_OVERFLOW_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH0_LINK0_OVERFLOW_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_LINK1_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a3";
    constant REG_TRIGGER_OH0_LINK1_OVERFLOW_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_LINK1_OVERFLOW_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH0_LINK0_UNDERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a4";
    constant REG_TRIGGER_OH0_LINK0_UNDERFLOW_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH0_LINK0_UNDERFLOW_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_LINK1_UNDERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a4";
    constant REG_TRIGGER_OH0_LINK1_UNDERFLOW_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_LINK1_UNDERFLOW_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH0_LINK0_SYNC_WORD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a5";
    constant REG_TRIGGER_OH0_LINK0_SYNC_WORD_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH0_LINK0_SYNC_WORD_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH0_LINK1_SYNC_WORD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"1a5";
    constant REG_TRIGGER_OH0_LINK1_SYNC_WORD_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH0_LINK1_SYNC_WORD_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH1_TRIGGER_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_TRIGGER_OH1_TRIGGER_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_TRIGGER_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_TRIGGER_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"201";
    constant REG_TRIGGER_OH1_TRIGGER_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_TRIGGER_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_0_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"210";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_0_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_0_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_1_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"211";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_1_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_1_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_2_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"212";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_2_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_2_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_3_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"213";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_3_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_3_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_4_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"214";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_4_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_4_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_5_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"215";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_5_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_5_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_6_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"216";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_6_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_6_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_7_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"217";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_7_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_7_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_8_RATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"218";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_8_RATE_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_8_RATE_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_0_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"220";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_0_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_0_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_1_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"221";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_1_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_1_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_2_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"222";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_2_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_2_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_3_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"223";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_3_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_3_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_4_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"224";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_4_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_4_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_5_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"225";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_5_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_5_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_6_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"226";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_6_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_6_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_7_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"227";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_7_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_7_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_CLUSTER_SIZE_8_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"228";
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_8_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_CLUSTER_SIZE_8_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_LINK0_SBIT_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a0";
    constant REG_TRIGGER_OH1_LINK0_SBIT_OVERFLOW_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH1_LINK0_SBIT_OVERFLOW_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_LINK1_SBIT_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a0";
    constant REG_TRIGGER_OH1_LINK1_SBIT_OVERFLOW_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_LINK1_SBIT_OVERFLOW_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH1_LINK0_MISSED_COMMA_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a1";
    constant REG_TRIGGER_OH1_LINK0_MISSED_COMMA_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH1_LINK0_MISSED_COMMA_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_LINK1_MISSED_COMMA_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a1";
    constant REG_TRIGGER_OH1_LINK1_MISSED_COMMA_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_LINK1_MISSED_COMMA_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH1_LINK0_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a3";
    constant REG_TRIGGER_OH1_LINK0_OVERFLOW_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH1_LINK0_OVERFLOW_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_LINK1_OVERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a3";
    constant REG_TRIGGER_OH1_LINK1_OVERFLOW_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_LINK1_OVERFLOW_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH1_LINK0_UNDERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a4";
    constant REG_TRIGGER_OH1_LINK0_UNDERFLOW_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH1_LINK0_UNDERFLOW_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_LINK1_UNDERFLOW_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a4";
    constant REG_TRIGGER_OH1_LINK1_UNDERFLOW_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_LINK1_UNDERFLOW_CNT_LSB     : integer := 16;

    constant REG_TRIGGER_OH1_LINK0_SYNC_WORD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a5";
    constant REG_TRIGGER_OH1_LINK0_SYNC_WORD_CNT_MSB    : integer := 15;
    constant REG_TRIGGER_OH1_LINK0_SYNC_WORD_CNT_LSB     : integer := 0;

    constant REG_TRIGGER_OH1_LINK1_SYNC_WORD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"2a5";
    constant REG_TRIGGER_OH1_LINK1_SYNC_WORD_CNT_MSB    : integer := 31;
    constant REG_TRIGGER_OH1_LINK1_SYNC_WORD_CNT_LSB     : integer := 16;


    --============================================================================
    --       >>> GEM_SYSTEM Module <<<    base address: 0x00900000
    --
    -- This module is controlling GEM AMC System wide settings
    --============================================================================

    constant REG_GEM_SYSTEM_NUM_REGS : integer := 13;
    constant REG_GEM_SYSTEM_ADDRESS_MSB : integer := 16;
    constant REG_GEM_SYSTEM_ADDRESS_LSB : integer := 0;
    constant REG_GEM_SYSTEM_TK_LINK_RX_POLARITY_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0000";
    constant REG_GEM_SYSTEM_TK_LINK_RX_POLARITY_MSB    : integer := 23;
    constant REG_GEM_SYSTEM_TK_LINK_RX_POLARITY_LSB     : integer := 0;
    constant REG_GEM_SYSTEM_TK_LINK_RX_POLARITY_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_GEM_SYSTEM_TK_LINK_TX_POLARITY_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0001";
    constant REG_GEM_SYSTEM_TK_LINK_TX_POLARITY_MSB    : integer := 23;
    constant REG_GEM_SYSTEM_TK_LINK_TX_POLARITY_LSB     : integer := 0;
    constant REG_GEM_SYSTEM_TK_LINK_TX_POLARITY_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_GEM_SYSTEM_BOARD_ID_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0002";
    constant REG_GEM_SYSTEM_BOARD_ID_MSB    : integer := 15;
    constant REG_GEM_SYSTEM_BOARD_ID_LSB     : integer := 0;
    constant REG_GEM_SYSTEM_BOARD_ID_DEFAULT : std_logic_vector(15 downto 0) := x"beef";

    constant REG_GEM_SYSTEM_BOARD_TYPE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0002";
    constant REG_GEM_SYSTEM_BOARD_TYPE_MSB    : integer := 19;
    constant REG_GEM_SYSTEM_BOARD_TYPE_LSB     : integer := 16;

    constant REG_GEM_SYSTEM_RELEASE_BUILD_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0003";
    constant REG_GEM_SYSTEM_RELEASE_BUILD_MSB    : integer := 7;
    constant REG_GEM_SYSTEM_RELEASE_BUILD_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_RELEASE_MINOR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0003";
    constant REG_GEM_SYSTEM_RELEASE_MINOR_MSB    : integer := 15;
    constant REG_GEM_SYSTEM_RELEASE_MINOR_LSB     : integer := 8;

    constant REG_GEM_SYSTEM_RELEASE_MAJOR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0003";
    constant REG_GEM_SYSTEM_RELEASE_MAJOR_MSB    : integer := 23;
    constant REG_GEM_SYSTEM_RELEASE_MAJOR_LSB     : integer := 16;

    constant REG_GEM_SYSTEM_RELEASE_DATE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0004";
    constant REG_GEM_SYSTEM_RELEASE_DATE_MSB    : integer := 31;
    constant REG_GEM_SYSTEM_RELEASE_DATE_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_CONFIG_NUM_OF_OH_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0005";
    constant REG_GEM_SYSTEM_CONFIG_NUM_OF_OH_MSB    : integer := 4;
    constant REG_GEM_SYSTEM_CONFIG_NUM_OF_OH_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_CONFIG_USE_TRIG_LINKS_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0005";
    constant REG_GEM_SYSTEM_CONFIG_USE_TRIG_LINKS_BIT    : integer := 9;

    constant REG_GEM_SYSTEM_VFAT3_USE_OH_VFAT3_SLOTS_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0011";
    constant REG_GEM_SYSTEM_VFAT3_USE_OH_VFAT3_SLOTS_BIT    : integer := 0;
    constant REG_GEM_SYSTEM_VFAT3_USE_OH_VFAT3_SLOTS_DEFAULT : std_logic := '0';

    constant REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0011";
    constant REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_BIT    : integer := 1;
    constant REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_DEFAULT : std_logic := '0';

    constant REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0011";
    constant REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_BIT    : integer := 2;
    constant REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_DEFAULT : std_logic := '0';

    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_SLOW_RX_BITSHIFT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0011";
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_SLOW_RX_BITSHIFT_MSB    : integer := 6;
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_SLOW_RX_BITSHIFT_LSB     : integer := 4;
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_SLOW_RX_BITSHIFT_DEFAULT : std_logic_vector(6 downto 4) := "010";

    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_0_BITSLIP_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0011";
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_0_BITSLIP_MSB    : integer := 11;
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_0_BITSLIP_LSB     : integer := 8;
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_0_BITSLIP_DEFAULT : std_logic_vector(11 downto 8) := x"0";

    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_1_BITSLIP_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0011";
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_1_BITSLIP_MSB    : integer := 15;
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_1_BITSLIP_LSB     : integer := 12;
    constant REG_GEM_SYSTEM_VFAT3_V3B_FPGA_TX_1_BITSLIP_DEFAULT : std_logic_vector(15 downto 12) := x"4";

    constant REG_GEM_SYSTEM_CTRL_CNT_RESET_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0100";
    constant REG_GEM_SYSTEM_CTRL_CNT_RESET_MSB    : integer := 31;
    constant REG_GEM_SYSTEM_CTRL_CNT_RESET_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_CTRL_LINK_RESET_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0101";
    constant REG_GEM_SYSTEM_CTRL_LINK_RESET_MSB    : integer := 31;
    constant REG_GEM_SYSTEM_CTRL_LINK_RESET_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0200";
    constant REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_BIT    : integer := 0;
    constant REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_DEFAULT : std_logic := '0';

    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_BOARD_ID_ADDR    : std_logic_vector(16 downto 0) := '1' & x"0000";
    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_BOARD_ID_MSB    : integer := 31;
    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_BOARD_ID_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_SYSTEM_ID_ADDR    : std_logic_vector(16 downto 0) := '1' & x"0001";
    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_SYSTEM_ID_MSB    : integer := 31;
    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_SYSTEM_ID_LSB     : integer := 0;

    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_FIRMWARE_VERSION_ADDR    : std_logic_vector(16 downto 0) := '1' & x"0002";
    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_FIRMWARE_VERSION_MSB    : integer := 31;
    constant REG_GEM_SYSTEM_LEGACY_SYSTEM_FIRMWARE_VERSION_LSB     : integer := 0;


    --============================================================================
    --       >>> GEM_TESTS Module <<<    base address: 0x00a00000
    --
    -- This module is controlling various hardware tests e.g. fiber loopback
    --============================================================================

    constant REG_GEM_TESTS_NUM_REGS : integer := 46;
    constant REG_GEM_TESTS_ADDRESS_MSB : integer := 16;
    constant REG_GEM_TESTS_ADDRESS_LSB : integer := 0;
    constant REG_GEM_TESTS_CTRL_RESET_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0000";
    constant REG_GEM_TESTS_CTRL_RESET_MSB    : integer := 31;
    constant REG_GEM_TESTS_CTRL_RESET_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_CTRL_LOOP_THROUGH_OH_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1000";
    constant REG_GEM_TESTS_GBT_LOOPBACK_CTRL_LOOP_THROUGH_OH_BIT    : integer := 0;
    constant REG_GEM_TESTS_GBT_LOOPBACK_CTRL_LOOP_THROUGH_OH_DEFAULT : std_logic := '0';

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_SYNC_DONE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1010";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_SYNC_DONE_BIT    : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_MEGA_WORD_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1011";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_MEGA_WORD_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_MEGA_WORD_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1012";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_ERROR_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_0_ERROR_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_SYNC_DONE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1020";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_SYNC_DONE_BIT    : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_MEGA_WORD_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1021";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_MEGA_WORD_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_MEGA_WORD_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1022";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_ERROR_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_1_ERROR_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_SYNC_DONE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1030";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_SYNC_DONE_BIT    : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_MEGA_WORD_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1031";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_MEGA_WORD_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_MEGA_WORD_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1032";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_ERROR_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_2_ERROR_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_SYNC_DONE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1040";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_SYNC_DONE_BIT    : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_MEGA_WORD_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1041";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_MEGA_WORD_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_MEGA_WORD_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1042";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_ERROR_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_3_ERROR_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_SYNC_DONE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1050";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_SYNC_DONE_BIT    : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_MEGA_WORD_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1051";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_MEGA_WORD_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_MEGA_WORD_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1052";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_ERROR_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_4_ERROR_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_SYNC_DONE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1060";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_SYNC_DONE_BIT    : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_MEGA_WORD_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1061";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_MEGA_WORD_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_MEGA_WORD_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1062";
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_ERROR_CNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_GBT_LOOPBACK_LINK_5_ERROR_CNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_RESET_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2000";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_RESET_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_RESET_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_ENABLE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2001";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_ENABLE_BIT    : integer := 0;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_ENABLE_DEFAULT : std_logic := '0';

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_OH_SELECT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2001";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_OH_SELECT_MSB    : integer := 7;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_OH_SELECT_LSB     : integer := 4;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_OH_SELECT_DEFAULT : std_logic_vector(7 downto 4) := x"0";

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_SELECT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2001";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_SELECT_MSB    : integer := 14;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_SELECT_LSB     : integer := 8;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_SELECT_DEFAULT : std_logic_vector(14 downto 8) := "000" & x"0";

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_GLOBAL_OR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2001";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_GLOBAL_OR_BIT    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_CTRL_VFAT_CHANNEL_GLOBAL_OR_DEFAULT : std_logic := '0';

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT0_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2010";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT0_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT0_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT0_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2010";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT0_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT0_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT1_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2020";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT1_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT1_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT1_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2020";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT1_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT1_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT2_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2030";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT2_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT2_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT2_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2030";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT2_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT2_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT3_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2040";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT3_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT3_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT3_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2040";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT3_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT3_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT4_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2050";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT4_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT4_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT4_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2050";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT4_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT4_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT5_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2060";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT5_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT5_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT5_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2060";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT5_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT5_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT6_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2070";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT6_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT6_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT6_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2070";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT6_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT6_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT7_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2080";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT7_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT7_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT7_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2080";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT7_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT7_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT8_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2090";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT8_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT8_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT8_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2090";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT8_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT8_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT9_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20a0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT9_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT9_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT9_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20a0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT9_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT9_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT10_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20b0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT10_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT10_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT10_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20b0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT10_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT10_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT11_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20c0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT11_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT11_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT11_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20c0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT11_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT11_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT12_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20d0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT12_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT12_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT12_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20d0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT12_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT12_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT13_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20e0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT13_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT13_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT13_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20e0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT13_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT13_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT14_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20f0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT14_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT14_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT14_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"20f0";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT14_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT14_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT15_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2100";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT15_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT15_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT15_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2100";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT15_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT15_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT16_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2110";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT16_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT16_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT16_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2110";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT16_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT16_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT17_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2120";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT17_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT17_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT17_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2120";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT17_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT17_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT18_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2130";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT18_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT18_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT18_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2130";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT18_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT18_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT19_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2140";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT19_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT19_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT19_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2140";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT19_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT19_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT20_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2150";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT20_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT20_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT20_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2150";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT20_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT20_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT21_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2160";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT21_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT21_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT21_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2160";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT21_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT21_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT22_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2170";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT22_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT22_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT22_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2170";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT22_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT22_CHANNEL_FIRE_COUNT_LSB     : integer := 16;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT23_GOOD_EVENTS_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2180";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT23_GOOD_EVENTS_COUNT_MSB    : integer := 15;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT23_GOOD_EVENTS_COUNT_LSB     : integer := 0;

    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT23_CHANNEL_FIRE_COUNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2180";
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT23_CHANNEL_FIRE_COUNT_MSB    : integer := 31;
    constant REG_GEM_TESTS_VFAT_DAQ_MONITOR_VFAT23_CHANNEL_FIRE_COUNT_LSB     : integer := 16;


    --============================================================================
    --       >>> DAQ Module <<<    base address: 0x00700000
    --
    -- DAQ module buffers track data, builds events, analyses the data for
    -- consistency                        and ships off the events with all the
    -- needed headers and trailers to AMC13 over DAQLink
    --============================================================================

    constant REG_DAQ_NUM_REGS : integer := 46;
    constant REG_DAQ_ADDRESS_MSB : integer := 8;
    constant REG_DAQ_ADDRESS_LSB : integer := 0;
    constant REG_DAQ_CONTROL_DAQ_ENABLE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_DAQ_ENABLE_BIT    : integer := 0;
    constant REG_DAQ_CONTROL_DAQ_ENABLE_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_ZERO_SUPPRESSION_EN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_ZERO_SUPPRESSION_EN_BIT    : integer := 1;
    constant REG_DAQ_CONTROL_ZERO_SUPPRESSION_EN_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_DAQ_LINK_RESET_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_DAQ_LINK_RESET_BIT    : integer := 2;
    constant REG_DAQ_CONTROL_DAQ_LINK_RESET_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_RESET_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_RESET_BIT    : integer := 3;
    constant REG_DAQ_CONTROL_RESET_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_TTS_OVERRIDE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_TTS_OVERRIDE_MSB    : integer := 7;
    constant REG_DAQ_CONTROL_TTS_OVERRIDE_LSB     : integer := 4;
    constant REG_DAQ_CONTROL_TTS_OVERRIDE_DEFAULT : std_logic_vector(7 downto 4) := x"0";

    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_MSB    : integer := 31;
    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_LSB     : integer := 8;
    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_DEFAULT : std_logic_vector(31 downto 8) := x"000001";

    constant REG_DAQ_STATUS_DAQ_LINK_RDY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_LINK_RDY_BIT    : integer := 0;

    constant REG_DAQ_STATUS_DAQ_CLK_LOCKED_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_CLK_LOCKED_BIT    : integer := 1;

    constant REG_DAQ_STATUS_TTC_RDY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_TTC_RDY_BIT    : integer := 2;

    constant REG_DAQ_STATUS_DAQ_LINK_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_LINK_AFULL_BIT    : integer := 3;

    constant REG_DAQ_STATUS_DAQ_OUTPUT_FIFO_HAD_OVERFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_OUTPUT_FIFO_HAD_OVERFLOW_BIT    : integer := 4;

    constant REG_DAQ_STATUS_TTC_BC0_LOCKED_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_TTC_BC0_LOCKED_BIT    : integer := 5;

    constant REG_DAQ_STATUS_L1A_FIFO_HAD_OVERFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_HAD_OVERFLOW_BIT    : integer := 23;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_UNDERFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_UNDERFLOW_BIT    : integer := 24;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_NEAR_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_NEAR_FULL_BIT    : integer := 26;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_TTS_STATE_MSB    : integer := 31;
    constant REG_DAQ_STATUS_TTS_STATE_LSB     : integer := 28;

    constant REG_DAQ_EXT_STATUS_NOTINTABLE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"02";
    constant REG_DAQ_EXT_STATUS_NOTINTABLE_ERR_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_NOTINTABLE_ERR_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_DISPER_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"03";
    constant REG_DAQ_EXT_STATUS_DISPER_ERR_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_DISPER_ERR_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_L1AID_ADDR    : std_logic_vector(8 downto 0) := '0' & x"04";
    constant REG_DAQ_EXT_STATUS_L1AID_MSB    : integer := 23;
    constant REG_DAQ_EXT_STATUS_L1AID_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_EVT_SENT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"05";
    constant REG_DAQ_EXT_STATUS_EVT_SENT_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_EVT_SENT_LSB     : integer := 0;

    constant REG_DAQ_CONTROL_DAV_TIMEOUT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_DAV_TIMEOUT_MSB    : integer := 23;
    constant REG_DAQ_CONTROL_DAV_TIMEOUT_LSB     : integer := 0;
    constant REG_DAQ_CONTROL_DAV_TIMEOUT_DEFAULT : std_logic_vector(23 downto 0) := x"000500";

    constant REG_DAQ_CONTROL_DBG_FANOUT_ENABLE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_DBG_FANOUT_ENABLE_BIT    : integer := 24;
    constant REG_DAQ_CONTROL_DBG_FANOUT_ENABLE_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_DBG_IGNORE_DAQLINK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_DBG_IGNORE_DAQLINK_BIT    : integer := 25;
    constant REG_DAQ_CONTROL_DBG_IGNORE_DAQLINK_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_DBG_FANOUT_INPUT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_DBG_FANOUT_INPUT_MSB    : integer := 31;
    constant REG_DAQ_CONTROL_DBG_FANOUT_INPUT_LSB     : integer := 28;
    constant REG_DAQ_CONTROL_DBG_FANOUT_INPUT_DEFAULT : std_logic_vector(31 downto 28) := x"0";

    constant REG_DAQ_EXT_STATUS_MAX_DAV_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"07";
    constant REG_DAQ_EXT_STATUS_MAX_DAV_TIMER_MSB    : integer := 23;
    constant REG_DAQ_EXT_STATUS_MAX_DAV_TIMER_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_LAST_DAV_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"08";
    constant REG_DAQ_EXT_STATUS_LAST_DAV_TIMER_MSB    : integer := 23;
    constant REG_DAQ_EXT_STATUS_LAST_DAV_TIMER_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_L1A_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"09";
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_DATA_CNT_MSB    : integer := 12;
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"09";
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_DATA_CNT_MSB    : integer := 28;
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_EXT_STATUS_L1A_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0a";
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0a";
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_EXT_STATUS_DAQ_ALMOST_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0b";
    constant REG_DAQ_EXT_STATUS_DAQ_ALMOST_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_DAQ_ALMOST_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_TTS_WARN_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0b";
    constant REG_DAQ_EXT_STATUS_TTS_WARN_CNT_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_TTS_WARN_CNT_LSB     : integer := 16;

    constant REG_DAQ_EXT_STATUS_DAQ_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0c";
    constant REG_DAQ_EXT_STATUS_DAQ_WORD_RATE_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_DAQ_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0f";
    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_MSB    : integer := 23;
    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_LSB     : integer := 0;
    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0f";
    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_MSB    : integer := 27;
    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_LSB     : integer := 24;
    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_DEFAULT : std_logic_vector(27 downto 24) := x"0";

    constant REG_DAQ_OH0_STATUS_VFAT_MIXED_EC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_MIXED_EC_BIT    : integer := 1;

    constant REG_DAQ_OH0_STATUS_VFAT_MIXED_BC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_MIXED_BC_BIT    : integer := 2;

    constant REG_DAQ_OH0_STATUS_OH_MIXED_BC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_OH_MIXED_BC_BIT    : integer := 3;

    constant REG_DAQ_OH0_STATUS_VFAT_TOO_MANY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_TOO_MANY_BIT    : integer := 4;

    constant REG_DAQ_OH0_STATUS_VFAT_SMALL_BLOCK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_SMALL_BLOCK_BIT    : integer := 5;

    constant REG_DAQ_OH0_STATUS_VFAT_LARGE_BLOCK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_LARGE_BLOCK_BIT    : integer := 6;

    constant REG_DAQ_OH0_STATUS_VFAT_NO_MARKER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_NO_MARKER_BIT    : integer := 7;

    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_OH0_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_OH0_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_OH0_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_OH0_STATUS_VFAT_INPUT_HAD_OVF_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_INPUT_HAD_OVF_BIT    : integer := 16;

    constant REG_DAQ_OH0_STATUS_VFAT_INPUT_HAD_UNF_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_VFAT_INPUT_HAD_UNF_BIT    : integer := 17;

    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_OH0_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_OH0_COUNTERS_CORRUPT_VFAT_BLK_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"11";
    constant REG_DAQ_OH0_COUNTERS_CORRUPT_VFAT_BLK_CNT_MSB    : integer := 31;
    constant REG_DAQ_OH0_COUNTERS_CORRUPT_VFAT_BLK_CNT_LSB     : integer := 0;

    constant REG_DAQ_OH0_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"12";
    constant REG_DAQ_OH0_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_OH0_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_OH0_CONTROL_EOE_TIMEOUT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"13";
    constant REG_DAQ_OH0_CONTROL_EOE_TIMEOUT_MSB    : integer := 23;
    constant REG_DAQ_OH0_CONTROL_EOE_TIMEOUT_LSB     : integer := 0;
    constant REG_DAQ_OH0_CONTROL_EOE_TIMEOUT_DEFAULT : std_logic_vector(23 downto 0) := x"000100";

    constant REG_DAQ_OH0_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"14";
    constant REG_DAQ_OH0_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 11;
    constant REG_DAQ_OH0_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_OH0_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"14";
    constant REG_DAQ_OH0_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_OH0_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_OH0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"15";
    constant REG_DAQ_OH0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_OH0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_OH0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"15";
    constant REG_DAQ_OH0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_OH0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_OH0_COUNTERS_VFAT_BLOCK_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"16";
    constant REG_DAQ_OH0_COUNTERS_VFAT_BLOCK_RATE_MSB    : integer := 14;
    constant REG_DAQ_OH0_COUNTERS_VFAT_BLOCK_RATE_LSB     : integer := 0;

    constant REG_DAQ_OH0_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"16";
    constant REG_DAQ_OH0_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_OH0_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_OH0_COUNTERS_MAX_EOE_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"17";
    constant REG_DAQ_OH0_COUNTERS_MAX_EOE_TIMER_MSB    : integer := 23;
    constant REG_DAQ_OH0_COUNTERS_MAX_EOE_TIMER_LSB     : integer := 0;

    constant REG_DAQ_OH0_COUNTERS_LAST_EOE_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"18";
    constant REG_DAQ_OH0_COUNTERS_LAST_EOE_TIMER_MSB    : integer := 23;
    constant REG_DAQ_OH0_COUNTERS_LAST_EOE_TIMER_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK0_ADDR    : std_logic_vector(8 downto 0) := '0' & x"19";
    constant REG_DAQ_OH0_LASTBLOCK0_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK0_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK1_ADDR    : std_logic_vector(8 downto 0) := '0' & x"1a";
    constant REG_DAQ_OH0_LASTBLOCK1_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK1_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK2_ADDR    : std_logic_vector(8 downto 0) := '0' & x"1b";
    constant REG_DAQ_OH0_LASTBLOCK2_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK2_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK3_ADDR    : std_logic_vector(8 downto 0) := '0' & x"1c";
    constant REG_DAQ_OH0_LASTBLOCK3_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK3_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK4_ADDR    : std_logic_vector(8 downto 0) := '0' & x"1d";
    constant REG_DAQ_OH0_LASTBLOCK4_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK4_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK5_ADDR    : std_logic_vector(8 downto 0) := '0' & x"1e";
    constant REG_DAQ_OH0_LASTBLOCK5_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK5_LSB     : integer := 0;

    constant REG_DAQ_OH0_LASTBLOCK6_ADDR    : std_logic_vector(8 downto 0) := '0' & x"1f";
    constant REG_DAQ_OH0_LASTBLOCK6_MSB    : integer := 31;
    constant REG_DAQ_OH0_LASTBLOCK6_LSB     : integer := 0;

    constant REG_DAQ_OH1_STATUS_VFAT_MIXED_EC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_MIXED_EC_BIT    : integer := 1;

    constant REG_DAQ_OH1_STATUS_VFAT_MIXED_BC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_MIXED_BC_BIT    : integer := 2;

    constant REG_DAQ_OH1_STATUS_OH_MIXED_BC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_OH_MIXED_BC_BIT    : integer := 3;

    constant REG_DAQ_OH1_STATUS_VFAT_TOO_MANY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_TOO_MANY_BIT    : integer := 4;

    constant REG_DAQ_OH1_STATUS_VFAT_SMALL_BLOCK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_SMALL_BLOCK_BIT    : integer := 5;

    constant REG_DAQ_OH1_STATUS_VFAT_LARGE_BLOCK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_LARGE_BLOCK_BIT    : integer := 6;

    constant REG_DAQ_OH1_STATUS_VFAT_NO_MARKER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_NO_MARKER_BIT    : integer := 7;

    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_OH1_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_OH1_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_OH1_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_OH1_STATUS_VFAT_INPUT_HAD_OVF_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_INPUT_HAD_OVF_BIT    : integer := 16;

    constant REG_DAQ_OH1_STATUS_VFAT_INPUT_HAD_UNF_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_VFAT_INPUT_HAD_UNF_BIT    : integer := 17;

    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_OH1_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_OH1_COUNTERS_CORRUPT_VFAT_BLK_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"21";
    constant REG_DAQ_OH1_COUNTERS_CORRUPT_VFAT_BLK_CNT_MSB    : integer := 31;
    constant REG_DAQ_OH1_COUNTERS_CORRUPT_VFAT_BLK_CNT_LSB     : integer := 0;

    constant REG_DAQ_OH1_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"22";
    constant REG_DAQ_OH1_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_OH1_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_OH1_CONTROL_EOE_TIMEOUT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"23";
    constant REG_DAQ_OH1_CONTROL_EOE_TIMEOUT_MSB    : integer := 23;
    constant REG_DAQ_OH1_CONTROL_EOE_TIMEOUT_LSB     : integer := 0;
    constant REG_DAQ_OH1_CONTROL_EOE_TIMEOUT_DEFAULT : std_logic_vector(23 downto 0) := x"000100";

    constant REG_DAQ_OH1_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"24";
    constant REG_DAQ_OH1_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 11;
    constant REG_DAQ_OH1_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_OH1_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"24";
    constant REG_DAQ_OH1_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_OH1_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_OH1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"25";
    constant REG_DAQ_OH1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_OH1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_OH1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"25";
    constant REG_DAQ_OH1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_OH1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_OH1_COUNTERS_VFAT_BLOCK_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"26";
    constant REG_DAQ_OH1_COUNTERS_VFAT_BLOCK_RATE_MSB    : integer := 14;
    constant REG_DAQ_OH1_COUNTERS_VFAT_BLOCK_RATE_LSB     : integer := 0;

    constant REG_DAQ_OH1_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"26";
    constant REG_DAQ_OH1_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_OH1_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_OH1_COUNTERS_MAX_EOE_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"27";
    constant REG_DAQ_OH1_COUNTERS_MAX_EOE_TIMER_MSB    : integer := 23;
    constant REG_DAQ_OH1_COUNTERS_MAX_EOE_TIMER_LSB     : integer := 0;

    constant REG_DAQ_OH1_COUNTERS_LAST_EOE_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"28";
    constant REG_DAQ_OH1_COUNTERS_LAST_EOE_TIMER_MSB    : integer := 23;
    constant REG_DAQ_OH1_COUNTERS_LAST_EOE_TIMER_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK0_ADDR    : std_logic_vector(8 downto 0) := '0' & x"29";
    constant REG_DAQ_OH1_LASTBLOCK0_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK0_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK1_ADDR    : std_logic_vector(8 downto 0) := '0' & x"2a";
    constant REG_DAQ_OH1_LASTBLOCK1_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK1_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK2_ADDR    : std_logic_vector(8 downto 0) := '0' & x"2b";
    constant REG_DAQ_OH1_LASTBLOCK2_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK2_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK3_ADDR    : std_logic_vector(8 downto 0) := '0' & x"2c";
    constant REG_DAQ_OH1_LASTBLOCK3_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK3_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK4_ADDR    : std_logic_vector(8 downto 0) := '0' & x"2d";
    constant REG_DAQ_OH1_LASTBLOCK4_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK4_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK5_ADDR    : std_logic_vector(8 downto 0) := '0' & x"2e";
    constant REG_DAQ_OH1_LASTBLOCK5_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK5_LSB     : integer := 0;

    constant REG_DAQ_OH1_LASTBLOCK6_ADDR    : std_logic_vector(8 downto 0) := '0' & x"2f";
    constant REG_DAQ_OH1_LASTBLOCK6_MSB    : integer := 31;
    constant REG_DAQ_OH1_LASTBLOCK6_LSB     : integer := 0;


    --============================================================================
    --       >>> OH_LINKS Module <<<    base address: 0x00600000
    --
    -- OH Link monitoring registers
    --============================================================================

    constant REG_OH_LINKS_NUM_REGS : integer := 52;
    constant REG_OH_LINKS_ADDRESS_MSB : integer := 12;
    constant REG_OH_LINKS_ADDRESS_LSB : integer := 0;
    constant REG_OH_LINKS_OH0_GBT0_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT0_READY_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_GBT1_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT1_READY_BIT    : integer := 1;

    constant REG_OH_LINKS_OH0_GBT2_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT2_READY_BIT    : integer := 2;

    constant REG_OH_LINKS_OH0_GBT0_WAS_NOT_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT0_WAS_NOT_READY_BIT    : integer := 3;

    constant REG_OH_LINKS_OH0_GBT1_WAS_NOT_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT1_WAS_NOT_READY_BIT    : integer := 4;

    constant REG_OH_LINKS_OH0_GBT2_WAS_NOT_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT2_WAS_NOT_READY_BIT    : integer := 5;

    constant REG_OH_LINKS_OH0_GBT0_RX_HAD_OVERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT0_RX_HAD_OVERFLOW_BIT    : integer := 6;

    constant REG_OH_LINKS_OH0_GBT1_RX_HAD_OVERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT1_RX_HAD_OVERFLOW_BIT    : integer := 7;

    constant REG_OH_LINKS_OH0_GBT2_RX_HAD_OVERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT2_RX_HAD_OVERFLOW_BIT    : integer := 8;

    constant REG_OH_LINKS_OH0_GBT0_RX_HAD_UNDERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT0_RX_HAD_UNDERFLOW_BIT    : integer := 9;

    constant REG_OH_LINKS_OH0_GBT1_RX_HAD_UNDERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT1_RX_HAD_UNDERFLOW_BIT    : integer := 10;

    constant REG_OH_LINKS_OH0_GBT2_RX_HAD_UNDERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"100";
    constant REG_OH_LINKS_OH0_GBT2_RX_HAD_UNDERFLOW_BIT    : integer := 11;

    constant REG_OH_LINKS_OH0_VFAT_MASK_ADDR    : std_logic_vector(12 downto 0) := '0' & x"101";
    constant REG_OH_LINKS_OH0_VFAT_MASK_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT_MASK_LSB     : integer := 0;
    constant REG_OH_LINKS_OH0_VFAT_MASK_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_OH_LINKS_OH0_VFAT0_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"110";
    constant REG_OH_LINKS_OH0_VFAT0_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT0_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"110";
    constant REG_OH_LINKS_OH0_VFAT0_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT0_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT0_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"110";
    constant REG_OH_LINKS_OH0_VFAT0_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT0_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT0_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"110";
    constant REG_OH_LINKS_OH0_VFAT0_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT0_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT1_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"112";
    constant REG_OH_LINKS_OH0_VFAT1_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT1_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"112";
    constant REG_OH_LINKS_OH0_VFAT1_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT1_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT1_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"112";
    constant REG_OH_LINKS_OH0_VFAT1_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT1_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT1_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"112";
    constant REG_OH_LINKS_OH0_VFAT1_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT1_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT2_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"114";
    constant REG_OH_LINKS_OH0_VFAT2_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT2_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"114";
    constant REG_OH_LINKS_OH0_VFAT2_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT2_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT2_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"114";
    constant REG_OH_LINKS_OH0_VFAT2_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT2_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT2_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"114";
    constant REG_OH_LINKS_OH0_VFAT2_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT2_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT3_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"116";
    constant REG_OH_LINKS_OH0_VFAT3_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT3_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"116";
    constant REG_OH_LINKS_OH0_VFAT3_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT3_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT3_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"116";
    constant REG_OH_LINKS_OH0_VFAT3_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT3_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT3_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"116";
    constant REG_OH_LINKS_OH0_VFAT3_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT3_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT4_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"118";
    constant REG_OH_LINKS_OH0_VFAT4_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT4_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"118";
    constant REG_OH_LINKS_OH0_VFAT4_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT4_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT4_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"118";
    constant REG_OH_LINKS_OH0_VFAT4_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT4_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT4_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"118";
    constant REG_OH_LINKS_OH0_VFAT4_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT4_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT5_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11a";
    constant REG_OH_LINKS_OH0_VFAT5_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT5_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11a";
    constant REG_OH_LINKS_OH0_VFAT5_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT5_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT5_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11a";
    constant REG_OH_LINKS_OH0_VFAT5_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT5_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT5_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11a";
    constant REG_OH_LINKS_OH0_VFAT5_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT5_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT6_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11c";
    constant REG_OH_LINKS_OH0_VFAT6_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT6_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11c";
    constant REG_OH_LINKS_OH0_VFAT6_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT6_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT6_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11c";
    constant REG_OH_LINKS_OH0_VFAT6_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT6_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT6_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11c";
    constant REG_OH_LINKS_OH0_VFAT6_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT6_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT7_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11e";
    constant REG_OH_LINKS_OH0_VFAT7_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT7_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11e";
    constant REG_OH_LINKS_OH0_VFAT7_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT7_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT7_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11e";
    constant REG_OH_LINKS_OH0_VFAT7_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT7_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT7_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"11e";
    constant REG_OH_LINKS_OH0_VFAT7_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT7_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT8_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"120";
    constant REG_OH_LINKS_OH0_VFAT8_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT8_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"120";
    constant REG_OH_LINKS_OH0_VFAT8_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT8_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT8_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"120";
    constant REG_OH_LINKS_OH0_VFAT8_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT8_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT8_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"120";
    constant REG_OH_LINKS_OH0_VFAT8_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT8_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT9_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"122";
    constant REG_OH_LINKS_OH0_VFAT9_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT9_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"122";
    constant REG_OH_LINKS_OH0_VFAT9_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT9_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT9_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"122";
    constant REG_OH_LINKS_OH0_VFAT9_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT9_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT9_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"122";
    constant REG_OH_LINKS_OH0_VFAT9_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT9_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT10_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"124";
    constant REG_OH_LINKS_OH0_VFAT10_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT10_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"124";
    constant REG_OH_LINKS_OH0_VFAT10_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT10_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT10_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"124";
    constant REG_OH_LINKS_OH0_VFAT10_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT10_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT10_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"124";
    constant REG_OH_LINKS_OH0_VFAT10_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT10_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT11_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"126";
    constant REG_OH_LINKS_OH0_VFAT11_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT11_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"126";
    constant REG_OH_LINKS_OH0_VFAT11_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT11_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT11_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"126";
    constant REG_OH_LINKS_OH0_VFAT11_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT11_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT11_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"126";
    constant REG_OH_LINKS_OH0_VFAT11_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT11_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT12_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"128";
    constant REG_OH_LINKS_OH0_VFAT12_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT12_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"128";
    constant REG_OH_LINKS_OH0_VFAT12_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT12_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT12_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"128";
    constant REG_OH_LINKS_OH0_VFAT12_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT12_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT12_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"128";
    constant REG_OH_LINKS_OH0_VFAT12_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT12_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT13_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12a";
    constant REG_OH_LINKS_OH0_VFAT13_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT13_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12a";
    constant REG_OH_LINKS_OH0_VFAT13_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT13_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT13_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12a";
    constant REG_OH_LINKS_OH0_VFAT13_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT13_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT13_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12a";
    constant REG_OH_LINKS_OH0_VFAT13_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT13_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT14_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12c";
    constant REG_OH_LINKS_OH0_VFAT14_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT14_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12c";
    constant REG_OH_LINKS_OH0_VFAT14_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT14_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT14_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12c";
    constant REG_OH_LINKS_OH0_VFAT14_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT14_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT14_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12c";
    constant REG_OH_LINKS_OH0_VFAT14_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT14_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT15_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12e";
    constant REG_OH_LINKS_OH0_VFAT15_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT15_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12e";
    constant REG_OH_LINKS_OH0_VFAT15_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT15_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT15_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12e";
    constant REG_OH_LINKS_OH0_VFAT15_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT15_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT15_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"12e";
    constant REG_OH_LINKS_OH0_VFAT15_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT15_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT16_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"130";
    constant REG_OH_LINKS_OH0_VFAT16_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT16_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"130";
    constant REG_OH_LINKS_OH0_VFAT16_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT16_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT16_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"130";
    constant REG_OH_LINKS_OH0_VFAT16_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT16_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT16_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"130";
    constant REG_OH_LINKS_OH0_VFAT16_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT16_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT17_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"132";
    constant REG_OH_LINKS_OH0_VFAT17_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT17_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"132";
    constant REG_OH_LINKS_OH0_VFAT17_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT17_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT17_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"132";
    constant REG_OH_LINKS_OH0_VFAT17_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT17_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT17_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"132";
    constant REG_OH_LINKS_OH0_VFAT17_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT17_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT18_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"134";
    constant REG_OH_LINKS_OH0_VFAT18_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT18_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"134";
    constant REG_OH_LINKS_OH0_VFAT18_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT18_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT18_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"134";
    constant REG_OH_LINKS_OH0_VFAT18_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT18_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT18_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"134";
    constant REG_OH_LINKS_OH0_VFAT18_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT18_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT19_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"136";
    constant REG_OH_LINKS_OH0_VFAT19_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT19_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"136";
    constant REG_OH_LINKS_OH0_VFAT19_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT19_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT19_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"136";
    constant REG_OH_LINKS_OH0_VFAT19_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT19_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT19_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"136";
    constant REG_OH_LINKS_OH0_VFAT19_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT19_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT20_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"138";
    constant REG_OH_LINKS_OH0_VFAT20_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT20_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"138";
    constant REG_OH_LINKS_OH0_VFAT20_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT20_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT20_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"138";
    constant REG_OH_LINKS_OH0_VFAT20_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT20_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT20_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"138";
    constant REG_OH_LINKS_OH0_VFAT20_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT20_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT21_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13a";
    constant REG_OH_LINKS_OH0_VFAT21_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT21_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13a";
    constant REG_OH_LINKS_OH0_VFAT21_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT21_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT21_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13a";
    constant REG_OH_LINKS_OH0_VFAT21_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT21_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT21_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13a";
    constant REG_OH_LINKS_OH0_VFAT21_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT21_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT22_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13c";
    constant REG_OH_LINKS_OH0_VFAT22_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT22_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13c";
    constant REG_OH_LINKS_OH0_VFAT22_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT22_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT22_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13c";
    constant REG_OH_LINKS_OH0_VFAT22_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT22_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT22_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13c";
    constant REG_OH_LINKS_OH0_VFAT22_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT22_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH0_VFAT23_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13e";
    constant REG_OH_LINKS_OH0_VFAT23_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH0_VFAT23_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13e";
    constant REG_OH_LINKS_OH0_VFAT23_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH0_VFAT23_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH0_VFAT23_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13e";
    constant REG_OH_LINKS_OH0_VFAT23_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH0_VFAT23_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH0_VFAT23_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"13e";
    constant REG_OH_LINKS_OH0_VFAT23_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH0_VFAT23_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_GBT0_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT0_READY_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_GBT1_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT1_READY_BIT    : integer := 1;

    constant REG_OH_LINKS_OH1_GBT2_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT2_READY_BIT    : integer := 2;

    constant REG_OH_LINKS_OH1_GBT0_WAS_NOT_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT0_WAS_NOT_READY_BIT    : integer := 3;

    constant REG_OH_LINKS_OH1_GBT1_WAS_NOT_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT1_WAS_NOT_READY_BIT    : integer := 4;

    constant REG_OH_LINKS_OH1_GBT2_WAS_NOT_READY_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT2_WAS_NOT_READY_BIT    : integer := 5;

    constant REG_OH_LINKS_OH1_GBT0_RX_HAD_OVERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT0_RX_HAD_OVERFLOW_BIT    : integer := 6;

    constant REG_OH_LINKS_OH1_GBT1_RX_HAD_OVERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT1_RX_HAD_OVERFLOW_BIT    : integer := 7;

    constant REG_OH_LINKS_OH1_GBT2_RX_HAD_OVERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT2_RX_HAD_OVERFLOW_BIT    : integer := 8;

    constant REG_OH_LINKS_OH1_GBT0_RX_HAD_UNDERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT0_RX_HAD_UNDERFLOW_BIT    : integer := 9;

    constant REG_OH_LINKS_OH1_GBT1_RX_HAD_UNDERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT1_RX_HAD_UNDERFLOW_BIT    : integer := 10;

    constant REG_OH_LINKS_OH1_GBT2_RX_HAD_UNDERFLOW_ADDR    : std_logic_vector(12 downto 0) := '0' & x"200";
    constant REG_OH_LINKS_OH1_GBT2_RX_HAD_UNDERFLOW_BIT    : integer := 11;

    constant REG_OH_LINKS_OH1_VFAT_MASK_ADDR    : std_logic_vector(12 downto 0) := '0' & x"201";
    constant REG_OH_LINKS_OH1_VFAT_MASK_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT_MASK_LSB     : integer := 0;
    constant REG_OH_LINKS_OH1_VFAT_MASK_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_OH_LINKS_OH1_VFAT0_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"210";
    constant REG_OH_LINKS_OH1_VFAT0_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT0_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"210";
    constant REG_OH_LINKS_OH1_VFAT0_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT0_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT0_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"210";
    constant REG_OH_LINKS_OH1_VFAT0_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT0_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT0_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"210";
    constant REG_OH_LINKS_OH1_VFAT0_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT0_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT1_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"212";
    constant REG_OH_LINKS_OH1_VFAT1_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT1_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"212";
    constant REG_OH_LINKS_OH1_VFAT1_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT1_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT1_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"212";
    constant REG_OH_LINKS_OH1_VFAT1_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT1_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT1_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"212";
    constant REG_OH_LINKS_OH1_VFAT1_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT1_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT2_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"214";
    constant REG_OH_LINKS_OH1_VFAT2_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT2_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"214";
    constant REG_OH_LINKS_OH1_VFAT2_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT2_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT2_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"214";
    constant REG_OH_LINKS_OH1_VFAT2_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT2_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT2_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"214";
    constant REG_OH_LINKS_OH1_VFAT2_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT2_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT3_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"216";
    constant REG_OH_LINKS_OH1_VFAT3_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT3_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"216";
    constant REG_OH_LINKS_OH1_VFAT3_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT3_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT3_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"216";
    constant REG_OH_LINKS_OH1_VFAT3_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT3_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT3_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"216";
    constant REG_OH_LINKS_OH1_VFAT3_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT3_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT4_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"218";
    constant REG_OH_LINKS_OH1_VFAT4_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT4_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"218";
    constant REG_OH_LINKS_OH1_VFAT4_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT4_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT4_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"218";
    constant REG_OH_LINKS_OH1_VFAT4_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT4_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT4_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"218";
    constant REG_OH_LINKS_OH1_VFAT4_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT4_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT5_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21a";
    constant REG_OH_LINKS_OH1_VFAT5_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT5_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21a";
    constant REG_OH_LINKS_OH1_VFAT5_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT5_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT5_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21a";
    constant REG_OH_LINKS_OH1_VFAT5_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT5_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT5_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21a";
    constant REG_OH_LINKS_OH1_VFAT5_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT5_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT6_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21c";
    constant REG_OH_LINKS_OH1_VFAT6_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT6_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21c";
    constant REG_OH_LINKS_OH1_VFAT6_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT6_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT6_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21c";
    constant REG_OH_LINKS_OH1_VFAT6_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT6_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT6_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21c";
    constant REG_OH_LINKS_OH1_VFAT6_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT6_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT7_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21e";
    constant REG_OH_LINKS_OH1_VFAT7_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT7_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21e";
    constant REG_OH_LINKS_OH1_VFAT7_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT7_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT7_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21e";
    constant REG_OH_LINKS_OH1_VFAT7_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT7_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT7_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"21e";
    constant REG_OH_LINKS_OH1_VFAT7_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT7_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT8_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"220";
    constant REG_OH_LINKS_OH1_VFAT8_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT8_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"220";
    constant REG_OH_LINKS_OH1_VFAT8_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT8_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT8_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"220";
    constant REG_OH_LINKS_OH1_VFAT8_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT8_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT8_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"220";
    constant REG_OH_LINKS_OH1_VFAT8_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT8_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT9_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"222";
    constant REG_OH_LINKS_OH1_VFAT9_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT9_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"222";
    constant REG_OH_LINKS_OH1_VFAT9_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT9_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT9_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"222";
    constant REG_OH_LINKS_OH1_VFAT9_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT9_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT9_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"222";
    constant REG_OH_LINKS_OH1_VFAT9_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT9_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT10_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"224";
    constant REG_OH_LINKS_OH1_VFAT10_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT10_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"224";
    constant REG_OH_LINKS_OH1_VFAT10_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT10_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT10_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"224";
    constant REG_OH_LINKS_OH1_VFAT10_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT10_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT10_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"224";
    constant REG_OH_LINKS_OH1_VFAT10_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT10_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT11_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"226";
    constant REG_OH_LINKS_OH1_VFAT11_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT11_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"226";
    constant REG_OH_LINKS_OH1_VFAT11_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT11_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT11_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"226";
    constant REG_OH_LINKS_OH1_VFAT11_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT11_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT11_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"226";
    constant REG_OH_LINKS_OH1_VFAT11_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT11_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT12_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"228";
    constant REG_OH_LINKS_OH1_VFAT12_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT12_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"228";
    constant REG_OH_LINKS_OH1_VFAT12_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT12_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT12_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"228";
    constant REG_OH_LINKS_OH1_VFAT12_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT12_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT12_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"228";
    constant REG_OH_LINKS_OH1_VFAT12_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT12_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT13_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22a";
    constant REG_OH_LINKS_OH1_VFAT13_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT13_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22a";
    constant REG_OH_LINKS_OH1_VFAT13_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT13_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT13_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22a";
    constant REG_OH_LINKS_OH1_VFAT13_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT13_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT13_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22a";
    constant REG_OH_LINKS_OH1_VFAT13_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT13_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT14_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22c";
    constant REG_OH_LINKS_OH1_VFAT14_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT14_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22c";
    constant REG_OH_LINKS_OH1_VFAT14_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT14_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT14_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22c";
    constant REG_OH_LINKS_OH1_VFAT14_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT14_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT14_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22c";
    constant REG_OH_LINKS_OH1_VFAT14_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT14_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT15_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22e";
    constant REG_OH_LINKS_OH1_VFAT15_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT15_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22e";
    constant REG_OH_LINKS_OH1_VFAT15_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT15_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT15_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22e";
    constant REG_OH_LINKS_OH1_VFAT15_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT15_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT15_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"22e";
    constant REG_OH_LINKS_OH1_VFAT15_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT15_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT16_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"230";
    constant REG_OH_LINKS_OH1_VFAT16_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT16_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"230";
    constant REG_OH_LINKS_OH1_VFAT16_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT16_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT16_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"230";
    constant REG_OH_LINKS_OH1_VFAT16_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT16_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT16_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"230";
    constant REG_OH_LINKS_OH1_VFAT16_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT16_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT17_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"232";
    constant REG_OH_LINKS_OH1_VFAT17_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT17_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"232";
    constant REG_OH_LINKS_OH1_VFAT17_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT17_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT17_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"232";
    constant REG_OH_LINKS_OH1_VFAT17_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT17_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT17_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"232";
    constant REG_OH_LINKS_OH1_VFAT17_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT17_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT18_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"234";
    constant REG_OH_LINKS_OH1_VFAT18_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT18_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"234";
    constant REG_OH_LINKS_OH1_VFAT18_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT18_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT18_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"234";
    constant REG_OH_LINKS_OH1_VFAT18_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT18_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT18_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"234";
    constant REG_OH_LINKS_OH1_VFAT18_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT18_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT19_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"236";
    constant REG_OH_LINKS_OH1_VFAT19_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT19_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"236";
    constant REG_OH_LINKS_OH1_VFAT19_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT19_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT19_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"236";
    constant REG_OH_LINKS_OH1_VFAT19_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT19_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT19_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"236";
    constant REG_OH_LINKS_OH1_VFAT19_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT19_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT20_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"238";
    constant REG_OH_LINKS_OH1_VFAT20_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT20_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"238";
    constant REG_OH_LINKS_OH1_VFAT20_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT20_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT20_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"238";
    constant REG_OH_LINKS_OH1_VFAT20_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT20_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT20_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"238";
    constant REG_OH_LINKS_OH1_VFAT20_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT20_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT21_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23a";
    constant REG_OH_LINKS_OH1_VFAT21_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT21_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23a";
    constant REG_OH_LINKS_OH1_VFAT21_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT21_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT21_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23a";
    constant REG_OH_LINKS_OH1_VFAT21_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT21_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT21_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23a";
    constant REG_OH_LINKS_OH1_VFAT21_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT21_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT22_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23c";
    constant REG_OH_LINKS_OH1_VFAT22_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT22_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23c";
    constant REG_OH_LINKS_OH1_VFAT22_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT22_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT22_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23c";
    constant REG_OH_LINKS_OH1_VFAT22_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT22_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT22_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23c";
    constant REG_OH_LINKS_OH1_VFAT22_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT22_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;

    constant REG_OH_LINKS_OH1_VFAT23_LINK_GOOD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23e";
    constant REG_OH_LINKS_OH1_VFAT23_LINK_GOOD_BIT    : integer := 0;

    constant REG_OH_LINKS_OH1_VFAT23_SYNC_ERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23e";
    constant REG_OH_LINKS_OH1_VFAT23_SYNC_ERR_CNT_MSB    : integer := 7;
    constant REG_OH_LINKS_OH1_VFAT23_SYNC_ERR_CNT_LSB     : integer := 4;

    constant REG_OH_LINKS_OH1_VFAT23_DAQ_EVENT_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23e";
    constant REG_OH_LINKS_OH1_VFAT23_DAQ_EVENT_CNT_MSB    : integer := 15;
    constant REG_OH_LINKS_OH1_VFAT23_DAQ_EVENT_CNT_LSB     : integer := 8;

    constant REG_OH_LINKS_OH1_VFAT23_DAQ_CRC_ERROR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"23e";
    constant REG_OH_LINKS_OH1_VFAT23_DAQ_CRC_ERROR_CNT_MSB    : integer := 23;
    constant REG_OH_LINKS_OH1_VFAT23_DAQ_CRC_ERROR_CNT_LSB     : integer := 16;


    --============================================================================
    --       >>> SLOW_CONTROL Module <<<    base address: 0x00b00000
    --
    -- This module is handling slow control (mainly OH SCA and OH GBTx IC related
    -- communication)
    --============================================================================

    constant REG_SLOW_CONTROL_NUM_REGS : integer := 53;
    constant REG_SLOW_CONTROL_ADDRESS_MSB : integer := 16;
    constant REG_SLOW_CONTROL_ADDRESS_LSB : integer := 0;
    constant REG_SLOW_CONTROL_SCA_CTRL_MODULE_RESET_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0000";
    constant REG_SLOW_CONTROL_SCA_CTRL_MODULE_RESET_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_CTRL_MODULE_RESET_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_CTRL_OH_FPGA_HARD_RESET_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0001";
    constant REG_SLOW_CONTROL_SCA_CTRL_OH_FPGA_HARD_RESET_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_CTRL_OH_FPGA_HARD_RESET_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0002";
    constant REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_BIT    : integer := 0;
    constant REG_SLOW_CONTROL_SCA_CTRL_TTC_HARD_RESET_EN_DEFAULT : std_logic := '1';

    constant REG_SLOW_CONTROL_SCA_STATUS_READY_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0100";
    constant REG_SLOW_CONTROL_SCA_STATUS_READY_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_STATUS_READY_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0101";
    constant REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_STATUS_CRITICAL_ERROR_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0102";
    constant REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH0_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH1_ADDR    : std_logic_vector(16 downto 0) := '0' & x"0103";
    constant REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH1_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_SCA_STATUS_NOT_READY_CNT_OH1_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1000";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_LINK_ENABLE_MASK_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1001";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_MSB    : integer := 7;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_CHANNEL_DEFAULT : std_logic_vector(7 downto 0) := x"00";

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1001";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_LSB     : integer := 8;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_COMMAND_DEFAULT : std_logic_vector(15 downto 8) := x"00";

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1001";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_LSB     : integer := 16;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_LENGTH_DEFAULT : std_logic_vector(23 downto 16) := x"00";

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1002";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_DATA_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_EXECUTE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1003";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_EXECUTE_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_CMD_SCA_CMD_EXECUTE_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1004";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_MSB    : integer := 7;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_CHANNEL_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1004";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_ERROR_LSB     : integer := 8;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1004";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_LENGTH_LSB     : integer := 16;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1005";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH0_SCA_RPY_DATA_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_CHANNEL_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1006";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_CHANNEL_MSB    : integer := 7;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_CHANNEL_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_ERROR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1006";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_ERROR_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_ERROR_LSB     : integer := 8;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_LENGTH_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1006";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_LENGTH_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_LENGTH_LSB     : integer := 16;

    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_DATA_ADDR    : std_logic_vector(16 downto 0) := '0' & x"1007";
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_DATA_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_MANUAL_CONTROL_SCA_REPLY_OH1_SCA_RPY_DATA_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2000";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_MONITORING_OFF_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2001";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVCCN_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2001";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_AVTTN_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2002";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V0_INT_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2002";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8F_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2003";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V5_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2003";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_2V5_IO_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2004";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_3V0_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2004";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_1V8_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2005";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI2_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2005";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_VTRX_RSSI1_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2006";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_SCA_TEMP_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2006";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP1_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2007";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP2_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2007";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP3_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2008";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP4_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2008";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP5_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2009";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP6_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2009";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP7_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_ADDR    : std_logic_vector(16 downto 0) := '0' & x"200a";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP8_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_ADDR    : std_logic_vector(16 downto 0) := '0' & x"200a";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH0_BOARD_TEMP9_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVCCN_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2010";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVCCN_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVCCN_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVTTN_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2010";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVTTN_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_AVTTN_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V0_INT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2011";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V0_INT_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V0_INT_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8F_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2011";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8F_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8F_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V5_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2012";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V5_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V5_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_2V5_IO_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2012";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_2V5_IO_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_2V5_IO_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_3V0_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2013";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_3V0_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_3V0_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2013";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_1V8_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI2_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2014";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI2_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI2_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI1_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2014";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI1_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_VTRX_RSSI1_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_SCA_TEMP_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2015";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_SCA_TEMP_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_SCA_TEMP_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP1_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2015";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP1_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP1_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP2_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2016";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP2_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP2_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP3_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2016";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP3_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP3_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP4_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2017";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP4_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP4_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP5_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2017";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP5_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP5_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP6_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2018";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP6_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP6_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP7_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2018";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP7_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP7_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP8_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2019";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP8_MSB    : integer := 11;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP8_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP9_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2019";
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP9_MSB    : integer := 23;
    constant REG_SLOW_CONTROL_SCA_ADC_MONITORING_OH1_BOARD_TEMP9_LSB     : integer := 12;

    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2500";
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_ENABLE_MASK_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2501";
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_BIT    : integer := 1;
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_SHIFT_MSB_DEFAULT : std_logic := '0';

    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2501";
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_BIT    : integer := 2;
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_EXEC_ON_EVERY_TDO_DEFAULT : std_logic := '0';

    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2501";
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_BIT    : integer := 3;
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_NO_SCA_LENGTH_UPDATE_DEFAULT : std_logic := '0';

    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2501";
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_BIT    : integer := 4;
    constant REG_SLOW_CONTROL_SCA_JTAG_CTRL_EXPERT_SHIFT_TDO_ASYNC_DEFAULT : std_logic := '0';

    constant REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2502";
    constant REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_MSB    : integer := 6;
    constant REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_JTAG_NUM_BITS_DEFAULT : std_logic_vector(6 downto 0) := "000" & x"0";

    constant REG_SLOW_CONTROL_SCA_JTAG_TMS_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2503";
    constant REG_SLOW_CONTROL_SCA_JTAG_TMS_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_JTAG_TMS_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_JTAG_TMS_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_SCA_JTAG_TDO_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2504";
    constant REG_SLOW_CONTROL_SCA_JTAG_TDO_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_JTAG_TDO_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_SCA_JTAG_TDO_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2505";
    constant REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_JTAG_TDI_OH0_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_SCA_JTAG_TDI_OH1_ADDR    : std_logic_vector(16 downto 0) := '0' & x"2506";
    constant REG_SLOW_CONTROL_SCA_JTAG_TDI_OH1_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_SCA_JTAG_TDI_OH1_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_IC_ADDRESS_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3000";
    constant REG_SLOW_CONTROL_IC_ADDRESS_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_IC_ADDRESS_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_IC_ADDRESS_DEFAULT : std_logic_vector(15 downto 0) := x"0000";

    constant REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3001";
    constant REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_MSB    : integer := 2;
    constant REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_IC_READ_WRITE_LENGTH_DEFAULT : std_logic_vector(2 downto 0) := "001";

    constant REG_SLOW_CONTROL_IC_WRITE_DATA_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3002";
    constant REG_SLOW_CONTROL_IC_WRITE_DATA_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_IC_WRITE_DATA_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_IC_WRITE_DATA_DEFAULT : std_logic_vector(31 downto 0) := x"00000000";

    constant REG_SLOW_CONTROL_IC_EXECUTE_WRITE_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3003";
    constant REG_SLOW_CONTROL_IC_EXECUTE_WRITE_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_IC_EXECUTE_WRITE_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_IC_EXECUTE_READ_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3004";
    constant REG_SLOW_CONTROL_IC_EXECUTE_READ_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_IC_EXECUTE_READ_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3005";
    constant REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_MSB    : integer := 3;
    constant REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_IC_GBTX_I2C_ADDR_DEFAULT : std_logic_vector(3 downto 0) := x"1";

    constant REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"3006";
    constant REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_MSB    : integer := 5;
    constant REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_LSB     : integer := 0;
    constant REG_SLOW_CONTROL_IC_GBTX_LINK_SELECT_DEFAULT : std_logic_vector(5 downto 0) := "00" & x"0";

    constant REG_SLOW_CONTROL_VFAT3_CRC_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"4000";
    constant REG_SLOW_CONTROL_VFAT3_CRC_ERROR_CNT_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_VFAT3_CRC_ERROR_CNT_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_VFAT3_PACKET_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"4000";
    constant REG_SLOW_CONTROL_VFAT3_PACKET_ERROR_CNT_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_VFAT3_PACKET_ERROR_CNT_LSB     : integer := 16;

    constant REG_SLOW_CONTROL_VFAT3_BITSTUFFING_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"4001";
    constant REG_SLOW_CONTROL_VFAT3_BITSTUFFING_ERROR_CNT_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_VFAT3_BITSTUFFING_ERROR_CNT_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_VFAT3_TIMEOUT_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"4001";
    constant REG_SLOW_CONTROL_VFAT3_TIMEOUT_ERROR_CNT_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_VFAT3_TIMEOUT_ERROR_CNT_LSB     : integer := 16;

    constant REG_SLOW_CONTROL_VFAT3_AXI_STROBE_ERROR_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"4002";
    constant REG_SLOW_CONTROL_VFAT3_AXI_STROBE_ERROR_CNT_MSB    : integer := 15;
    constant REG_SLOW_CONTROL_VFAT3_AXI_STROBE_ERROR_CNT_LSB     : integer := 0;

    constant REG_SLOW_CONTROL_VFAT3_TRANSACTION_CNT_ADDR    : std_logic_vector(16 downto 0) := '0' & x"4002";
    constant REG_SLOW_CONTROL_VFAT3_TRANSACTION_CNT_MSB    : integer := 31;
    constant REG_SLOW_CONTROL_VFAT3_TRANSACTION_CNT_LSB     : integer := 16;


end registers;
