`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100 ns / 10 ns

module simulate_tb;
  reg r_clk;
  always #5 r_clk = (r_clk === 1'b0);

  wire [2:0] w_ok;

  simulate #(
    .START_POS(0)
  ) uut (
    .i_clk(r_clk),
    .i_speed(16'd200),
    .o_led(w_ok[0])
  );

  simulate #(
    .START_POS(512)
  ) uut2 (
    .i_clk(r_clk),
    .i_speed(16'd200),
    .o_led(w_ok[1])
  );

  simulate #(
    .START_POS(1024)
  ) uut3 (
    .i_clk(r_clk),
    .i_speed(16'd200),
    .o_led(w_ok[2])
  );



  initial begin
    $timeformat(3, 2, " ns", 20);
  end

  initial begin
    $dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, simulate_tb);

    repeat (400000) @(posedge r_clk);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $time);
    $finish;
  end
endmodule

