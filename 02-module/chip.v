/*
 * Top level module
 */ 
module chip (
	output	O_LED_R
	);

  // Module instantiation
	led my_led (
    // Connect the module output
    .o_led_r(O_LED_R)
	);
endmodule
