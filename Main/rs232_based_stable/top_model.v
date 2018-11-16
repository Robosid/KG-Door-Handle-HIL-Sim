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



`timescale 1ns/10ps
 
`include "uart_tx.v"
`include "uart_rx.v"
 
module top_model (r_Clock, out, rx_in);

input wire r_Clock;			//better be 10MHz
input reg rx_in;
output wire out;

 
  // if the module uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8600;
   
  //reg r_Clock = 0;
  reg r_Tx_DV = 0;
  wire w_Tx_Done;
  reg [7:0] r_Tx_Byte = 0;
  //reg r_Rx_Serial; 			using rx_in instead
  reg rst = 0;  			
  wire [7:0] w_Rx_Byte;
  wire w_Rx_DV; 
  reg test = 0; 
  reg test2 = 0;
//
wire clk_out;
wire reset;
reg [9:0] fall;
reg [15:0] rise;
wire [7:0] rep_number;
wire [7:0] count_rep_number;
wire [7:0] Tele_Byte_Tele;
wire [15:0] high_ON_ON_high;
wire [15:0] low_ON_ON_low;
wire [15:0] imp_ON_ON_imp;
wire [15:0]  stop_ON_ON_stop;
wire [9:0] fall_fall;
wire [15:0] rise_rise;
wire clk_out_clk_out;
wire [3:0] count_cnt;
//
// 
/*
integer count = 0;
//
  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_Data;
    integer     ii;
    begin
       
      // Send Start Bit
      r_Rx_Serial <= 1'b0;
	rst = 0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          r_Rx_Serial <= i_Data[ii];
          #(c_BIT_PERIOD);
        end
       
      // Send Stop Bit
      r_Rx_Serial <= 1'b1;
      rst = 1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE
  */ 
   
  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST
    (.i_Clock(r_Clock),
     .i_Rx_Serial(rx_in), // rx_in instead of r_Rx_Serial
     .o_Rx_DV(w_Rx_DV),
     .o_Rx_Byte(w_Rx_Byte)
     );
   
  /*uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST
    (.i_Clock(r_Clock),
     .i_Tx_DV(r_Tx_DV),
     .i_Tx_Byte(r_Tx_Byte),
     .o_Tx_Active(),
     .o_Tx_Serial(),
     .o_Tx_Done(w_Tx_Done)
     );
*/
 
sqwaveGen sqwave(.clk(r_Clock),.reset(reset),.rise(rise_rise),.fall(fall_fall),.clk_out(clk_out_clk_out));
gen gen1(.clk_out(clk_out_clk_out),.reset(reset), .Tele(Tele_Byte_Tele), .ON_high(high_ON_ON_high), .ON_low(low_ON_ON_low) , .ON_imp(imp_ON_ON_imp), .rise(rise_rise),.fall(fall_fall), .count_no_rep(count_rep_number), .ON_stop(stop_ON_ON_stop));
buffer buffer1(.clk(r_Clock), .rst(w_Rx_DV),.Rx_Byte(w_Rx_Byte), .Tele_Byte(Tele_Byte_Tele), .rep_no(rep_number),  .high_ON(high_ON_ON_high), .low_ON(low_ON_ON_low), .imp_ON(imp_ON_ON_imp), .stop_ON(stop_ON_ON_stop),.count(count_cnt)); 
rst_ctrl rst_ctrl1(.clk(r_Clock), .rst(reset), .crn(count_rep_number), .rn(rep_number), .cnt(count_cnt));
//-------------------------------------------------------------------------------------------------------------------   
// Test Clock Generator
//--------------------------------------------------------------------------------------------------------------------------- 
 // always
 //   #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;                 instead set sys_clk to 10Mhz
//-------------------------------------------------------------------------------------------------------------------------- 
  /* 
  // Main Testing:
  initial
    begin
             
	//reset=0;
      // Tell UART to send a command (exercise Tx)
      @(posedge r_Clock);
      @(posedge r_Clock);
      r_Tx_DV <= 1'b1;
      r_Tx_Byte <= 8'hAB;
      @(posedge r_Clock);
      r_Tx_DV <= 1'b0;
      @(posedge w_Tx_Done);
       
      // Send a command to the UART (exercise Rx)
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h64);			//1
      @(posedge r_Clock);
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h64)
      begin
	assign test = 1;
	 count = 1;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;


      // Send a command to the UART (exercise Rx)

      UART_WRITE_BYTE(8'h32);		//2
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h32)
      begin
	assign test = 1;
	count = 2;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

      // Send a command to the UART (exercise Rx)

      UART_WRITE_BYTE(8'h34);		//3

             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h34)
      begin
	assign test = 1;
	 count = 3;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

      // Send a command to the UART (exercise Rx)

      UART_WRITE_BYTE(8'h08);		//4

             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h08)
      begin
	assign test = 1;
	 count = 4;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

      // Send a command to the UART (exercise Rx)
 
      UART_WRITE_BYTE(8'h84);		//5
   
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h84)
      begin
	assign test = 1;
	 count = 5;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

      // Send a command to the UART (exercise Rx)
   
      UART_WRITE_BYTE(8'h03);		//6

             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h03)
      begin
	assign test = 1;
	 count = 6;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;      
	
// Send a command to the UART (exercise Rx)
 
      UART_WRITE_BYTE(8'h98);		//7
      
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h98)
      begin
	assign test = 1;
	count = 7;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

// Send a command to the UART (exercise Rx)
 
      UART_WRITE_BYTE(8'h3A);		//8
    
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h3A)
      begin
	assign test = 1;
	 count = 8;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

// Send a command to the UART (exercise Rx)
 
      UART_WRITE_BYTE(8'h50);		//9
    
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'h50)
      begin
	assign test = 1;
	 count = 9;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;

// Send a command to the UART (exercise Rx)
 
      UART_WRITE_BYTE(8'hC3);		//10
    
             
      // Check that the correct command was received
      if (w_Rx_Byte == 8'hC3)
      begin
	assign test = 1;
	 count = 10;
      end
      else
        //$display("Test Failed - Incorrect Byte Received");
	assign test2 = 1;


if (count == 10)
begin
	//reset = 1;					//Take care of this in top model
	 count = 0;
end
*/
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------

//end

//always@(posedge r_Clock)
//begin
//if (count_rep_number == rep_number)		//Take care of this in top model
	//reset = 0; 
//end

assign out = clk_out_clk_out;

endmodule