
module chip (
	output	LED_R,
	output	LED_G,
	output	LED_B,
  input   INPUT_1
	);

	wire clk, led_r, led_g, led_b, reset;

	SB_HFOSC u_hfosc (
        	.CLKHFPU(1'b1),
        	.CLKHFEN(1'b1),
        	.CLKHF(clk)
    	);

	morse my_morse (
		.clk(clk),
		.rst(reset),
    		.led_r(led_r),
    		.led_g(led_g),
    		.led_b(led_b)
	);

	assign LED_R = led_r;
	assign LED_G = led_g;
	assign LED_B = led_b;

  assign reset = INPUT_1;

endmodule
