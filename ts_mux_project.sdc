# Clock constraints
create_clock -name "CLK_IN" -period 25MHz [get_ports {CLK_IN}]
# added constraints for maximum frequency
create_clock -name "DCLK_0" -period 10MHz [get_ports {DCLK_0}]
create_clock -name "DCLK_1" -period 10MHz [get_ports {DCLK_1}]
create_clock -name "DCLK_2" -period 10MHz [get_ports {DCLK_2}]
create_clock -name "DCLK_3" -period 10MHz [get_ports {DCLK_3}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints