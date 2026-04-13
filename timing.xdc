# Define a 100 MHz clock (10ns period) on your 'clk' port
create_clock -period 10.000 -name sys_clk [get_ports clk]
