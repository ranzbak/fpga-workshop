module chip (
  output  O_LED_R,
  output  O_LED_G,
  output  O_LED_B
  );

  wire w_clk, w_led_r, w_led_g, w_led_b;

  // Internal oscillator
  SB_HFOSC u_hfosc (
          .CLKHFPU(1'b1),
          .CLKHFEN(1'b1),
          .CLKHF(w_clk)
   );

  led my_led (
    .i_clk(w_clk),
    .i_rst(0),
    .o_led_r(w_led_r),
    .o_led_g(w_led_g),
    .o_led_b(w_led_b)
  );

  assign O_LED_R = w_led_r;
  assign O_LED_G = w_led_g;
  assign O_LED_B = w_led_b;

endmodule
