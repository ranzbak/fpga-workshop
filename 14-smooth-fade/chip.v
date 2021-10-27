
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
    p_speed_r = 1301,
    p_speed_g = 1607,
    p_speed_b = 1999;

  // Clock to 24 MHz
  pll mypll (
    .i_clk(EXT_CLK),
    .o_clk(w_clk)
  );

  // RGB IP
  SB_RGBA_DRV #(
    .CURRENT_MODE("0b1"),
    .RGB0_CURRENT("0b000111"),
    .RGB1_CURRENT("0b000011"),
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
	cycle red_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_r[10:0]),
    .o_led(w_led_r)
	);

  // GREEN
	cycle green_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_g[10:0]),
    .o_led(w_led_g)
	);

  // BLUE
	cycle blue_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_b[10:0]),
    .o_led(w_led_b)
	);


endmodule
