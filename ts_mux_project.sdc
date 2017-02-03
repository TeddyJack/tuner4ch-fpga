# Clock constraints
create_clock -name "CLK_IN" -period 25MHz [get_ports {CLK_IN}]
# added constraints for maximum frequency
create_clock -name "DCLK[0]" -period 10MHz [get_ports {DCLK[0]}]
create_clock -name "DCLK[1]" -period 10MHz [get_ports {DCLK[1]}]
create_clock -name "DCLK[2]" -period 10MHz [get_ports {DCLK[2]}]
create_clock -name "DCLK[3]" -period 10MHz [get_ports {DCLK[3]}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints

# ignore paths
set_false_path -from [get_clocks DCLK[0]] -to [get_clocks pll_for_ts_muxer|altpll_component|auto_generated|pll1|clk[1]]
set_false_path -from [get_clocks DCLK[1]] -to [get_clocks pll_for_ts_muxer|altpll_component|auto_generated|pll1|clk[1]]
set_false_path -from [get_clocks DCLK[2]] -to [get_clocks pll_for_ts_muxer|altpll_component|auto_generated|pll1|clk[1]]