module chip (
  input EXT_CLK,
  output  LED_R,
  output  LED_G,
  output  LED_B
  );

  wire clk, led_r, led_g, led_b;

  // Clock IP
  // Takes the 12MHz oscillator, and converts it to 24MHz
  pll my_pll (
      .i_clk(EXT_CLK),
      .o_clk(clk)
  );

  blink my_blink (
    .clk(clk),
    .rst(0),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
  );

  assign LED_R = led_r;
  assign LED_G = led_g;
  assign LED_B = led_b;

endmodule
