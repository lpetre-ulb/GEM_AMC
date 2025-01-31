------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    15:04 2016-05-10
-- Module Name:    GEM System Registers
-- Description:    this module provides registers for GEM system-wide setting  
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.gem_pkg.all;
use work.registers.all;
use work.ttc_pkg.all;
use work.gem_board_config_package.all;

entity gem_system_regs is
port(
    
    reset_i                     : in std_logic;

    ttc_clks_i                  : in t_ttc_clks;

    ipb_clk_i                   : in std_logic;
    ipb_reset_i                 : in std_logic;
    
    ipb_mosi_i                  : in ipb_wbus;
    ipb_miso_o                  : out ipb_rbus;
    
    board_id_o                  : out std_logic_vector(15 downto 0);

    loopback_gbt_test_en_o      : out std_logic;
    use_v3b_elink_mapping_o     : out std_logic;

    vfat3_sc_only_mode_o        : out std_logic;
    manual_link_reset_o         : out std_logic 
);
end gem_system_regs;

architecture gem_system_regs_arch of gem_system_regs is

    signal reset_cnt                : std_logic := '0';
    
    signal board_id                 : std_logic_vector(15 downto 0) := (others => '0');
    signal gem_station              : integer range 0 to 2;
    signal version_major            : integer range 0 to 255; 
    signal version_minor            : integer range 0 to 255; 
    signal version_build            : integer range 0 to 255;
    signal firmware_date            : std_logic_vector(31 downto 0);
    signal num_of_oh                : std_logic_vector(4 downto 0);
    signal board_type               : std_logic_vector(3 downto 0);
    
    signal loopback_gbt_test_en     : std_logic;
    
    signal vfat3_sc_only_mode       : std_logic;
    
    signal use_v3b_elink_mapping    : std_logic;

    --== LEGACY Firmware date and version (taken from GLIB) ==--
    -- TODO: remove legacy firmware date and version once the software is ready 
    constant c_legacy_sys_ver_year :integer range 0 to 99 :=17;
    constant c_legacy_sys_ver_month:integer range 0 to 12 :=05;
    constant c_legacy_sys_ver_day  :integer range 0 to 31 :=23;
    constant c_legacy_board_id     : std_logic_vector(31 downto 0) := x"474c4942"; -- GLIB
    constant c_legacy_sys_id       : std_logic_vector(31 downto 0) := x"32307631"; -- '2_0_v1'
    
    signal legacy_board_id     : std_logic_vector(31 downto 0);
    signal legacy_sys_id       : std_logic_vector(31 downto 0);
    signal legacy_fw_version   : std_logic_vector(31 downto 0);

    ------ Register signals begin (this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_GEM_SYSTEM_NUM_REGS - 1 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------
    
begin

    --=== version and date === --
    
    firmware_date <= C_FIRMWARE_DATE;
    version_major <= C_FIRMWARE_MAJOR;
    version_minor <= C_FIRMWARE_MINOR;
    version_build <= C_FIRMWARE_BUILD;
    gem_station <= CFG_GEM_STATION;

    --=== board type and configuration parameters ===--
    board_type     <= CFG_BOARD_TYPE;
    num_of_oh      <= std_logic_vector(to_unsigned(CFG_NUM_OF_OHs, 5));
    
    --=== version and date === --
    -- TODO: remove legacy firmware date and version once the software is ready
    legacy_board_id      <= c_legacy_board_id;
    legacy_sys_id        <= c_legacy_sys_id;
    legacy_fw_version    <= std_logic_vector(to_unsigned(version_major, 4)) &
                            std_logic_vector(to_unsigned(version_minor, 4)) &
                            std_logic_vector(to_unsigned(version_build, 8)) &
                            std_logic_vector(to_unsigned(c_legacy_sys_ver_year, 7)) &
                            std_logic_vector(to_unsigned(c_legacy_sys_ver_month, 4)) &
                            std_logic_vector(to_unsigned(c_legacy_sys_ver_day, 5));
            
    --=== Tests === --
    loopback_gbt_test_en_o <= loopback_gbt_test_en; 
    
    vfat3_sc_only_mode_o <= vfat3_sc_only_mode;
    use_v3b_elink_mapping_o <= use_v3b_elink_mapping;

    --===============================================================================================
    -- this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py (do not edit) 
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_GEM_SYSTEM_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_GEM_SYSTEM_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_GEM_SYSTEM_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => ipb_clk_i,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => ttc_clks_i.clk_40,
           regs_read_arr_i        => regs_read_arr,
           regs_write_arr_o       => regs_write_arr,
           read_pulse_arr_o       => regs_read_pulse_arr,
           write_pulse_arr_o      => regs_write_pulse_arr,
           regs_read_ready_arr_i  => regs_read_ready_arr,
           regs_write_done_arr_i  => regs_write_done_arr,
           individual_addrs_arr_i => regs_addresses,
           regs_defaults_arr_i    => regs_defaults,
           writable_regs_i        => regs_writable_arr
      );

    -- Addresses
    regs_addresses(0)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0002";
    regs_addresses(1)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0003";
    regs_addresses(2)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0004";
    regs_addresses(3)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0005";
    regs_addresses(4)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0011";
    regs_addresses(5)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0100";
    regs_addresses(6)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0101";
    regs_addresses(7)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '0' & x"0200";
    regs_addresses(8)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '1' & x"0000";
    regs_addresses(9)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '1' & x"0001";
    regs_addresses(10)(REG_GEM_SYSTEM_ADDRESS_MSB downto REG_GEM_SYSTEM_ADDRESS_LSB) <= '1' & x"0002";

    -- Connect read signals
    regs_read_arr(0)(REG_GEM_SYSTEM_BOARD_ID_MSB downto REG_GEM_SYSTEM_BOARD_ID_LSB) <= board_id;
    regs_read_arr(0)(REG_GEM_SYSTEM_BOARD_TYPE_MSB downto REG_GEM_SYSTEM_BOARD_TYPE_LSB) <= board_type;
    regs_read_arr(1)(REG_GEM_SYSTEM_RELEASE_BUILD_MSB downto REG_GEM_SYSTEM_RELEASE_BUILD_LSB) <= std_logic_vector(to_unsigned(version_build, 8));
    regs_read_arr(1)(REG_GEM_SYSTEM_RELEASE_MINOR_MSB downto REG_GEM_SYSTEM_RELEASE_MINOR_LSB) <= std_logic_vector(to_unsigned(version_minor, 8));
    regs_read_arr(1)(REG_GEM_SYSTEM_RELEASE_MAJOR_MSB downto REG_GEM_SYSTEM_RELEASE_MAJOR_LSB) <= std_logic_vector(to_unsigned(version_major, 8));
    regs_read_arr(1)(REG_GEM_SYSTEM_RELEASE_GEM_STATION_MSB downto REG_GEM_SYSTEM_RELEASE_GEM_STATION_LSB) <= std_logic_vector(to_unsigned(gem_station, 2));
    regs_read_arr(2)(REG_GEM_SYSTEM_RELEASE_DATE_MSB downto REG_GEM_SYSTEM_RELEASE_DATE_LSB) <= firmware_date;
    regs_read_arr(3)(REG_GEM_SYSTEM_CONFIG_NUM_OF_OH_MSB downto REG_GEM_SYSTEM_CONFIG_NUM_OF_OH_LSB) <= num_of_oh;
    regs_read_arr(4)(REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_BIT) <= vfat3_sc_only_mode;
    regs_read_arr(4)(REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_BIT) <= use_v3b_elink_mapping;
    regs_read_arr(7)(REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_BIT) <= loopback_gbt_test_en;
    regs_read_arr(8)(REG_GEM_SYSTEM_LEGACY_SYSTEM_BOARD_ID_MSB downto REG_GEM_SYSTEM_LEGACY_SYSTEM_BOARD_ID_LSB) <= legacy_board_id;
    regs_read_arr(9)(REG_GEM_SYSTEM_LEGACY_SYSTEM_SYSTEM_ID_MSB downto REG_GEM_SYSTEM_LEGACY_SYSTEM_SYSTEM_ID_LSB) <= legacy_sys_id;
    regs_read_arr(10)(REG_GEM_SYSTEM_LEGACY_SYSTEM_FIRMWARE_VERSION_MSB downto REG_GEM_SYSTEM_LEGACY_SYSTEM_FIRMWARE_VERSION_LSB) <= legacy_fw_version;

    -- Connect write signals
    board_id <= regs_write_arr(0)(REG_GEM_SYSTEM_BOARD_ID_MSB downto REG_GEM_SYSTEM_BOARD_ID_LSB);
    vfat3_sc_only_mode <= regs_write_arr(4)(REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_BIT);
    use_v3b_elink_mapping <= regs_write_arr(4)(REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_BIT);
    loopback_gbt_test_en <= regs_write_arr(7)(REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_BIT);

    -- Connect write pulse signals
    reset_cnt <= regs_write_pulse_arr(5);
    manual_link_reset_o <= regs_write_pulse_arr(6);

    -- Connect write done signals

    -- Connect read pulse signals

    -- Connect read ready signals

    -- Defaults
    regs_defaults(0)(REG_GEM_SYSTEM_BOARD_ID_MSB downto REG_GEM_SYSTEM_BOARD_ID_LSB) <= REG_GEM_SYSTEM_BOARD_ID_DEFAULT;
    regs_defaults(4)(REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_BIT) <= REG_GEM_SYSTEM_VFAT3_SC_ONLY_MODE_DEFAULT;
    regs_defaults(4)(REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_BIT) <= REG_GEM_SYSTEM_VFAT3_USE_OH_V3B_MAPPING_DEFAULT;
    regs_defaults(7)(REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_BIT) <= REG_GEM_SYSTEM_TESTS_GBT_LOOPBACK_EN_DEFAULT;

    -- Define writable regs
    regs_writable_arr(0) <= '1';
    regs_writable_arr(4) <= '1';
    regs_writable_arr(7) <= '1';

    --==== Registers end ============================================================================

end gem_system_regs_arch;