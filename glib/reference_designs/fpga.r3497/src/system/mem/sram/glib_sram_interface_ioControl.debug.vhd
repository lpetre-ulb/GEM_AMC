--=================================================================================================--
--==================================== Module Information =========================================--
--=================================================================================================--
--
-- Company:  				CERN (PH-ESE-BE)
-- Engineer: 				Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--
-- Create Date:		   09/12/2011
-- Project Name:			glib_sram_interface
-- Module Name:   		glib_sram_interface_ioControl
--
-- Language:				VHDL'93
--
-- Target Devices: 		GLIB (Virtex 6)
-- Tool versions: 		ISE 13.2
--
-- Revision:		 		2.6
--
-- Additional Comments:
--
-- The ipbubs ack adapter was done by Paschalis Vichoudis
-- 02-Jun-2016: The 256th word sram bug has been fixed by Marius Preuten (RWTH Aachen University)
--=================================================================================================--
--=================================================================================================--
-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;
-- User libraries and packages:
use work.system_flash_sram_package.all;
--=================================================================================================--
--======================================= Module Body =============================================--
--=================================================================================================--
entity glib_sram_interface_ioControl is
	port (
		-- Control:
		USER_SELECT_I										: in  std_logic;
		-- IPbus:
      IPBUS_RESET_I										: in  std_logic;
      IPBUS_CLK_I   										: in  std_logic;
		IPBUS_STROBE_I		   							: in 	std_logic;
      IPBUS_WRITE_I		   							: in  std_logic;
      IPBUS_ADDR_I   									: in  std_logic_vector(31 downto 0);
      IPBUS_WDATA_I										: in  std_logic_vector(31 downto 0);
      IPBUS_RDATA_O										: out std_logic_vector(31 downto 0);
      IPBUS_TEST_I 										: in  std_logic;
      IPBUS_BIST_ERRINJECT_I 							: in  std_logic;
		IPBUS_ACK_O											: buffer std_logic;
	   IPBUS_ERR_O											: out std_logic;
		-- User:
		USER_RESET_I										: in  std_logic;
		USER_CLK_I     									: in  std_logic;
      USER_CS_I											: in  std_logic;
      USER_WRITE_I										: in  std_logic;
      USER_ADDR_I											: in  std_logic_vector(20 downto 0);
      USER_DATA_I											: in  std_logic_vector(35 downto 0);
      USER_DATA_O	   									: out std_logic_vector(35 downto 0);
      USER_TEST_I 										: in  std_logic;
      USER_BIST_ERRINJECT_I 							: in  std_logic;
      -- Built In Self Test:
      BIST_RESET_O 										: out std_logic;
      BIST_CLK_O											: out std_logic;
		BIST_ENABLE_O										: out std_logic;
		BIST_ERRINJECT_O									: out std_logic;
		BIST_CS_I 											: in  std_logic;
      BIST_WRITE_I 										: in  std_logic;
      BIST_ADDR_I		 									: in  std_logic_vector(20 downto 0);
      BIST_DATA_I 										: in  std_logic_vector(35 downto 0);
      BIST_DATA_O 										: out std_logic_vector(35 downto 0);
      BIST_TESTDONE_I 									: in  std_logic;
		-- SRAM interface:
      SRAMINT_RESET_O									: out std_logic;
      SRAMINT_CLK_O 										: out std_logic;
		SRAMINT_CS_O 										: buffer std_logic;
      SRAMINT_WRITE_O 									: out std_logic;
      SRAMINT_ADDR_O 									: out std_logic_vector(20 downto 0);
      SRAMINT_DATA_I 									: in  std_logic_vector(35 downto 0);
      SRAMINT_DATA_O 									: out std_logic_vector(35 downto 0)
	);
end glib_sram_interface_ioControl;



