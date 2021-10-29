// Set the timescale Timescale/Time Precision
`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100ns / 10ns

module simulate_tb;
  reg clk;
  always #5 clk = (clk === 1'b0);

  wire led_r, led_g, led_b, i_one_wire, o_one_wire;
  reg  rst;
  reg i_one_wire_reg;


  // Instantiate the test bench
  sim_tb uut (
    .clk(clk),
    .rst(rst),
    .O_LED_R(led_r),
    .O_LED_G(led_g),
    .O_LED_B(led_b),
    .I_ONE_WIRE(i_one_wire),
    .O_ONE_WIRE(o_one_wire)
  );

  initial begin
    $timeformat(3, 2, " ns", 20);
  end

  // Generate the reset
  initial begin
    rst = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
  end

  // One wire slave mock up
  initial begin
    i_one_wire_reg = 1'b1;
    repeat (500) @(posedge clk);
    i_one_wire_reg = 1'b0;
    repeat (200) @(posedge clk);
    i_one_wire_reg = 1'b1;
    repeat (1929) @(posedge clk);
    i_one_wire_reg = 1'b0;
    repeat (200) @(posedge clk);
    i_one_wire_reg = 1'b1;
  end
  assign i_one_wire = i_one_wire_reg;

  // Conversion done
  initial begin
    i_one_wire_reg = 1'b1;
    repeat (43945) @(posedge clk);
    i_one_wire_reg = 1'b0;
    repeat (40) @(posedge clk);
    i_one_wire_reg = 1'b1;
  end
  assign i_one_wire = i_one_wire_reg;

  // End the simulation in time
  initial begin
    $dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, simulate_tb);

    repeat (200000) @(posedge clk);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $time);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $realtime);
    $finish;
  end
endmodule

