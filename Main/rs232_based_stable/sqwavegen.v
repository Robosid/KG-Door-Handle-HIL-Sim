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
 
module sqwaveGen(clk,reset,rise,fall,clk_out);
input wire clk;
input wire reset;
output wire clk_out;
input wire [15:0] rise; 
input wire [9:0] fall;
reg [15:0] count, count_on, count_off;
reg  pos_or_neg;
 
always @(posedge reset)
begin
	pos_or_neg <=0;
		
end
always @(posedge clk, negedge reset) 
begin
    if(~reset) 
		begin
		count<= 0;
		//count <= 0;
      		pos_or_neg <=1;
		end
		
	else  if ( (pos_or_neg ==1) ) 
	begin
		
		if ((count == count_on-1) ) 
		begin 
			count <=0;
			pos_or_neg <=0;  	  
		end
		
		else 
			count <= count+1;
	end
	else  if ( (pos_or_neg ==0) ) 
	begin
	
		if ((count == count_off-1) )
		begin 
			count <=0;
			pos_or_neg <=1;  	  
		end
		
		else 
			count <= count+1;
	end
end

always @(posedge reset)
begin
	pos_or_neg <= 0;
		
end
 
always @(rise, fall)
begin
count_on <= rise;
count_off <= fall;	
end	
 
assign clk_out = pos_or_neg;
 
endmodule