# Clock constraints
create_clock -name "BOARD_CLK" -period 27MHz [get_ports {BOARD_CLK}]
create_clock -name "RESERVE_CLK" -period 25.175MHz [get_ports {RESERVE_CLK}]

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# Automatically calculate clock uncertainty to jitter and other effects.
derive_clock_uncertainty

# tsu/th constraints

# tco constraints

# tpd constraints