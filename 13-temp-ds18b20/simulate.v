// Testing the circuit with altered clock deviders

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
  read_temp #(
    .CDR_N(4),
    .CDR_O(0)
    ) my_temp (
    .i_clk(clk),
    .i_rst(rst),
    .o_led_r(led_r),
    .o_led_g(led_g),
    .o_led_b(led_b),
    .i_owr(owr_in),
    .o_owr(owr_out)
  );
  //defparam my_temp.CDR_N = 1; // small devider for simulation
  //defparam my_temp.CDR_O = 0;


  // Handle the inout
  assign O_ONE_WIRE = owr_out;
  assign owr_in = I_ONE_WIRE;

  // Set the LEDs
  assign O_LED_R = led_r;
  assign O_LED_G = led_g;
  assign O_LED_B = led_b;

endmodule
