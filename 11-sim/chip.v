
module chip (
  input EXT_CLK,

  output  LED_R,
  output  LED_G,
  output  LED_B,
  input   I_INPUT_1
  );

  wire clk;
  reg r_rst;

  // Cycle speeds of the RGB colors (All primes)
  parameter
    p_speed_r = 1301,
    p_speed_g = 1607,
    p_speed_b = 1999;

  // Clock IP
  // Takes the 12MHz oscillator, and converts it to 24MHz
  pll my_pll (
      .i_clk(EXT_CLK),
      .o_clk(clk)
  );

  // RED
  cycle red_cycle (
    .i_clk(clk),
    .i_rst(r_rst),
    .i_speed(p_speed_r[10:0]),
    .o_led(LED_R)
  );

  // GREEN
  cycle green_cycle (
    .i_clk(clk),
    .i_rst(r_rst),
    .i_speed(p_speed_g[10:0]),
    .o_led(LED_G)
  );

  // BLUE
  cycle blue_cycle (
    .i_clk(clk),
    .i_rst(r_rst),
    .i_speed(p_speed_b[10:0]),
    .o_led(LED_B)
  );

  always @(posedge clk) begin
    r_rst <= I_INPUT_1;
  end

endmodule
