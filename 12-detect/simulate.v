// A simple circuit that can be used to detect brownouts and other hardware issues

module sim_top (
  input i_clk,
  input i_rst,
  output O_LED_R,
  output O_LED_G,
  output O_LED_B,
  input  I_ONE_WIRE,
  output O_ONE_WIRE
);

  // temperature sensor
  temp #(
    .CDR_N(4),
    .CRD_O(0)
  ) my_temp (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_led_r(O_LED_R),
    .o_led_g(O_LED_G),
    .o_led_b(O_LED_B),
    .i_owr(I_ONE_WIRE),
    .o_owr(O_ONE_WIRE)
  );

endmodule