architecture structural of glib_sram_interface_ioControl is
	--======================== Signal Declarations ========================--
	signal reset_from_mux								: std_logic;
	signal clk_from_mux									: std_logic;
	signal ipbus_strobe_sr							   : std_logic_vector(SR_SIZE-1 downto 0);
	signal addr_from_ipBus	   						: std_logic_vector(20 downto 0);
	signal wData_from_ipBus	   						: std_logic_vector(35 downto 0);
	signal ipBus_rdata		   						: std_logic_vector(35 downto 0);
	signal sramint_cs_from_mux							: std_logic;
	signal sramint_write_from_mux						: std_logic;
	signal sramint_addr_from_mux						: std_logic_vector(20 downto 0);
	signal sramint_data_from_mux						: std_logic_vector(35 downto 0);
	signal testEnable_from_orGate						: std_logic;
	signal bistModeEnable_from_fsm					: std_logic;

    --signal ipbus_read_state: integer range 0 to 8:= 0;
    --signal ipbus_ack: std_logic;
    signal ipbus_addr_prediction: std_logic_vector(31 downto 0);
    signal ipbus_addr_prediction_delayed: std_logic_vector(31 downto 0);
    
    type ack_states is (
        idle,
        wr_active,
        wr_halt0,
        wr_halt1,
        rd_prep0,
        rd_prep1,
        rd_prep2,
        rd_active,
        rd_halt0,
        rd_halt1,
        rd_halt2,
        rd_halt3
    );
    
    signal current_state : ack_states := idle;
    signal next_state : ack_states := idle;

    -- DEBUG START
    signal chipscope_control : STD_LOGIC_VECTOR(35 DOWNTO 0);
    signal chipscope_TRIG: std_logic_vector(7 downto 0);
    signal chipscope_DATA: std_logic_vector(255 downto 0);
    -- DEBUG END

