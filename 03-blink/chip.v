module chip (
  input   EXT_CLK,
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

  // Module that blinks the light
  blink my_blink (
    .clk(clk),
    .rst(1'b0),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
  );

  // Connect the signals to the output pins
  assign LED_R = led_r;
  assign LED_G = led_g;
  assign LED_B = led_b;

endmodule
