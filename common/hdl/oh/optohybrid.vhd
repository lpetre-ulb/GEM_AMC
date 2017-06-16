------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    10:43 2016-08-04
-- Module Name:    OPTOHYBRID
-- Description:    This module handles all communications with the optohybrid
-- Note:           All 8b10b links must be already synchronized to the ttc clock 160  
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--use work.gth_pkg.all;
use work.ttc_pkg.all;
use work.gem_pkg.all;
use work.ipbus.all;

entity optohybrid is
    generic(
        g_USE_GBT       : boolean := true;  -- if this is true, GBT links will be used for communicationa with OH, if false 3.2Gbs 8b10b links will be used instead (remember to instanciate the correct links!)
        g_DEBUG         : boolean := false -- if this is set to true, some chipscope cores will be inserted
    );
    port(
        -- reset
        reset_i                 : in  std_logic;

        -- TTC
        ttc_clk_i               : in  t_ttc_clks;
        ttc_cmds_i              : in  t_ttc_cmds;
        
        -- Control and tracking data link 
        gth_rx_data_i           : in  t_gt_8b10b_rx_data;
        gth_tx_data_o           : out t_gt_8b10b_tx_data;

        -- GBT control/tracking link
        gbt_rx_ready_i          : in  std_logic; 
        gbt_rx_data_i           : in  std_logic_vector(83 downto 0);
        gbt_tx_data_o           : out std_logic_vector(83 downto 0);
        
        -- Trigger links
        gth_rx_trig_data_i      : in t_gt_8b10b_rx_data_arr(1 downto 0);
        sbit_clusters_o         : out t_oh_sbits;
        sbit_links_status_o     : out t_oh_sbit_links;
        
        -- Tracking data link
        tk_data_link_o          : out t_data_link;
        tk_error_o              : out std_logic;
        tk_evt_received_o       : out std_logic;
        
        -- OH reg forwarding IPbus
        oh_reg_ipb_reset_i      : in  std_logic;
        oh_reg_ipb_clk_i        : in  std_logic;
        oh_reg_ipb_reg_miso_o   : out ipb_rbus;
        oh_reg_ipb_reg_mosi_i   : in  ipb_wbus
        
    );
end optohybrid;

architecture optohybrid_arch of optohybrid is
    
    signal vfat2_t1         : t_t1;
    
    signal gth_tx_data      : t_gt_8b10b_tx_data;
    
    --== GTX requests ==--
    
    signal g2o_req_en       : std_logic;
    signal g2o_req_valid    : std_logic;
    signal g2o_req_data     : std_logic_vector(64 downto 0);
    
    signal o2g_req_en       : std_logic;
    signal o2g_req_data     : std_logic_vector(31 downto 0);
    signal o2g_req_error    : std_logic;    
    
    --== Tracking data ==--
    
    signal evt_en           : std_logic;
    signal evt_data         : std_logic_vector(15 downto 0);


    --== debug signals ==--
    
    signal debug_tr_tx_link : t_gt_8b10b_tx_data;
    signal debug_tr_rx_link : t_gt_8b10b_rx_data;

