// A simple circuit that can be used to detect brownouts and other hardware issues

module simulate (
  input clk,
  input rst,
  input [10:0] speed,
  output led
);

  // RED
	cycle simulate_cycle (
		.clk(clk),
		.rst(rst),
    .speed(speed),
 		.led(led)
	);

endmodule
