-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: gem_board_config_package
--                                                                            
--     Description: Configuration for CTP7 board
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

    constant CFG_BOARD_TYPE     : std_logic_vector(3 downto 0) := x"1"; 

    constant CFG_USE_GBT        : boolean := true;  -- if this is true, GBT links will be used for communicationa with OH, if false 3.2Gbs 8b10b links will be used instead (remember to instanciate the correct links!)
    constant CFG_USE_3x_GBTs    : boolean := false;  -- if this is true, each OH will use 3 GBT links - this will be default in the future with OH v3, but for now it's a good test
    constant CFG_USE_TRIG_LINKS : boolean := true; -- this should be TRUE by default, but could be set to false for tests or quicker compilation if not needed
    constant CFG_NUM_OF_OHs     : integer := 12;    -- total number of OHs to instanciate (remember to adapt the CFG_OH_LINK_CONFIG_ARR accordingly)


    --========================--
    --== Link configuration ==--
    --========================--

    -- defines the GT index for each type of OH link
    type t_oh_link_config is record
        track_8b10b_link: integer range 0 to 79; -- fallback link on OH v2b (can be used instead of GBT) and default for OH v2a
        gbt0_link       : integer range 0 to 79; -- main GBT link on OH v2b
        gbt1_link       : integer range 0 to 79; -- with OH v2b this is just for test, this will be needed with OH v3
        gbt2_link       : integer range 0 to 79; -- with OH v2b this is just for test, this will be needed with OH v3
        trig0_rx_link   : integer range 0 to 79; -- trigger RX link for clusters 0, 1, 2, 3
        trig1_rx_link   : integer range 0 to 79; -- trigger RX link for clusters 4, 5, 6, 7
    end record t_oh_link_config;
    
    type t_oh_link_config_arr is array (0 to CFG_NUM_OF_OHs - 1) of t_oh_link_config;
    
    constant CFG_OH_LINK_CONFIG_ARR : t_oh_link_config_arr := (
        (0, 24, 24, 24, 12, 12), 
        (1, 25, 25, 25, 13, 13),
        (2, 26, 26, 26, 14, 14), 
        (3, 27, 27, 27, 15, 15),

        (4, 28, 28, 28, 16, 16), 
        (5, 29, 29, 29, 17, 17), 
        (6, 30, 30, 30, 18, 18), 
        (7, 31, 31, 31, 19, 19), 

        (8, 32, 32, 32, 20, 20), 
        (9, 33, 33, 33, 21, 21), 
        (10, 34, 34, 34, 22, 22), 
        (11, 35, 35, 35, 23, 23) 
    );

    -- this record is used in CXP fiber to GTH map (holding tx and rx GTH index)
    type t_cxp_fiber_to_gth_link is record
        tx      : integer range 0 to 35; -- GTH TX index
        rx      : integer range 0 to 35; -- GTH RX index
    end record;
    
    -- this array is meant to hold mapping from CXP fiber index to GTH TX and RX indexes
    type t_cxp_fiber_to_gth_link_map is array (0 to 35) of t_cxp_fiber_to_gth_link;

    -- defines the GTH TX and RX index for each index of the CXP fiber
    constant CFG_CXP_FIBER_TO_GTH_MAP : t_cxp_fiber_to_gth_link_map := (
        (1, 2), -- fiber 0 (CXP 0)
        (3, 0), -- fiber 1
        (5, 4), -- fiber 2
        (0, 3), -- fiber 3
        (2, 5), -- fiber 4
        (4, 1), -- fiber 5
        (10, 7), -- fiber 6
        (8, 9), -- fiber 7
        (6, 10), -- fiber 8
        (11, 6), -- fiber 9
        (9, 8), -- fiber 10
        (7, 11), -- fiber 11
        (13, 15), -- fiber 12 (CXP 1)
        (15, 12), -- fiber 13
        (17, 16), -- fiber 14
        (12, 14), -- fiber 15 
        (14, 18), -- fiber 16
        (16, 13), -- fiber 17
        (22, 19), -- fiber 18
        (20, 23), -- fiber 19
        (18, 20), -- fiber 20
        (23, 17), -- fiber 21
        (21, 21), -- fiber 22
        (19, 22), -- fiber 23
        (25, 27), -- fiber 24 (CXP 2)
        (27, 24), -- fiber 25
        (29, 28), -- fiber 26
        (24, 26), -- fiber 27
        (26, 30), -- fiber 28
        (28, 25), -- fiber 29
        (34, 31), -- fiber 30
        (32, 35), -- fiber 31
        (30, 32), -- fiber 32
        (35, 29), -- fiber 33
        (33, 33), -- fiber 34
        (31, 34)  -- fiber 35
    );
    
end package gem_board_config_package;
--============================================================================
--                                                                 Package end 
--============================================================================

