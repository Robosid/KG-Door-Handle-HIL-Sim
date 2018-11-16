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

`timescale 1ns/1ns
module sqwavegentb;
wire clk_out;
reg clk,reset;
reg [9:0] fall;
reg [15:0] rise;
wire a_a , b_b, c_c, d_d, e_e, f_f;
wire [9:0] fall_fall;
wire [15:0] rise_rise;
wire clk_out_clk_out;  
etho eth(.clk,.a(a_a),.b(b_b),.c(c_c),.d(d_d),.e(e_e),.f(f_f));
sqwaveGen sqwave(.clk,.reset(reset),.rise(rise_rise),.fall(fall_fall),.clk_out(clk_out_clk_out));
gen gen1(.clk_out(clk_out_clk_out),.reset(reset),.a(a_a),.b(b_b),.c(c_c),.d(d_d),.e(e_e),.f(f_f),.rise(rise_rise),.fall(fall_fall));

initial
clk = 1'b1;
always
#20 clk = ~clk;
initial
begin
$monitor($time,"clk = %b,reset = %b,clk_out = %b,rise = %b,fall = %b",clk,reset,clk_out,rise,fall);
reset=0;
#150000 reset = 1;
#2000000 $finish;
end
initial
begin
    $dumpfile ("sqwavegentb.vcd");
    $dumpvars (0,sqwavegentb);
end
endmodule