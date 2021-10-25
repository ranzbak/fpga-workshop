module chip (
  input EXT_CLK,

  output  LED_R,
  output  LED_G,
  output  LED_B
);

wire w_clk, w_led_r, w_led_g, w_led_b;

  // Clock IP
  // Takes the 12MHz oscillator, and converts it to 24MHz
  pll my_pll (
      .i_clk(EXT_CLK),
      .o_clk(w_clk)
  );

  blink #(
    .p_bit_r(23),
    .p_bit_g(22),
    .p_bit_b(21)
  ) my_blink (
    .i_clk(w_clk),
    .i_rst(0),
    .o_led_r(LED_R),
    .o_led_g(LED_G),
    .o_led_b(LED_B)
  );
endmodule
