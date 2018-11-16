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

module gen(clk_out, reset, Tele, ON_high, ON_low , ON_imp, rise, fall, count_no_rep, ON_stop);

input wire clk_out;
input wire reset;
input wire [7:0] Tele;
input wire [15:0] ON_imp;
input wire [15:0] ON_low;
input wire [15:0] ON_high;
input wire [15:0] ON_stop;
output reg [15:0] rise; 
output reg [9:0] fall;

wire a = Tele[0];
wire b = Tele[1];
wire c = Tele[2];
wire d = Tele[3];
wire e = Tele[4];
wire f = Tele[5];
wire g = Tele[6];

reg i;
reg cnt;
reg [2:0] state;
output reg [7:0] count_no_rep = 0;

always @(negedge clk_out)
begin
	if (cnt == 0)
		begin		
			cnt <= 1;
			i <= a;
			state <= 3'b000;
			//assign rise = 15'b100111000100000;
			assign rise = ON_imp;
			assign fall = 10'b1111101000;
		end
	else
	begin
	
	if (state == 3'b111)
	begin
		//assign rise = 16'b1100001101010000;
		assign rise = ON_stop;
		assign fall = 10'b1111101000;
	end
	else if ( i == 0)
		begin
			//assign rise = 10'b1111101000;
			assign rise = ON_low;
			assign fall = 10'b1111101000;
		end
	else if (i == 1)
		begin
			//assign rise = 11'b11111010000;
			assign rise = ON_high;
			assign fall = 10'b1111101000;
		end
	
	if ( state == 3'b000)
	begin
		i <= b;
		state <= 3'b001;
	end
	else if ( state == 3'b001)
	begin
		i <= c;
		state <= 3'b010;
	end
	else if(state == 3'b010)
	begin
		i <= d;
		state <= 3'b011;
	end
	else if(state == 3'b011 && g == 0) //g == 1 means no NFC , state bypass / ignore
	begin
		i <= e;
		state <= 3'b100;
	end
	else if(state == 3'b100 || state == 3'b011)
	begin
		i <= f;
		state <= 3'b101;
	end
	else if(state == 3'b101)
	begin 
		state <= 3'b111;
	end
	else if(state == 3'b111)
	begin
		state <= 3'b000;
		i <= a ;
		 assign count_no_rep = count_no_rep + 1'b1;
		
	end
end
end

always @(posedge reset)
begin
	cnt<=0;
	assign count_no_rep = 0;

end

/*always @(~reset)
begin
	cnt<=0;
end
*/
endmodule
	
		
	