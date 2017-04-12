
create_clock -name "CLK_IN" -period 25MHz [get_ports CLK_IN]

# added constraints for maximum frequency
for {set i 0} {$i < 4} {incr i} {
	create_clock -name "DCLK_$i" -period 10MHz [get_ports DCLK[$i]]
}

derive_pll_clocks

# ignore paths
for {set i 0} {$i < 4} {incr i} {
	set_false_path -from "DCLK_$i" -to pll_for_ts_muxer|altpll_component|auto_generated|pll1|clk[0]
}

derive_clock_uncertainty