/*Copyright [2018] [Siddhant Mahapatra]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://github.com/Robosid/Drone-Intelligence/blob/master/License.rtf
    https://github.com/Robosid/Drone-Intelligence/blob/master/License.pdf

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


module top (
	  //Clock and Reset
	  input  wire        clk_50_max10,
	  input  wire        fpga_resetn,

	  //LED ,PUSH BUTTON, DIPSW
	  output wire [4:0]  user_led,
	  input  wire [3:0]  user_pb,

	  //Ethernet
	  output wire        enet_mdc,
	  inout  wire        enet_mdio,
	  output wire        enet_resetn,	
	  input  wire        enet_rx_clk,
	  output wire        enet_gtx_clk,
	  input  wire [3:0]  enet_rx_d,
	  output wire [3:0]  enet_tx_d,
	  output wire        enet_tx_en,
	  input  wire        enet_rx_dv

);

//Heart-beat counter
reg   [25:0]  heart_beat_cnt;

wire          phy_resetn;
wire          system_resetn;
wire          mdio_oen_from_the_tse_mac;
wire          mdio_out_from_the_tse_mac;
wire          eth_mode_from_the_tse_mac;
wire          ena_10_from_the_tse_mac;
wire          enet_tx_125;
wire          enet_tx_25;
wire          enet_tx_2p5;
wire          tx_clk_to_the_tse_mac;
wire          tx_clk_to_the_tse_mac_g;
wire          enet_rx_clk_g;
wire 				gtx_clk125_shift,enet_tx_125_shift;
//Ethernet interface assignments
wire [3:0]	  debounced_user_pb;

//MDIO output control
assign enet_mdio = ( !mdio_oen_from_the_tse_mac ) ? ( mdio_out_from_the_tse_mac ) : ( 1'bz );

////////////////////////////////////////////////////////////////////////////
//debounce and set correct polarity of reset signal
// fpga_resetn
reg				u_resetn_r1, u_resetn_r2, resetn ;
reg [19:0] db_count;	// Debounce counter

always @ (posedge clk_50_max10)  begin
   // This should create a long pulse clock 
   if (db_count[19]) begin
      db_count <= #1 20'd0;
   end else begin
      db_count <= #1 db_count + 20'd1;
   end
	
   // Debounce and double register
   if (db_count[19]) begin  // use db_count[19] as an enable
      u_resetn_r1 <= #1 fpga_resetn;
      u_resetn_r2 <= #1 u_resetn_r1;

      if (u_resetn_r2 == u_resetn_r1) begin
         resetn <= #1 u_resetn_r2;
      end else begin
         resetn <= #1 1'b0; // Keep in reset
      end	  
   end
end

//PHY power-on reset control
parameter MSB = 20; // PHY interface: need minimum 10ms delay for POR
reg [MSB:0] epcount;

always @(posedge clk_50_max10 or negedge resetn) begin
  if (!resetn)
      epcount <= MSB + 1'b0;
  else if (epcount[MSB] == 1'b0)
      epcount <= epcount + 1;
  else
      epcount <= epcount;
end

// Debounce logic to clean out glitches within 1ms
debounce debounce_inst (
.clk          (clk_50_max10),
.reset_n      (resetn),  
.data_in      (user_pb),
.data_out     (debounced_user_pb)
);
defparam debounce_inst.WIDTH = 4;
defparam debounce_inst.POLARITY = "LOW";
defparam debounce_inst.TIMEOUT = 50000;               // at 50Mhz this is a debounce time of 1ms
defparam debounce_inst.TIMEOUT_WIDTH = 16;            // ceil(log2(TIMEOUT))

assign phy_resetn    =  debounced_user_pb[0] & !epcount[MSB-1];
assign enet_resetn   = phy_resetn;
assign system_resetn = resetn;

//RGMII clock solution
assign tx_clk_to_the_tse_mac = ( eth_mode_from_the_tse_mac ) ? ( enet_tx_125 ) :  // GbE Mode = 125MHz clock
                               ( ena_10_from_the_tse_mac ) ? ( enet_tx_2p5 ) :    // 10Mb Mode = 2.5MHz clock
                               ( enet_tx_25 );                                    // 100Mb Mode = 25MHz clock
assign gtx_clk125_shift = ( eth_mode_from_the_tse_mac ) ? ( enet_tx_125_shift ) :  // GbE Mode = 125MHz clock
                               ( ena_10_from_the_tse_mac ) ? ( enet_tx_2p5 ) :    // 10Mb Mode = 2.5MHz clock
                               ( enet_tx_25 );  
										 
										 
clkctrl  clkctrl_inst0 (
   .inclk        (tx_clk_to_the_tse_mac),
   .outclk       (tx_clk_to_the_tse_mac_g)
);

clkctrl  clkctrl_inst1 (
   .inclk        (gtx_clk125_shift),
   .outclk       (gtx_clk125_shift_g)
);

//ksting clkctrl  clkctrl_inst1 (
//ksting    .inclk        (enet_rx_clk),
//ksting    .outclk       (enet_rx_clk_g)
//ksting );

//Heart beat by 50MHz clock
always @(posedge clk_50_max10 or negedge resetn)
  if (!resetn)
      heart_beat_cnt <= 26'h0; //0x3FFFFFF
  else
      heart_beat_cnt <= heart_beat_cnt + 1'b1;

assign user_led[4] = heart_beat_cnt[25];
assign user_led[2:0] = 3'b0; // Unused


gtx_clk gtx_clk_inst (
.outclock (gtx_clk125_shift_g),
.din(2'b01),
.pad_out(enet_gtx_clk)
);


pll i_pll (
	.areset (~resetn),
	.inclk0 (clk_50_max10),
	.c0 (enet_tx_125),
	.c1 (enet_tx_25),
	.c2 (enet_tx_2p5),
	.c3 (enet_tx_125_shift),
	.locked (user_led[3])
);

qsys_top qsys_top_0 (
   .triple_speed_ethernet_0_mac_misc_connection_xon_gen (1'b0),
   .triple_speed_ethernet_0_mac_misc_connection_xoff_gen (1'b0),     
   .triple_speed_ethernet_0_mac_misc_connection_ff_tx_crc_fwd (1'b0),
   .triple_speed_ethernet_0_mac_misc_connection_ff_tx_septy (),
   .triple_speed_ethernet_0_mac_misc_connection_tx_ff_uflow (),
   .triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_full (),
   .triple_speed_ethernet_0_mac_misc_connection_ff_tx_a_empty (),
   .triple_speed_ethernet_0_mac_misc_connection_rx_err_stat (),
   .triple_speed_ethernet_0_mac_misc_connection_rx_frm_type (),
   .triple_speed_ethernet_0_mac_misc_connection_ff_rx_dsav (),
   .triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_full (),
   .triple_speed_ethernet_0_mac_misc_connection_ff_rx_a_empty (),

	.triple_speed_ethernet_0_mac_status_connection_eth_mode	(eth_mode_from_the_tse_mac),
	.triple_speed_ethernet_0_mac_status_connection_ena_10   	(ena_10_from_the_tse_mac),
	.triple_speed_ethernet_0_mac_rgmii_connection_rgmii_in   (enet_rx_d),
	.triple_speed_ethernet_0_mac_mdio_connection_mdc      	(enet_mdc),
	.triple_speed_ethernet_0_pcs_mac_tx_clock_connection_clk (tx_clk_to_the_tse_mac_g),
	.triple_speed_ethernet_0_mac_rgmii_connection_tx_control	(enet_tx_en),
	.triple_speed_ethernet_0_mac_status_connection_set_1000  (1'b0),
	.triple_speed_ethernet_0_mac_mdio_connection_mdio_out  	(mdio_out_from_the_tse_mac),
	.triple_speed_ethernet_0_mac_rgmii_connection_rgmii_out  (enet_tx_d),
	.triple_speed_ethernet_0_pcs_mac_rx_clock_connection_clk (enet_rx_clk),
//ksting   .triple_speed_ethernet_0_pcs_mac_rx_clock_connection_clk (clk_50_max10),
	.triple_speed_ethernet_0_mac_mdio_connection_mdio_oen 	(mdio_oen_from_the_tse_mac),
	.triple_speed_ethernet_0_mac_status_connection_set_10    (1'b0),
	.triple_speed_ethernet_0_mac_mdio_connection_mdio_in    	(enet_mdio),
	.triple_speed_ethernet_0_mac_rgmii_connection_rx_control (enet_rx_dv),
	.reset_reset_n                                   		   (system_resetn),
	.clk_clk                                					   (enet_tx_125)
);

endmodule 
