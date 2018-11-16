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

module rst_ctrl(clk, rst, crn, rn, cnt);
output reg rst; //reset control
input clk; //clock
input wire [7:0] crn; //Telegram repetition number count received from buffer module
input wire [7:0] rn; //Telegram repetition number count received from gen module
input wire [3:0] cnt; //Count of no. of receives from buffer module

always@(posedge clk)
begin
if (crn == rn)		
	rst = 0; 
else if (cnt == 4'b1011)
	rst = 1;
end

endmodule