
module chip (
  input EXT_CLK,

	output	LED_R,
	output	LED_G,
	output	LED_B
	);

	wire w_clk;
  wire w_led_r, w_led_g, w_led_b;
  reg r_rst = 1'b0;

  // Cycle speeds of the RGB colors (All primes)
  parameter
    p_speed_r = 20'hff,
    p_speed_g = 20'hff,
    p_speed_b = 20'hff;

  // Clock to 24 MHz
  pll mypll (
    .i_clk(EXT_CLK),
    .o_clk(w_clk)
  );

  // RGB IP
  SB_RGBA_DRV #(
    .CURRENT_MODE("0b1"),
    .RGB0_CURRENT("0b111111"),
    .RGB1_CURRENT("0b111111"),
    .RGB2_CURRENT("0b111111")
  ) u_rgb_drv (
    .RGB0(LED_R),
    .RGB1(LED_G),
    .RGB2(LED_B),
    .RGBLEDEN(1'b1),
    .RGB0PWM(w_led_r),
    .RGB1PWM(w_led_g),
    .RGB2PWM(w_led_b),
    .CURREN(1'b1)
  );

  // RED
	cycle #(
    .START_POS(0)
  ) red_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_r),
    .o_led(w_led_r)
	);

  // GREEN
	cycle #(
    .START_POS(512)
  ) green_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_g),
    .o_led(w_led_g)
	);

  // BLUE
	cycle #(
    .START_POS(1024)
  ) blue_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_b),
    .o_led(w_led_b)
	);

endmodule
