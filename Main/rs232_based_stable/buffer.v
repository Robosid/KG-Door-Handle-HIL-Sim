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



module buffer(clk, rst, Rx_Byte, Tele_Byte, rep_no,  high_ON, low_ON, imp_ON, stop_ON, count);
input wire [7:0] Rx_Byte;
input wire clk;
input wire rst;

output reg [7:0] Tele_Byte;
output reg [7:0] rep_no = 0;
output reg [15:0] high_ON;
output reg [15:0] low_ON;
output reg [15:0] imp_ON;
output reg [15:0] stop_ON;
output reg [3:0] count = 4'b0001;
//Internal//
reg okay = 1;
//
always @(posedge rst) 
begin

	if(okay)
	begin
		if (count == 4'b0000)
		begin
			 count = count + 4'b0001;
		end
		else if (count == 4'b0001)
		begin
			Tele_Byte = Rx_Byte;
			 count = count + 4'b0001;
		end
		
		else if (count == 4'b0010)
		begin
			rep_no = Rx_Byte;
			 count = count + 4'b0001;
		end

		else if (count == 4'b0011)
		begin
			high_ON[7:0] = Rx_Byte;
			count = count + 4'b0001;
		end
		
		else if (count == 4'b0100)
		begin
			high_ON[15:8] = Rx_Byte;
			 count = count + 4'b0001;
		end

		else if (count == 4'b0101)
		begin
			low_ON[7:0] = Rx_Byte;
			count = count + 4'b0001;
		end
		
		else if (count == 4'b0110)
		begin
			low_ON[15:8] = Rx_Byte;
			 count = count + 4'b0001;
		end
		
		else if (count == 4'b0111)
		begin
			imp_ON[7:0] = Rx_Byte;
			count = count + 4'b0001;
		end
		
		else if (count == 4'b1000)
		begin
			imp_ON[15:8] = Rx_Byte;
			count = count + 4'b0001;
		end
		else if (count == 4'b1001)
		begin
			stop_ON[7:0] = Rx_Byte;
			count = count + 4'b0001;
		end
		else if (count == 4'b1010)
		begin
			stop_ON[15:8] = Rx_Byte;
			count = count + 4'b0001;
		end
	end
end

	always @(posedge clk) 
	begin
		if (count == 4'b1011)
		begin
			count = 4'b0001;
			//okay = 0;
		end
	end
endmodule
			