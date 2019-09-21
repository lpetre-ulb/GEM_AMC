library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;

package ipb_addr_decode is

    constant C_NUM_IPB_SLAVES : integer := 26;

    type t_integer_arr is array (natural range <>) of integer;

    type t_ipb_slv is record
        oh_reg           : t_integer_arr(0 to 15);
        vfat3            : integer;
        oh_links         : integer;
        daq              : integer;
        ttc              : integer;
        trigger          : integer;
        system           : integer;
        test             : integer;
        slow_control     : integer;
        config_blaster   : integer;
        glib_gtx         : integer;
    end record;

    -- IPbus slave index definition
    constant C_IPB_SLV : t_ipb_slv := (oh_reg => (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
        vfat3 => 16,
        ttc => 17,
        oh_links => 18,
        daq => 19,
        trigger => 20,
        system => 21,
        test => 22,
        slow_control => 23,
        config_blaster => 24,
        glib_gtx => 25
    );

    function ipb_addr_sel(signal addr : in std_logic_vector(31 downto 0)) return integer;

end ipb_addr_decode;

package body ipb_addr_decode is

    function ipb_addr_sel(signal addr : in std_logic_vector(31 downto 0)) return integer is
        variable sel : integer;
    begin
        -- The addressing below uses 24 usable bits. Note that this supports "only" up to 16 OHs and up to 12 bits of OH in-module addressing.
        -- Addressing goes like this:
        --   * [31:24] - 0100
        --   * [23:20] - AMC module
        --   * [19:0]  - Addressing within the module
        -- AMC modules:
        --   * 0x3 - TTC
        --   * 0x4 - OH register. Module 0x4 is OH reg forwarding where addressing is
        --         - [19:16] - OH number
        --         - [15:12] - OH module
        --         - [11:0] - address within module
        --   * 0x5 - VFAT3
        --   * 0x6 - OH links
        --   * 0x7 - DAQ
        --   * 0x8 - trigger
        --   * 0x9 - system
        --   * 0xa - test
        --   * 0xb - slow control
        --   * 0xc - config blaster


        --              addr, "00------------------------------" is reserved (system ipbus fabric)

        -- TTC
        if    std_match(addr, "01000000001100000000000000------") then sel := C_IPB_SLV.ttc;

        -- OH register access
        -- One exception is the VFAT
        elsif std_match(addr, "0100000001000000----------------") then sel := C_IPB_SLV.oh_reg(0);
        elsif std_match(addr, "0100000001000001----------------") then sel := C_IPB_SLV.oh_reg(1);
        elsif std_match(addr, "0100000001000010----------------") then sel := C_IPB_SLV.oh_reg(2);
        elsif std_match(addr, "0100000001000011----------------") then sel := C_IPB_SLV.oh_reg(3);
        elsif std_match(addr, "0100000001000100----------------") then sel := C_IPB_SLV.oh_reg(4);
        elsif std_match(addr, "0100000001000101----------------") then sel := C_IPB_SLV.oh_reg(5);
        elsif std_match(addr, "0100000001000110----------------") then sel := C_IPB_SLV.oh_reg(6);
        elsif std_match(addr, "0100000001000111----------------") then sel := C_IPB_SLV.oh_reg(7);
        elsif std_match(addr, "0100000001001000----------------") then sel := C_IPB_SLV.oh_reg(8);
        elsif std_match(addr, "0100000001001001----------------") then sel := C_IPB_SLV.oh_reg(9);
        elsif std_match(addr, "0100000001001010----------------") then sel := C_IPB_SLV.oh_reg(10);
        elsif std_match(addr, "0100000001001011----------------") then sel := C_IPB_SLV.oh_reg(11);
        elsif std_match(addr, "0100000001001100----------------") then sel := C_IPB_SLV.oh_reg(12);
        elsif std_match(addr, "0100000001001101----------------") then sel := C_IPB_SLV.oh_reg(13);
        elsif std_match(addr, "0100000001001110----------------") then sel := C_IPB_SLV.oh_reg(14);
        elsif std_match(addr, "0100000001001111----------------") then sel := C_IPB_SLV.oh_reg(15);

        -- VFAT3 register forwarding
        -- bits [19:16] = OH index (0xf means write broadcast), and bits [15:11] = VFAT3 index (0x1f means write broadcast), for the rest of the bits we use this mapping:
        -- ipbus addr = 0x0xx is translated to VFAT3 addresses 0x000000xx
        -- ipbus addr = 0x1xx is translated to VFAT3 addresses 0x000100xx
        -- ipbus addr = 0x2xx is translated to VFAT3 addresses 0x000200xx
        -- ipbus addr = 0x300 is translated to VFAT3 address   0x0000ffff
        elsif std_match(addr, "010000000101--------------------") then sel := C_IPB_SLV.vfat3;

        -- other AMC modules
        elsif std_match(addr, "0100000001100000000-------------") then sel := C_IPB_SLV.oh_links;
        elsif std_match(addr, "01000000011100000000000---------") then sel := C_IPB_SLV.daq;
        elsif std_match(addr, "0100000010000000000-------------") then sel := C_IPB_SLV.trigger;
        elsif std_match(addr, "010000001001000-----------------") then sel := C_IPB_SLV.system;
        elsif std_match(addr, "010000001010000-----------------") then sel := C_IPB_SLV.test;
        elsif std_match(addr, "010000001011000-----------------") then sel := C_IPB_SLV.slow_control;
        elsif std_match(addr, "01000000110000------------------") then sel := C_IPB_SLV.config_blaster;

        -- GLIB GTX
        elsif std_match(addr, "0101000000000000000000000000----") then sel := C_IPB_SLV.glib_gtx;


        --              addr, "1-------------------------------" is reserved (wishbone fabric)
        else
            sel := 99;
        end if;

        return sel;
    end ipb_addr_sel;

end ipb_addr_decode;