COMPONENT ipbus_addr_delay
  PORT (
    d : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    clk : IN STD_LOGIC;
    q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;


-- DEBUG START
 component sram_ila
   PORT (
     CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
     CLK : IN STD_LOGIC;
     DATA : IN STD_LOGIC_VECTOR(255 DOWNTO 0);
     TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
 end component;
 component sram_ctrl
   PORT (
     CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
 end component;
-- DEBUG END

	--=====================================================================--
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================--
-----		  --===================================================--
--========================================================================--
	--========================= Port Assignments ==========================--
	-- Stam Interface:
	SRAMINT_RESET_O										<= reset_from_mux;
	SRAMINT_CLK_O											<= clk_from_mux;
	-- Buil In Self Test:
	BIST_RESET_O											<= reset_from_mux;
	BIST_CLK_O												<= clk_from_mux;
	BIST_DATA_O												<= SRAMINT_DATA_I;
	--=====================================================================--
	--============================ User Logic =============================--


    ipbus_addr_delay_inst : ipbus_addr_delay
    PORT MAP (
        d => ipbus_addr_prediction,
        clk => IPBUS_CLK_I,
        q => ipbus_addr_prediction_delayed
    );


    process(IPBUS_CLK_I)
    begin
        if rising_edge(IPBUS_CLK_I) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, IPBUS_WRITE_I, IPBUS_STROBE_I)
    begin
        case current_state is
            -- normal and common path
            when idle =>
                if    (IPBUS_WRITE_I = '1' and IPBUS_STROBE_I = '1') then
                    next_state <= wr_active;
                elsif (IPBUS_WRITE_I = '0' and IPBUS_STROBE_I = '1') then
                    next_state <= rd_prep0;
                else
                    next_state <= idle;
                end if;

            when wr_active =>
                if (IPBUS_STROBE_I = '0') then
                    next_state <= wr_halt0;
                else
                    next_state <= wr_active;
                end if;
            when wr_halt0 =>
                next_state <= wr_halt1;
            when wr_halt1 =>
                next_state <= idle;

            when rd_prep0 =>
                next_state <= rd_prep1;
            when rd_prep1 =>
                next_state <= rd_prep2;
            when rd_prep2 =>
                next_state <= rd_active;
            when rd_active =>
                if (IPBUS_STROBE_I = '1' and IPBUS_ADDR_I = ipbus_addr_prediction_delayed) then
                    next_state <= rd_active;
                else
                    next_state <= rd_halt0;
                end if;
            when rd_halt0 =>
                next_state <= rd_halt1;
            when rd_halt1 =>
                next_state <= rd_halt2;
            when rd_halt2 =>
                next_state <= rd_halt3;
            when rd_halt3 =>
                next_state <= idle;
        end case;
    end process;
    
    IPBUS_ACK_O <= IPBUS_STROBE_I when (current_state = wr_active) or
                                       (current_state = rd_active) else
                   '0';

    IPBUS_ERR_O <= '0';
    
    ipbus_addr_prediction <= std_logic_vector(unsigned(IPBUS_ADDR_I)+1) when (current_state = rd_prep1) else
                             std_logic_vector(unsigned(IPBUS_ADDR_I)+2) when (current_state = rd_prep2) else
                             std_logic_vector(unsigned(IPBUS_ADDR_I)+3) when (current_state = rd_active) else
                             IPBUS_ADDR_I;

    addr_from_ipBus		    <= ipbus_addr_prediction(20 downto 0) when (current_state = rd_prep0) or
                                                                       (current_state = rd_prep1) or
                                                                       (current_state = rd_prep2) or
                                                                       (current_state = rd_active) else 
                               IPBUS_ADDR_I(20 downto 0);
    

--    -- there should be a real state machine here...
--    ack_process:process(IPBUS_RESET_I, IPBUS_CLK_I)
--        variable write_timeout : integer range 0 to 1 := 1;
--	begin
--		if IPBUS_RESET_I = '1' then
--			ipbus_read_state<=0;
--            ipbus_ack <= '0';
--            write_timeout := 0;
--		elsif rising_edge(IPBUS_CLK_I) then
--            if    IPBUS_WRITE_I = '1' and IPBUS_STROBE_I = '0' then
--                write_timeout := 0;
--                ipbus_ack <= '0';
--            elsif IPBUS_WRITE_I = '1' and IPBUS_STROBE_I = '1' then
--                if write_timeout = 0 then
--                    ipbus_ack 	<= IPBUS_STROBE_I;-- and not ipbus_ack;
--                else
--                    ipbus_ack <= '0';
--                    write_timeout := write_timeout - 1;
--                end if;
--            else
--                case ipbus_read_state is
--                when 0 =>
--                    ipbus_ack 		<= '0';
--                    IF IPBUS_STROBE_I='1' then
--                        ipbus_read_state <= 1;
--                        ipbus_addr_prediction <= std_logic_vector(unsigned(IPBUS_ADDR_I)+0);
--                    end if;
--                when 1 =>
--                    ipbus_ack 		<= '0';
--                    ipbus_read_state <= 2;
--                    ipbus_addr_prediction <= std_logic_vector(unsigned(IPBUS_ADDR_I)+1);
--                when 2 =>
--                    ipbus_ack 		<= '0';
--                    ipbus_read_state <= 3;
--                    ipbus_addr_prediction <= std_logic_vector(unsigned(IPBUS_ADDR_I)+2);
--                when 3 =>
--                    ipbus_ack 		<= IPBUS_STROBE_I;
--                    ipbus_read_state <= 4;
--                    ipbus_addr_prediction <= std_logic_vector(unsigned(IPBUS_ADDR_I)+3);
--                when 4 =>
--                    if IPBUS_STROBE_I = '1' and IPBUS_ADDR_I = ipbus_addr_prediction_delayed then
--                        ipbus_ack 		<= IPBUS_STROBE_I;
--                    else
--                        ipbus_ack       <= '0';
--                        ipbus_read_state <= 5;
--                    end if;
--                    ipbus_addr_prediction <= std_logic_vector(unsigned(IPBUS_ADDR_I)+4);
--                when 5 =>
--                    ipbus_ack       <= '0';
--                    ipbus_read_state <= 6;
--                when 6 =>
--                    ipbus_ack       <= '0';
--                    ipbus_read_state <= 7;
--                when 7 =>
--                    ipbus_ack       <= '0';
--                    ipbus_read_state <= 8;
--                when 8 =>
--                    ipbus_ack       <= '0';
--                    ipbus_read_state <= 0;
--                when others =>
--                end case;
--            end if;
--        end if;
--    end process;
--
--    IPBUS_ACK_O <= ipbus_ack;
                               
    -- W Data:
    wData_from_ipBus									<= b"0000" & IPBUS_WDATA_I;
    -- R Data:
    IPBUS_RDATA_O										<= ipBus_rdata(31 downto 0);


	-- I/O control Multiplexors:
	reset_from_mux											<= USER_RESET_I				when USER_SELECT_I = '1'
																	else IPBUS_RESET_I;
	clk_bufgmux : BUFGMUX
		port map (
			O 													=> clk_from_mux,
			I0 												=> IPBUS_CLK_I,
			I1 												=> USER_CLK_I,
			S 													=> USER_SELECT_I
		);
	ipBus_rdata												<=	(others => '0') 			when USER_SELECT_I = '1' or
																										  testEnable_from_orGate = '1'
																	else SRAMINT_DATA_I;
	USER_DATA_O												<=	SRAMINT_DATA_I				when USER_SELECT_I = '1' and
																										  testEnable_from_orGate = '0'
																	else (others => '0');
	sramint_cs_from_mux									<= USER_CS_I					when USER_SELECT_I = '1'
																	else IPBUS_STROBE_I;
	sramint_write_from_mux								<= USER_WRITE_I				when USER_SELECT_I = '1'
																	else IPBUS_WRITE_I;
	sramint_addr_from_mux								<= USER_ADDR_I					when USER_SELECT_I = '1'
																	else addr_from_ipBus;
	sramint_data_from_mux								<= USER_DATA_I					when USER_SELECT_I = '1'
																	else wData_from_ipBus;
	-- Normal mode or Test mode:
	testEnable_from_orGate								<= '1' when (IPBUS_TEST_I = '1' and USER_SELECT_I = '0') or
																				(USER_TEST_I  = '1' and USER_SELECT_I = '1')
																	else '0';
	SRAMINT_CS_O											<= BIST_CS_I 					when bistModeEnable_from_fsm = '1'
																	else sramint_cs_from_mux;
	SRAMINT_WRITE_O										<= BIST_WRITE_I 				when bistModeEnable_from_fsm = '1'
																	else sramint_write_from_mux;
	SRAMINT_ADDR_O											<= BIST_ADDR_I 			   when bistModeEnable_from_fsm = '1'
																	else sramint_addr_from_mux;
	SRAMINT_DATA_O											<= BIST_DATA_I 				when bistModeEnable_from_fsm = '1'
																	else sramint_data_from_mux;
	-- BIST error injection:
	BIST_ERRINJECT_O										<= USER_BIST_ERRINJECT_I  	when USER_SELECT_I = '1'
																	else IPBUS_BIST_ERRINJECT_I;
	-- Test mode Finite State Machine(FSM):
	testModeFsm_process: process(reset_from_mux, clk_from_mux)
		variable state										: testControlStateT;
	begin
		if reset_from_mux = '1' then
			state												:= e0_userMode;
			bistModeEnable_from_fsm						<= '0';
			BIST_ENABLE_O									<= '0';
		elsif rising_edge(clk_from_mux) then
			case state is
				when e0_userMode =>
					if testEnable_from_orGate = '1' then
						state									:= e1_bistMode;
						bistModeEnable_from_fsm			<= '1';
						BIST_ENABLE_O						<= '1';
					end if;
				when e1_bistMode =>
					BIST_ENABLE_O							<= '0';
					if BIST_TESTDONE_I = '1' then
						state									:= e0_userMode;
						bistModeEnable_from_fsm			<= '0';
					end if;
			end case;
		end if;
	end process;








--DEBUG START

 chipscope_sram_ila_inst : sram_ila
   port map (
     CONTROL => chipscope_control,
     CLK => IPBUS_CLK_I,
     DATA => chipscope_DATA,
     TRIG0 => chipscope_TRIG);


 chipscope_TRIG(0) <= IPBUS_STROBE_I;
 chipscope_DATA(0) <= SRAMINT_CS_O;
 chipscope_DATA(3) <= IPBUS_STROBE_I;
 chipscope_DATA(4) <= IPBUS_WRITE_I;
 chipscope_DATA(5) <= IPBUS_ACK_O;
 --chipscope_DATA(9 downto 6) <= std_logic_vector(to_unsigned(ipbus_read_state, 4));
 chipscope_DATA(30 downto 10) <= addr_from_ipBus;
 chipscope_DATA(63 downto 32) <= IPBUS_ADDR_I;
 chipscope_DATA(95 downto 64) <= ipbus_addr_prediction;
 chipscope_DATA(127 downto 96) <= ipbus_addr_prediction_delayed;
 chipscope_DATA(159 downto 128) <= IPBUS_WDATA_I;
 chipscope_DATA(191 downto 160) <= ipBus_rdata(31 downto 0);
 
 chipscope_DATA(255 downto 251) <= "00000" when (current_state = idle) else
                                   "01000" when (current_state = wr_active) else
                                   "01001" when (current_state = wr_halt0) else
                                   "01010" when (current_state = wr_halt1) else
                                   
                                   "10000" when (current_state = rd_prep0) else
                                   "10001" when (current_state = rd_prep1) else
                                   "10010" when (current_state = rd_prep2) else
                                   "10011" when (current_state = rd_active) else
                                   "10100" when (current_state = rd_halt0) else
                                   "10101" when (current_state = rd_halt1) else
                                   "10110" when (current_state = rd_halt2) else
                                   "10111" when (current_state = rd_halt3);

 chipscope_sram_ctrl_inst : sram_ctrl
   port map (
     CONTROL0 => chipscope_control);

-- DEBUG END


	--=====================================================================--
	end structural;
--=================================================================================================--
--=================================================================================================--