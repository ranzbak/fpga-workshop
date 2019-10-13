
module chip (
	output	O_LED_R,
	output	O_LED_G,
	output	O_LED_B,
  input   I_INPUT_1
	);

	wire w_clk;
  wire w_led_r, w_led_g, w_led_b;
  reg r_rst;

  // Cycle speeds of the RGB colors (All primes)
  parameter
    p_speed_r = 1301,
    p_speed_g = 1607,
    p_speed_b = 1999;

  // Clock devided to 24 MHz
  SB_HFOSC #(
    .CLKHF_DIV("0b01") // Half the clock speed
    ) u_hfosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF(w_clk)
    );

  // RGB IP
  SB_RGBA_DRV #(
    .CURRENT_MODE("0b1"),
    .RGB0_CURRENT("0b100000"),
    .RGB1_CURRENT("0b100000"),
    .RGB2_CURRENT("0b100000")
  ) u_rgb_drv (
    .RGB0(O_LED_R),
    .RGB1(O_LED_G),
    .RGB2(O_LED_B),
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
    .i_speed(p_speed_r),
    .o_led(w_led_r)
	);

  // GREEN
	cycle green_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_g),
    .o_led(w_led_g)
	);

  // BLUE
	cycle blue_cycle (
		.i_clk(w_clk),
		.i_rst(r_rst),
    .i_speed(p_speed_b),
    .o_led(w_led_b)
	);

  assign r_rst = I_INPUT_1;

endmodule
