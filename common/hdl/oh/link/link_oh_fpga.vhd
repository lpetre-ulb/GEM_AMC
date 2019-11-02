------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    12:00 2017-11-04
-- Module Name:    LINK OH FPGA
-- Description:    This module manages the OH FPGA slow control requests and responses 
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.ttc_pkg.all;
use work.gem_pkg.all;
use work.ipbus.all;

entity link_oh_fpga is
    port(
        -- reset
        reset_i         : in  std_logic;
        
        -- clocks
        ttc_clk_i       : in  t_ttc_clks;
        ipb_clk_i       : in  std_logic;
        
        -- ttc
        ttc_cmds_i      : in  t_ttc_cmds;
        
        -- ipbus
        ipb_mosi_i      : in  ipb_wbus;
        ipb_miso_o      : out ipb_rbus;
        
        -- fifo I/O
        rx_elink_i      : in  std_logic_vector(7 downto 0);
        tx_elink_o      : out std_logic_vector(7 downto 0)
        
        -- monitoring
--        status_o        : out t_vfat_slow_control_status
        
    );
end link_oh_fpga;

architecture link_oh_fpga_arch of link_oh_fpga is
    
    constant TRANSACTION_TIMEOUT    : unsigned(11 downto 0) := x"7ff";
    
    type state_t is (IDLE, RSPD, ACK, RST);
        
    signal state                : state_t;

    signal transaction_timer    : unsigned(11 downto 0) := (others => '0');
    signal timeout_err_cnt      : unsigned(15 downto 0) := (others => '0');
    signal axi_strobe_err_cnt   : unsigned(15 downto 0) := (others => '0');
    
    signal tx_busy              : std_logic := '0';
    signal tx_is_write          : std_logic := '0';
    signal tx_reg_addr          : std_logic_vector(15 downto 0) := (others => '0');
    signal tx_reg_value         : std_logic_vector(31 downto 0) := (others => '0');
    signal tx_command_en        : std_logic := '0';
    signal tx_command_en_sync   : std_logic := '0';

    signal rx_valid             : std_logic;
    signal rx_valid_sync        : std_logic;
    signal rx_valid_ack         : std_logic;
    signal rx_valid_ack_sync    : std_logic;
    signal rx_error             : std_logic;
    signal rx_error_sync        : std_logic;
    signal rx_reg_value         : std_logic_vector(31 downto 0) := (others => '0');
    
