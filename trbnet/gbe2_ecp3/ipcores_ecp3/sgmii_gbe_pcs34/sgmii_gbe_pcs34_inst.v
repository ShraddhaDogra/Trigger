//=============================================================================
// Verilog module generated by IPExpress    10/04/2011    13:50:20          
// Filename: sgmii_gbe_pcs34_inst.v                                            
// Copyright(c) 2008 Lattice Semiconductor Corporation. All rights reserved.   
//=============================================================================

/* WARNING - Changes to this file should be performed by re-running IPexpress
or modifying the .LPC file and regenerating the core.  Other changes may lead
to inconsistent simulation and/or implemenation results */

//---------------------------------------------------------------
// sgmii_gbe_pcs34 module instantiation template              
//---------------------------------------------------------------
 

                        

sgmii_gbe_pcs34  sgmii_gbe_pcs34_U (

   // Control Interface
   .rst_n                  ( rst_n ) ,
   .signal_detect          ( signal_detect ) ,
   .gbe_mode               ( gbe_mode ) ,
   .sgmii_mode             ( sgmii_mode ) ,
   .operational_rate       ( operational_rate ) ,
   .debug_link_timer_short ( debug_link_timer_short ) ,
   .force_isolate          ( force_isolate ) ,
   .force_loopback         ( force_loopback ) ,
   .force_unidir           ( force_unidir ) ,

   .rx_compensation_err    ( rx_compensation_err ) ,
   .ctc_drop_flag          ( ctc_drop_flag ) ,
   .ctc_add_flag           ( ctc_add_flag ) ,
   .an_link_ok             ( an_link_ok ) ,

   // (G)MII Interface
   .tx_clock_enable_sink   ( tx_clock_enable_sink ),
   .tx_clock_enable_source ( tx_clock_enable_source ),
   .tx_clk_125             ( tx_clk_125 ) ,
   .tx_d                   ( tx_d ) ,
   .tx_en                  ( tx_en ) ,
   .tx_er                  ( tx_er ) ,

   .rx_clock_enable_sink   ( rx_clock_enable_sink ),
   .rx_clock_enable_source ( rx_clock_enable_source ),
   .rx_clk_125             ( rx_clk_125 ) ,
   .rx_d                   ( rx_d ) ,
   .rx_dv                  ( rx_dv ) ,
   .rx_er                  ( rx_er ) ,
   .col                    ( col ) ,
   .crs                    ( crs ) ,
                  
   // 8BI Interface
   .tx_data           ( tx_data ) ,
   .tx_kcntl          ( tx_kcntl ) ,
   .tx_disparity_cntl ( tx_disparity_cntl ) ,
   .xmit_autoneg      ( xmit_autoneg ) ,

   .serdes_recovered_clk ( serdes_recovered_clk ) ,
   .rx_data              ( rx_data ) ,
   .rx_kcntl             ( rx_kcntl) ,
   .rx_even              ( rx_even ) ,
   .rx_disp_err          ( rx_disp_err ) ,
   .rx_cv_err            ( rx_cv_err ) ,
   .rx_err_decode_mode   ( rx_err_decode_mode ) ,

   // Management Interface
   .mr_adv_ability ( mr_adv_ability ),
   .mr_an_enable   ( mr_an_enable ), 
   .mr_main_reset  ( mr_main_reset ),  
   .mr_restart_an  ( mr_restart_an ),   

   .mr_an_complete    ( mr_an_complete ),   
   .mr_lp_adv_ability ( mr_lp_adv_ability ), 
   .mr_page_rx        ( mr_page_rx )
   );
        
);

