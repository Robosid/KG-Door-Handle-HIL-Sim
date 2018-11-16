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


module nios_system (
	clk_clk,
	reset_reset_n,
	tse_mac_mac_status_connection_set_10,
	tse_mac_mac_status_connection_set_1000,
	tse_mac_mac_status_connection_eth_mode,
	tse_mac_mac_status_connection_ena_10);	

	input		clk_clk;
	input		reset_reset_n;
	input		tse_mac_mac_status_connection_set_10;
	input		tse_mac_mac_status_connection_set_1000;
	output		tse_mac_mac_status_connection_eth_mode;
	output		tse_mac_mac_status_connection_ena_10;
endmodule