begin

    --== IPbus process ==--

    process(ipb_clk_i)       
    begin    
        if (rising_edge(ipb_clk_i)) then
            if (reset_i = '1') then
                ipb_miso_o <= (ipb_err => '0', ipb_ack => '0', ipb_rdata => (others => '0'));
                tx_is_write <= '0';
                tx_reg_addr <= (others => '0');
                tx_reg_value <= (others => '0');
                tx_command_en <= '0';
                rx_valid_ack <= '0';
                state <= IDLE;
                transaction_timer <= (others => '0');
                timeout_err_cnt <= (others => '0');
                axi_strobe_err_cnt <= (others => '0');
            else
                case state is
                    when IDLE =>
                    
                        ipb_miso_o <= (ipb_err => '0', ipb_ack => '0', ipb_rdata => (others => '0'));
                        transaction_timer <= (others => '0');
                        rx_valid_ack <= '0';
                        
                        -- waiting for a request from IPbus
                        if (ipb_mosi_i.ipb_strobe = '1') then
                            tx_command_en <= '1';
                            tx_reg_addr <= ipb_mosi_i.ipb_addr(15 downto 0);
                            tx_is_write  <= ipb_mosi_i.ipb_write;
                            tx_reg_value <= ipb_mosi_i.ipb_wdata;
                            
                            state <= RSPD;
                        else
                            tx_command_en <= '0';
                            state <= IDLE;
                        end if;
                        
                    -- waiting for an OH response and replying to IPbus
                    when RSPD =>

                        rx_valid_ack <= '0';
                        
                        if (tx_busy = '1') then
                            tx_command_en <= '0';
                        end if;
                        
                        if (ipb_mosi_i.ipb_strobe = '0') then
                            state <= IDLE;     
                            axi_strobe_err_cnt <= axi_strobe_err_cnt + 1;
                        elsif (rx_valid_sync = '1') then
                            ipb_miso_o <= (ipb_ack => '1', ipb_err => '0', ipb_rdata => rx_reg_value);
                            rx_valid_ack <= '1';
                            state <= ACK;
                        elsif (rx_error_sync = '1') then
                            ipb_miso_o <= (ipb_ack => '1', ipb_err => '1', ipb_rdata => rx_reg_value);
                            state <= RST;
                        elsif (transaction_timer = TRANSACTION_TIMEOUT) then
                            timeout_err_cnt <= timeout_err_cnt + 1;
                            ipb_miso_o <= (ipb_ack => '1', ipb_err => '1', ipb_rdata => rx_reg_value);
                            state <= RST;
                        end if;

                        transaction_timer <= transaction_timer + 1;

                    when ACK =>

                        if (rx_valid_sync = '0') then
                            rx_valid_ack <= '0';
                            state <= RST;
                        end if;

                        if (ipb_mosi_i.ipb_strobe = '0') then
                            ipb_miso_o.ipb_ack <= '0';
                            ipb_miso_o.ipb_err <= '0';
                        end if;

                    -- closing the transaction and returning to idle
                    when RST =>
                        rx_valid_ack <= '0';
                        if (ipb_mosi_i.ipb_strobe = '0') then 
                            ipb_miso_o.ipb_ack <= '0';
                            ipb_miso_o.ipb_err <= '0';
                            state <= IDLE;
                            tx_command_en <= '0';
                        end if;
                    
                    -- who knows what might happen :)
                    when others =>
                        
                        ipb_miso_o <= (ipb_err => '0', ipb_ack => '0', ipb_rdata => (others => '0')); 
                        state <= IDLE;
                        tx_is_write <= '0';
                        tx_reg_addr <= (others => '0');
                        tx_reg_value <= (others => '0');
                        tx_command_en <= '0';
                        rx_valid_ack <= '0';
                        
                end case;                      
            end if;        
        end if;        
    end process;

    i_tx_cmd_en_sync : entity work.synchronizer
        generic map(
            N_STAGES => 2
        )
        port map(
            async_i => tx_command_en,
            clk_i   => ttc_clk_i.clk_40,
            sync_o  => tx_command_en_sync
        );

    i_rx_valid_sync : entity work.synchronizer
        generic map(
            N_STAGES => 2
        )
        port map(
            async_i => rx_valid,
            clk_i   => ipb_clk_i,
            sync_o  => rx_valid_sync
        );

    i_rx_valid_ack_sync : entity work.synchronizer
        generic map(
            N_STAGES => 2
        )
        port map(
            async_i => rx_valid_ack,
            clk_i   => ttc_clk_i.clk_40,
            sync_o  => rx_valid_ack_sync
        );

    i_rx_error_sync : entity work.synchronizer
        generic map(
            N_STAGES => 2
        )
        port map(
            async_i => rx_error,
            clk_i   => ipb_clk_i,
            sync_o  => rx_error_sync
        );
    
    i_link_tx : entity work.link_oh_fpga_tx
        port map(
            reset_i         => reset_i,
            ttc_clk_40_i    => ttc_clk_i.clk_40,
            ttc_cmds_i      => ttc_cmds_i,
            elink_data_o    => tx_elink_o,
            request_valid_i => tx_command_en_sync,
            request_write_i => tx_is_write,
            request_addr_i  => tx_reg_addr,
            request_data_i  => tx_reg_value,
            busy_o          => tx_busy
        );
    
    i_link_rx : entity work.link_oh_fpga_rx
        port map(
            reset_i          => reset_i,
            ttc_clk_40_i     => ttc_clk_i.clk_40,
            elink_data_i     => rx_elink_i,
            data_valid_o     => rx_valid,
            data_valid_ack_i => rx_valid_ack_sync,
            data_o           => rx_reg_value,
            error_o          => rx_error
        );
    
end link_oh_fpga_arch;
