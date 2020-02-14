`default_nettype none

// Example 01 Hello world
module chip (
  output  O_LED_R
  );

  // A wire
  wire  w_led_r;

  // Continuous assignment to a wire
  assign w_led_r = 1'b0;

  // Connecting the wire to the output
  assign O_LED_R = w_led_r;
endmodule
