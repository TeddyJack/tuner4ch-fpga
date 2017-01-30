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