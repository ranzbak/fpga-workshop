
module chip (
  output  LED_R,
  output  LED_G,
  output  LED_B
  );

  wire w_clk;

  SB_HFOSC u_hfosc (
          .CLKHFPU(1'b1),
          .CLKHFEN(1'b1),
          .CLKHF(w_clk)
      );

  blink my_blink (
    .i_clk(w_clk),
    .i_rst(1'b0),
    .o_led_r(LED_R),
    .o_led_g(LED_G),
    .o_led_b(LED_B)
  );

endmodule
