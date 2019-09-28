
module chip (
  input   I_USER_1,
  output  O_LED_R,
  output  O_LED_G,
  output  O_LED_B
  );

  wire w_clk;

  // Clock devided to 24 MHz
  SB_HFOSC u_hfosc (
    .CLKHFPU(1'b1),
    .CLKHFEN(1'b1),
    .CLKHF(w_clk)
  );

  morse my_morse (
    .i_clk(w_clk),
    .i_rst(I_USER_1),
    .o_led_r(O_LED_R),
    .o_led_g(O_LED_G),
    .o_led_b(O_LED_B)
  );

  endmodule
