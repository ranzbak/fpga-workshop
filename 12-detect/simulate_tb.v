`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100ns / 10ns

module simulate_tb;
  reg clk;
  always #5 clk = (clk === 1'b0);

  wire led_r, led_g, led_b, i_one_wire, o_one_wire;
  reg  r_rst;
  reg i_one_wire_reg;


  // Instantiate the test bench
  sim_tb uut (
    .i_clk(clk),
    .i_rst(r_rst),
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
    r_rst = 1'b1;
    repeat (10) @(posedge clk);
    r_rst = 1'b0;
  end

  // One wire slave mock up
  initial begin
    i_one_wire_reg = 1'b1;
    repeat (500) @(posedge clk);
    i_one_wire_reg = 1'b0;
    repeat (200) @(posedge clk);
    i_one_wire_reg = 1'b1;
  end

  // One wire slave mock up
  initial begin
    i_one_wire_reg = 1'b1;
    repeat (21500) @(posedge clk);
    i_one_wire_reg = 1'b0;
    repeat (200) @(posedge clk);
    i_one_wire_reg = 1'b1;
  end
  assign i_one_wire = i_one_wire_reg;

  // Check if the ds18b20 is detected correctly
  initial begin
    // Check the green LED at 11000 steps (cycle one)
    repeat (11000) @(posedge clk);
    $display("DS18B20 Should not be detected at run 1");
    if (led_g == 1'b1) begin
      $display("DS18B20 not detected at run 1: FAIL");
      $finish;
    end else begin
      $display("DS18B20 detected at run 1: OK");
    end

    // Check the green LED at 32000 steps (run two)
    repeat (21000) @(posedge clk);
    $display("DS18B20 Should not be detected at run 2");
    if (led_g == 1'b1) begin
      $display("DS18B20 not detected at run 2: FAIL");
      $finish;
    end else begin
      $display("DS18B20 detected at run 2: OK");
    end

    // Check the red LED at 53000 steps (run two)
    repeat (21000) @(posedge clk);
    $display("DS18B20 Should not be detected at run 3");
    if (led_r == 1'b1) begin
      $display("DS18B20 detected at run 3: FAIL");
      $finish;
    end else begin
      $display("DS18B20 not detected at run 3: OK");
    end
  end

  // End the simulation at 200_000 cycles 
  initial begin
    $dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, simulate_tb);

    repeat (100000) @(posedge clk);
    $display("SUCCESS: Simulation run for 100000 cycles.");
    $finish;
  end
endmodule