begin

    gth_tx_data_o <= gth_tx_data;

    g_3g2_fallback_data_clk : if not g_USE_GBT generate
        tk_data_link_o.clk <= ttc_clk_i.clk_160;
    end generate;

    g_gbt_data_clk : if g_USE_GBT generate
        tk_data_link_o.clk <= ttc_clk_i.clk_80;
    end generate;
    
    tk_data_link_o.data_en <= evt_en;
    tk_data_link_o.data <= evt_data;

    vfat2_t1.lv1a       <= ttc_cmds_i.l1a;
    vfat2_t1.bc0        <= ttc_cmds_i.bc0;
    vfat2_t1.resync     <= ttc_cmds_i.resync;
    vfat2_t1.calpulse   <= ttc_cmds_i.calpulse;
    
    --==========================--
    --==   TX Tracking link   ==--
    --==========================--
    
    g_3g2_fallback_tk_tx_link : if not g_USE_GBT generate
    
        i_link_tx_tracking : entity work.link_tx_tracking
            port map(
                gtx_clk_i   => ttc_clk_i.clk_160,   
                reset_i     => reset_i,           
                vfat2_t1_i  => vfat2_t1,        
                req_en_o    => g2o_req_en,   
                req_valid_i => g2o_req_valid,   
                req_data_i  => g2o_req_data,           
                tx_kchar_o  => gth_tx_data.txcharisk(1 downto 0),   
                tx_data_o   => gth_tx_data.txdata(15 downto 0)
            );  
    
    end generate;

    g_gbt_tx_link : if g_USE_GBT generate
        i_gbt_tx_link : entity work.link_gbt_tx
            port map(
                ttc_clk_40_i          => ttc_clk_i.clk_40,
                reset_i               => reset_i,
                vfat2_t1_i            => vfat2_t1,
                req_en_o              => g2o_req_en,
                req_valid_i           => g2o_req_valid,
                req_data_i            => g2o_req_data,
                gbt_tx_data_o         => gbt_tx_data_o
            );
    end generate;

    
    --==========================--
    --==   RX Tracking link   ==--
    --==========================--
    
    g_3g2_fallback_tk_rx_link : if not g_USE_GBT generate

        i_link_rx_tracking : entity work.link_rx_tracking
            port map(
                gtx_clk_i       => ttc_clk_i.clk_160,   
                reset_i         => reset_i,           
                req_en_o        => o2g_req_en,   
                req_data_o      => o2g_req_data,   
                evt_en_o        => evt_en,
                evt_data_o      => evt_data,
                tk_error_o      => tk_error_o,
                evt_rcvd_o      => tk_evt_received_o,
                rx_kchar_i      => gth_rx_data_i.rxcharisk(1 downto 0),   
                rx_data_i       => gth_rx_data_i.rxdata(15 downto 0)        
            );

    end generate;

    g_gbt_rx_link : if g_USE_GBT generate
        
        i_gbt_rx_link : entity work.link_gbt_rx
            port map(
                ttc_clk_40_i            => ttc_clk_i.clk_40,
                ttc_clk_80_i            => ttc_clk_i.clk_80,
                reset_i                 => reset_i,
                req_en_o                => o2g_req_en,
                req_data_o              => o2g_req_data,
                evt_en_o                => evt_en,
                evt_data_o              => evt_data,
                tk_error_o              => tk_error_o,
                evt_rcvd_o              => tk_evt_received_o,
                gbt_rx_data_i           => gbt_rx_data_i,
                gbt_rx_ready_i          => gbt_rx_ready_i
            );
        
    end generate;    

    --=================================--
    --== Register request forwarding ==--
    --=================================--
    
    g_3g2_fallback_ipb_req : if not g_USE_GBT generate
        i_link_request : entity work.link_request
            port map(
                ipb_clk_i       => oh_reg_ipb_clk_i,
                gtx_rx_clk_i    => ttc_clk_i.clk_160,
                gtx_tx_clk_i    => ttc_clk_i.clk_160,
                reset_i         => oh_reg_ipb_reset_i,        
                ipb_mosi_i      => oh_reg_ipb_reg_mosi_i,
                ipb_miso_o      => oh_reg_ipb_reg_miso_o,        
                tx_en_i         => g2o_req_en,
                tx_valid_o      => g2o_req_valid,
                tx_data_o       => g2o_req_data,        
                rx_en_i         => o2g_req_en,
                rx_data_i       => o2g_req_data        
            );
    end generate;

    -- just a different clock here, maybe should make it neater later (just change the clk signals and keep the module instanciation, but oh well.. :)
    g_gbt_ipb_req : if g_USE_GBT generate
        i_link_request : entity work.link_request
            port map(
                ipb_clk_i       => oh_reg_ipb_clk_i,
                gtx_rx_clk_i    => ttc_clk_i.clk_40,
                gtx_tx_clk_i    => ttc_clk_i.clk_40,
                reset_i         => oh_reg_ipb_reset_i,        
                ipb_mosi_i      => oh_reg_ipb_reg_mosi_i,
                ipb_miso_o      => oh_reg_ipb_reg_miso_o,        
                tx_en_i         => g2o_req_en,
                tx_valid_o      => g2o_req_valid,
                tx_data_o       => g2o_req_data,        
                rx_en_i         => o2g_req_en,
                rx_data_i       => o2g_req_data        
            );
     end generate;
     
    --=========================--
    --==   RX Trigger Link   ==--
    --=========================--
    
    i_link_rx_trigger0 : entity work.link_rx_trigger
        port map(
            ttc_clk_i           => ttc_clk_i.clk_40,
            reset_i             => reset_i,
            gt_rx_trig_usrclk_i => ttc_clk_i.clk_160,
            rx_kchar_i          => gth_rx_trig_data_i(0).rxcharisk(1 downto 0),
            rx_data_i           => gth_rx_trig_data_i(0).rxdata(15 downto 0),
            sbit_cluster0_o     => sbit_clusters_o(0),
            sbit_cluster1_o     => sbit_clusters_o(1),
            sbit_cluster2_o     => sbit_clusters_o(2),
            sbit_cluster3_o     => sbit_clusters_o(3),
            link_status_o       => sbit_links_status_o(0)
        );
     
    i_link_rx_trigger1 : entity work.link_rx_trigger
        port map(
            ttc_clk_i           => ttc_clk_i.clk_40,
            reset_i             => reset_i,
            gt_rx_trig_usrclk_i => ttc_clk_i.clk_160,
            rx_kchar_i          => gth_rx_trig_data_i(1).rxcharisk(1 downto 0),
            rx_data_i           => gth_rx_trig_data_i(1).rxdata(15 downto 0),
            sbit_cluster0_o     => sbit_clusters_o(4),
            sbit_cluster1_o     => sbit_clusters_o(5),
            sbit_cluster2_o     => sbit_clusters_o(6),
            sbit_cluster3_o     => sbit_clusters_o(7),
            link_status_o       => sbit_links_status_o(1)
        );
        
    --============================--
    --==        Debug           ==--
    --============================--
    
