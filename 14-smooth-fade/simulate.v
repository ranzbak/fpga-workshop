// A simple circuit that can be used to detect brownouts and other hardware issues

module simulate #(
  parameter START_POS=0
) (
  input i_clk,
  input i_rst,
  input [15:0] i_speed,
  output o_led
);

  // RED
	cycle #(
    .START_POS(START_POS)
  ) simulate_cycle (
		.i_clk(i_clk),
		.i_rst(i_rst),
    .i_speed(i_speed),
 		.o_led(o_led)
	);

endmodule
