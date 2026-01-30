# System Clock
create_clock -name clk -period 5.250 [get_ports clk]

# Programming Clock
create_clock -name prog_clk -period 5.250 [get_ports prog_clk]

# Declare asynch clocks
set_clock_groups -asynchronous -group [get_clocks clk] -group [get_clocks prog_clk]

# Input Delays - clk
#set_input_delay -clock [get_clocks clk] -max 5.000 [get_ports {reset load_config dm_reset ecg_in[*]}]
#set_input_delay -clock [get_clocks clk] -min 1.000 [get_ports {reset load_config dm_reset ecg_in[*]}]

## Input Delays - prog_clk
#set_input_delay -clock [get_clocks prog_clk] -max 5.000 [get_ports prog_data]
#set_input_delay -clock [get_clocks prog_clk] -min 1.000 [get_ports prog_data]

## Output Delays
#set_output_delay -clock [get_clocks clk] -max 5.000 [get_ports {fire[*] winner[*]}]
#set_output_delay -clock [get_clocks clk] -min -1.000 [get_ports {fire[*] winner[*]}]
