create_clock -period "50.000000 MHz" [get_ports CLOCK2_50]
create_clock -period "50.000000 MHz" [get_ports CLOCK3_50]
create_clock -period "50.000000 MHz" [get_ports CLOCK4_50]
create_clock -period "50.000000 MHz" [get_ports CLOCK_50]

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

derive_pll_clocks
derive_clock_uncertainty