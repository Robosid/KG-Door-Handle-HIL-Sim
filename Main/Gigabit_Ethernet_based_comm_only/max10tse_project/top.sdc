#Create PLL reference clock
create_clock -name {clk_50_max10} -period "50 MHz" [get_ports {clk_50_max10}]
#Virtual clock for input constraints
create_clock -name virtual_clk_125 -period 8
create_clock -name virtual_clk_25 -period 40
create_clock -name virtual_clk_2p5 -period 400
#Define RX clocks from PHY
create_clock -period 8 -waveform { 2 6 } -name  {rx_clk_125} [get_ports enet_rx_clk]
create_clock -period 40 -waveform { 10 30 } -name  {rx_clk_25} [get_ports enet_rx_clk] -add
create_clock -period 400 -waveform { 100 300 } -name  {rx_clk_2p5} [get_ports enet_rx_clk] -add
#PLL clocks for triple speed Ethernet
create_generated_clock -name enet_tx_125 -source [get_pins {i_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 2 -master_clock {clk_50_max10} [get_pins {i_pll|altpll_component|auto_generated|pll1|clk[0]}] 
##Shifted 125MHz clock for timing closure in MAX10 device
create_generated_clock -name enet_tx_125_shift -source [get_pins {i_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 2 -phase 11.25 -master_clock {clk_50_max10} [get_pins {i_pll|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name enet_tx_25 -source [get_pins {i_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock {clk_50_max10} [get_pins {i_pll|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name enet_tx_2p5 -source [get_pins {i_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 20 -master_clock {clk_50_max10} [get_pins {i_pll|altpll_component|auto_generated|pll1|clk[2]}] 
#GTX clocks to PHY
create_generated_clock -name gtx_125_clk -source [get_pins {clkctrl_inst1|altclkctrl_0|clkctrl_altclkctrl_0_sub_component|clkctrl1|outclk}] -master_clock {enet_tx_125_shift} [get_ports {enet_gtx_clk}]
create_generated_clock -name gtx_25_clk -source [get_pins {clkctrl_inst0|altclkctrl_0|clkctrl_altclkctrl_0_sub_component|clkctrl1|outclk}] -master_clock {enet_tx_25} [get_ports {enet_gtx_clk}] -add
create_generated_clock -name gtx_2p5_clk -source [get_pins {clkctrl_inst0|altclkctrl_0|clkctrl_altclkctrl_0_sub_component|clkctrl1|outclk}] -master_clock {enet_tx_2p5} [get_ports {enet_gtx_clk}] -add

derive_clock_uncertainty

# RGMII TX channel
# Output Delay Constraints (Edge Aligned, Same Edge Capture)
# +---------------------------------------------------

set output_max_delay -0.9
set output_min_delay -2.7

post_message -type info "Output Max Delay = $output_max_delay"
post_message -type info "Output Min Delay = $output_min_delay"

set_output_delay -clock gtx_125_clk -max $output_max_delay [get_ports "enet_tx_d* enet_tx_en"]
set_output_delay -clock gtx_125_clk -max $output_max_delay [get_ports "enet_tx_d* enet_tx_en"] -clock_fall -add_delay
set_output_delay -clock gtx_125_clk -min $output_min_delay [get_ports "enet_tx_d* enet_tx_en"] -add_delay
set_output_delay -clock gtx_125_clk -min $output_min_delay [get_ports "enet_tx_d* enet_tx_en"] -clock_fall -add_delay

set_output_delay -clock gtx_25_clk -max $output_max_delay [get_ports "enet_tx_d* enet_tx_en"] -add_delay
set_output_delay -clock gtx_25_clk -max $output_max_delay [get_ports "enet_tx_d* enet_tx_en"] -clock_fall -add_delay
set_output_delay -clock gtx_25_clk -min $output_min_delay [get_ports "enet_tx_d* enet_tx_en"] -add_delay
set_output_delay -clock gtx_25_clk -min $output_min_delay [get_ports "enet_tx_d* enet_tx_en"] -clock_fall -add_delay

set_output_delay -clock gtx_2p5_clk -max $output_max_delay [get_ports "enet_tx_d* enet_tx_en"] -add_delay
set_output_delay -clock gtx_2p5_clk -max $output_max_delay [get_ports "enet_tx_d* enet_tx_en"] -clock_fall -add_delay
set_output_delay -clock gtx_2p5_clk -min $output_min_delay [get_ports "enet_tx_d* enet_tx_en"] -add_delay
set_output_delay -clock gtx_2p5_clk -min $output_min_delay [get_ports "enet_tx_d* enet_tx_en"] -clock_fall -add_delay

# Set multicycle paths to align the launch edge with the latch edge
# Not needed for 125MHz GTX clock as the clock was shifted

set_multicycle_path -setup -end -rise_from [get_clocks enet_tx_25] -rise_to [get_clocks gtx_25_clk] 0
set_multicycle_path -setup -end -fall_from [get_clocks enet_tx_25] -fall_to [get_clocks gtx_25_clk] 0
set_multicycle_path -hold -end -rise_from [get_clocks enet_tx_25] -rise_to [get_clocks gtx_25_clk] -1
set_multicycle_path -hold -end -fall_from [get_clocks enet_tx_25] -fall_to [get_clocks gtx_25_clk] -1

set_multicycle_path -setup -end -rise_from [get_clocks enet_tx_2p5] -rise_to [get_clocks gtx_2p5_clk] 0
set_multicycle_path -setup -end -fall_from [get_clocks enet_tx_2p5] -fall_to [get_clocks gtx_2p5_clk] 0
set_multicycle_path -hold -end -rise_from [get_clocks enet_tx_2p5] -rise_to [get_clocks gtx_2p5_clk] -1
set_multicycle_path -hold -end -fall_from [get_clocks enet_tx_2p5] -fall_to [get_clocks gtx_2p5_clk] -1

# Set false paths to remove irrelevant setup and hold analysis
set_false_path -fall_from [get_clocks enet_tx_125] -rise_to [get_clocks gtx_125_clk] -setup
set_false_path -rise_from [get_clocks enet_tx_125] -fall_to [get_clocks gtx_125_clk] -setup
set_false_path -fall_from [get_clocks enet_tx_125] -fall_to [get_clocks gtx_125_clk] -hold
set_false_path -rise_from [get_clocks enet_tx_125] -rise_to [get_clocks gtx_125_clk] -hold

set_false_path -fall_from [get_clocks enet_tx_25] -rise_to [get_clocks gtx_25_clk] -setup
set_false_path -rise_from [get_clocks enet_tx_25] -fall_to [get_clocks gtx_25_clk] -setup
set_false_path -fall_from [get_clocks enet_tx_25] -fall_to [get_clocks gtx_25_clk] -hold
set_false_path -rise_from [get_clocks enet_tx_25] -rise_to [get_clocks gtx_25_clk] -hold

set_false_path -fall_from [get_clocks enet_tx_2p5] -rise_to [get_clocks gtx_2p5_clk] -setup
set_false_path -rise_from [get_clocks enet_tx_2p5] -fall_to [get_clocks gtx_2p5_clk] -setup
set_false_path -fall_from [get_clocks enet_tx_2p5] -fall_to [get_clocks gtx_2p5_clk] -hold
set_false_path -rise_from [get_clocks enet_tx_2p5] -rise_to [get_clocks gtx_2p5_clk] -hold


# RGMII RX channel
# Input Delay Constraints (Center aligned, Same Edge Analysis)
# 125MHz input constraints
set input_max_delay_125 0.8
set input_min_delay_125 -0.8

post_message -type info "Input Max Delay for 125MHz domain= $input_max_delay_125"
post_message -type info "Input Min Delay for 125MHz domain= $input_min_delay_125"

set_input_delay -max [expr $input_max_delay_125 ] -clock [get_clocks virtual_clk_125] [get_ports "enet_rx_d* enet_rx_dv"]
set_input_delay -max [expr $input_max_delay_125 ] -clock [get_clocks virtual_clk_125] [get_ports "enet_rx_d* enet_rx_dv"] -clock_fall -add_delay
set_input_delay -min [expr $input_min_delay_125 ] -clock [get_clocks virtual_clk_125] [get_ports "enet_rx_d* enet_rx_dv"] -add_delay
set_input_delay -min [expr $input_min_delay_125 ] -clock [get_clocks virtual_clk_125] [get_ports "enet_rx_d* enet_rx_dv"] -clock_fall -add_delay

# Set false paths to remove irrelevant setup and hold analysis
set_false_path -fall_from [get_clocks virtual_clk_125] -rise_to [get_clocks {rx_clk_125}] -setup
set_false_path -rise_from [get_clocks virtual_clk_125] -fall_to [get_clocks {rx_clk_125}] -setup
set_false_path -fall_from [get_clocks virtual_clk_125] -fall_to [get_clocks {rx_clk_125}] -hold
set_false_path -rise_from [get_clocks virtual_clk_125] -rise_to [get_clocks {rx_clk_125}] -hold

# 25MHz input constraints
set input_max_delay_25 8.8
set input_min_delay_25 -8.8

post_message -type info "Input Max Delay for 25MHz domain = $input_max_delay_25"
post_message -type info "Input Min Delay for 25MHz domain = $input_min_delay_25"

set_input_delay -max [expr $input_max_delay_25 ] -clock [get_clocks virtual_clk_25] [get_ports "enet_rx_d* enet_rx_dv"] -add_delay
set_input_delay -max [expr $input_max_delay_25 ] -clock [get_clocks virtual_clk_25] [get_ports "enet_rx_d* enet_rx_dv"] -clock_fall -add_delay
set_input_delay -min [expr $input_min_delay_25 ] -clock [get_clocks virtual_clk_25] [get_ports "enet_rx_d* enet_rx_dv"] -add_delay
set_input_delay -min [expr $input_min_delay_25 ] -clock [get_clocks virtual_clk_25] [get_ports "enet_rx_d* enet_rx_dv"] -clock_fall -add_delay

# Set false paths to remove irrelevant setup and hold analysis
set_false_path -fall_from [get_clocks virtual_clk_25] -rise_to [get_clocks {rx_clk_25}] -setup
set_false_path -rise_from [get_clocks virtual_clk_25] -fall_to [get_clocks {rx_clk_25}] -setup
set_false_path -fall_from [get_clocks virtual_clk_25] -fall_to [get_clocks {rx_clk_25}] -hold
set_false_path -rise_from [get_clocks virtual_clk_25] -rise_to [get_clocks {rx_clk_25}] -hold

# 2.5MHz input constraints
set input_max_delay_2p5 98.8
set input_min_delay_2p5 -98.8

post_message -type info "Input Max Delay for 2.5MHz domain = $input_max_delay_2p5"
post_message -type info "Input Min Delay for 2.5MHz domain = $input_min_delay_2p5"

set_input_delay -max [expr $input_max_delay_2p5 ] -clock [get_clocks virtual_clk_2p5] [get_ports "enet_rx_d* enet_rx_dv"] -add_delay
set_input_delay -max [expr $input_max_delay_2p5 ] -clock [get_clocks virtual_clk_2p5] [get_ports "enet_rx_d* enet_rx_dv"] -clock_fall -add_delay
set_input_delay -min [expr $input_min_delay_2p5 ] -clock [get_clocks virtual_clk_2p5] [get_ports "enet_rx_d* enet_rx_dv"] -add_delay
set_input_delay -min [expr $input_min_delay_2p5 ] -clock [get_clocks virtual_clk_2p5] [get_ports "enet_rx_d* enet_rx_dv"] -clock_fall -add_delay

# Set false paths to remove irrelevant setup and hold analysis
set_false_path -fall_from [get_clocks virtual_clk_2p5] -rise_to [get_clocks {rx_clk_2p5}] -setup
set_false_path -rise_from [get_clocks virtual_clk_2p5] -fall_to [get_clocks {rx_clk_2p5}] -setup
set_false_path -fall_from [get_clocks virtual_clk_2p5] -fall_to [get_clocks {rx_clk_2p5}] -hold
set_false_path -rise_from [get_clocks virtual_clk_2p5] -rise_to [get_clocks {rx_clk_2p5}] -hold

#Remove irrelevant clock domain crossing analysis
set_clock_groups -exclusive -group {enet_tx_125 gtx_125_clk virtual_clk_125 rx_clk_125} -group {enet_tx_25 gtx_25_clk virtual_clk_25 rx_clk_25} -group {enet_tx_2p5 gtx_2p5_clk virtual_clk_2p5 rx_clk_2p5}

set_false_path -to [get_registers *sld_signaltap*]
