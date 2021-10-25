
module chip (
  input EXT_CLK,

  output  LED_R,
  output  LED_G,
  output  LED_B
  );

  wire w_clk;

  // Clock IP
  // Takes the 12MHz oscillator, and converts it to 24MHz
  pll my_pll (
      .i_clk(EXT_CLK),
      .o_clk(w_clk)
  );

  morse my_morse (
    .i_clk(w_clk),
    .i_rst(1'b0),
    .o_led_r(LED_R),
    .o_led_g(LED_G),
    .o_led_b(LED_B)
  );

endmodule
