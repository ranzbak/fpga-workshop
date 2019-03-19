
module chip (
	output	LED_R,
	output	LED_G,
	output	LED_B
	);

	wire clk, led_r, led_g, led_b;

  SB_HFOSC #(
    .CLKHF_DIV("0b00")
    ) u_hfosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF(clk)
    );

	blink #(
    .r_bit(25),
    .g_bit(24),
    .b_bit(23)
    ) my_blink (
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
