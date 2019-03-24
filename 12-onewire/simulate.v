// A simple circuit that can be used to detect brownouts and other hardware issues

module sim_top (
  input clk,
  input rst,
  output O_LED_R,
  output O_LED_G,
  output O_LED_B,
  input  I_ONE_WIRE,
  output O_ONE_WIRE
);
	wire clk, led_r, led_g, led_b, one_wire, owr_in, owr_out;

  // temperature sensor
	temp my_temp (
		.clk(clk),
		.rst(rst),
    .led_r(led_r),
    .led_g(led_g),
    .led_b(led_b),
    .owr_in(owr_in),
    .owr_out(owr_out)
	);
  defparam my_temp.CDR_N = 4; // small devider for simulation
  defparam my_temp.CDR_O = 0;  


  // Handle the inout
  //assign one_wire = out_enable == 1 ? pull_down:1'bz;
  assign O_ONE_WIRE = owr_out;
  assign owr_in = I_ONE_WIRE;

	assign O_LED_R = led_r;
	assign O_LED_G = led_g;
	assign O_LED_B = led_b;

endmodule
