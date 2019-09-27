
module chip (
  output  O_LED_R,
  output  O_LED_G,
  output  O_LED_B,
  input   I_INPUT_1
  );

  wire w_clk;
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

  // RED
  cycle red_cycle (
    .i_clk(w_clk),
    .i_rst(r_rst),
    .i_speed(p_speed_r),
    .o_led(O_LED_R)
  );

  // GREEN
  cycle green_cycle (
    .i_clk(w_clk),
    .i_rst(r_rst),
    .i_speed(p_speed_g),
    .o_led(O_LED_G)
  );

  // BLUE
  cycle blue_cycle (
    .i_clk(w_clk),
    .i_rst(r_rst),
    .i_speed(p_speed_b),
    .o_led(O_LED_B)
  );

  assign r_rst = I_INPUT_1;

endmodule