--    gen_debug:
--    if g_DEBUG and not g_USE_GBT generate
--        
--        --debug_tr_tx_link.txcharisk(1 downto 0) <= sync_tk_tx_din(17 downto 16); 
--
--        gt_tx_link_ila_inst : entity work.gt_tx_link_ila_wrapper
--            port map(
--                clk_i => ttc_clk_i.clk_160,
--                kchar_i => sync_tk_tx_din(17 downto 16),
--                data_i => sync_tk_tx_din(15 downto 0)
--            );
--        
--        sync_tk_rx_din <= gth_rx_data_i.rxdisperr(1 downto 0) & gth_rx_data_i.rxnotintable(1 downto 0) & gth_rx_data_i.rxchariscomma(1 downto 0) & gth_rx_data_i.rxcharisk(1 downto 0) & gth_rx_data_i.rxdata(15 downto 0);
--        gt_rx_link_ila_inst : entity work.gt_rx_link_ila_wrapper
--            port map(
--                clk_i => ttc_clk_i.clk_160,
--                kchar_i => sync_tk_rx_dout(17 downto 16),
--                comma_i => sync_tk_rx_dout(19 downto 18),
--                not_in_table_i => sync_tk_rx_dout(21 downto 20),
--                disperr_i => sync_tk_rx_dout(23 downto 22),
--                data_i => sync_tk_rx_dout(15 downto 0)
--            );
--    end generate;     
     
end optohybrid_arch;
