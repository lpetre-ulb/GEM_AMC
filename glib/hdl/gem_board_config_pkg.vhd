-------------------------------------------------------------------------------
--
--       Unit Name: gem_board_config_package
--
--     Description: Configuration for GLIB board
--
--
-------------------------------------------------------------------------------
--
--           Notes:
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                         Package declaration
--============================================================================
package gem_board_config_package is

    function get_num_gbts_per_oh(gem_station : integer) return integer;
    function get_num_vfats_per_oh(gem_station : integer) return integer;

    ----------------------------------------------------------------------------------------------

    constant CFG_GEM_STATION        : integer range 0 to 2 := 1; -- 0 = ME0; 1 = GE1/1; 2 = GE2/1
    constant CFG_NUM_OF_OHs         : integer := 2;   -- total number of OHs to instanciate (remember to adapt the CFG_OH_LINK_CONFIG_ARR accordingly)
    constant CFG_NUM_GBTS_PER_OH    : integer := get_num_gbts_per_oh(CFG_GEM_STATION);
    constant CFG_NUM_VFATS_PER_OH   : integer := get_num_vfats_per_oh(CFG_GEM_STATION);

    constant CFG_USE_TRIG_TX_LINKS  : boolean := false; -- if true, then trigger transmitters will be instantiated (used to connect to EMTF)
    constant CFG_NUM_TRIG_TX        : integer := 12; -- number of trigger transmitters used to connect to EMTF

    constant CFG_GBT_DEBUG          : boolean := false; -- if set to true, an ILA will be instantiated which allows probing any GBT link
    constant CFG_BOARD_TYPE         : std_logic_vector(3 downto 0) := x"0"; -- 0 = GLIB; 1 = CTP7

    ------------ DEBUG FLAGS ------------
    constant CFG_USE_CHIPSCOPE              : boolean := false; -- setting this to true will instantiate ILA and VIO cores for debugging
    constant CFG_LPGBT_2P56G_LOOPBACK_TEST  : boolean := false; -- setting this to true will result in a test firmware with 2.56Gbps transceivers only usable for PRBS loopback tests with LpGBT chip, note that none of the GEM logic will be included (also no LpGBT core will be instantiated)
    constant CFG_ILA_GBT0_MGT_EN            : boolean := false; -- setting this to 1 enables the instantiation of ILA on GBT link 0 MGT

    --========================--
    --== Link configuration ==--
    --========================--

    -- defines the GT index for each type of OH link
    type t_oh_link_config is record
        gbt0_link       : integer range 0 to 79; -- main GBT link on OH v2b
        gbt1_link       : integer range 0 to 79; -- with OH v2b this is just for test, this will be needed with OH v3
        gbt2_link       : integer range 0 to 79; -- with OH v2b this is just for test, this will be needed with OH v3
        trig0_rx_link   : integer range 0 to 79; -- trigger RX link for clusters 0, 1, 2, 3
        trig1_rx_link   : integer range 0 to 79; -- trigger RX link for clusters 4, 5, 6, 7
    end record t_oh_link_config;

    type t_oh_link_config_arr is array (0 to CFG_NUM_OF_OHs - 1) of t_oh_link_config;

--    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
--        (0, 1, 2, 24, 25),
--        (3, 4, 5, 26, 27)
--    );

--    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
--        (0, 1, 2, 24, 25),
--        (3, 4, 5, 26, 27),
--        (6, 7, 8, 28, 29),
--        (9, 10, 11, 30, 31)
--    );

--    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
--        (0, 1, 2, 40, 41),
--        (3, 4, 5, 42, 43),
--        (6, 7, 8, 44, 45),
--        (9, 10, 11, 46, 47),
--
--        (12, 13, 14, 48, 49),
--        (15, 16, 17, 50, 51),
--        (18, 19, 20, 52, 53),
--        (21, 22, 23, 54, 55),
--
--        (24, 25, 26, 56, 57),
--        (27, 28, 29, 58, 59),
--        (30, 31, 32, 68, 69),
--        (33, 34, 35, 70, 71)
--    );

    -- this record is used in CXP fiber to GTH map (holding tx and rx GTH index)
    type t_cxp_fiber_to_gth_link is record
        tx      : integer range 0 to 67; -- GTH TX index (#67 means disconnected/non-existing)
        rx      : integer range 0 to 67; -- GTH RX index (#67 means disconnected/non-existing)
    end record;

    -- this array is meant to hold mapping from CXP fiber index to GTH TX and RX indexes
    -- type t_cxp_fiber_to_gth_link_map is array (0 to 71) of t_cxp_fiber_to_gth_link;

    -- defines the GTH TX and RX index for each index of the CXP and MP fiber
    -- CXP0: fibers 0-11
    -- CXP1: fibers 12-23
    -- CXP2: fibers 24-35
    -- MP0 RX: fibers 36-47
    -- MP1 RX: fibers 48-59
    -- MP TX : fibers 48-59
    -- MP2 RX: fibers 60-71
    -- note that GTH channel #67 is used as a placeholder for fiber links that are not connected to the FPGA
    -- constant CFG_CXP_FIBER_TO_GTH_MAP : t_cxp_fiber_to_gth_link_map := (
    --     --=== CXP0 ===--
    --     (1, 2), -- fiber 0
    --     (3, 0), -- fiber 1
    --     (5, 4), -- fiber 2
    --     (0, 3), -- fiber 3
    --     (2, 5), -- fiber 4
    --     (4, 1), -- fiber 5
    --     (10, 7), -- fiber 6
    --     (8, 9), -- fiber 7
    --     (6, 10), -- fiber 8
    --     (11, 6), -- fiber 9
    --     (9, 8), -- fiber 10
    --     (7, 11), -- fiber 11
    -- );

end gem_board_config_package;

package body gem_board_config_package is

    function get_num_gbts_per_oh(gem_station : integer) return integer is
    begin
        if gem_station = 0 then
            return 2;
        elsif gem_station = 1 then
            return 3;
        elsif gem_station = 2 then
            return 2;
        else -- hmm whatever, lets say 3
            return 3;  
        end if;
    end function get_num_gbts_per_oh;
    
    function get_num_vfats_per_oh(gem_station : integer) return integer is
    begin
        if gem_station = 0 then
            return 6;
        elsif gem_station = 1 then
            return 24;
        elsif gem_station = 2 then
            return 12;
        else -- hmm whatever, lets say 24
            return 24;  
        end if;
    end function get_num_vfats_per_oh;
    
    function get_oh_link_config_arr(gem_station: integer; ge11_config, ge21_config, me0_config : t_oh_link_config_arr) return t_oh_link_config_arr is
    begin
        if gem_station = 0 then
            return me0_config;
        elsif gem_station = 1 then
            return ge11_config;
        elsif gem_station = 2 then
            return ge21_config;
        else -- hmm whatever, lets say GE1/1
            return ge11_config;  
        end if;
    end function get_oh_link_config_arr;
    
end gem_board_config_package;
--============================================================================
--                                                                 Package end 
--============================================================================
