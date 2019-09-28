
module chip (
  output  O_LED_R,
  output  O_LED_G,
  output  O_LED_B
);

wire w_clk, w_led_r, w_led_g, w_led_b;

  SB_HFOSC #(
    .CLKHF_DIV("0b00")
  ) u_hfosc (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(w_clk)
  );

  blink #(
    .p_bit_r(25),
    .p_bit_g(24),
    .p_bit_b(23)
  ) my_blink (
    .i_clk(w_clk),
    .i_rst(0),
    .o_led_r(O_LED_R),
    .o_led_g(O_LED_G),
    .o_led_b(O_LED_B)
  );
endmodule
