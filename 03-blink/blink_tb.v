`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100 ns / 10 ns

module blink_tb;
  reg clk;
  reg rst;
  always #2 clk = (clk === 1'b0);

  wire led_r;
  wire led_g;
  wire led_b;


  // Instanciate the module
  blink uut (
    .clk(clk),
    .rst(rst),
    .led_r(led_r),
    .led_g(led_g),
    .led_b(led_b)
    );

  reg [4095:0] vcdfile;

  initial begin
    rst = 1'b1;
    // Clear reset after 20 time units
    #10 rst = 1'b0;
  end

  initial begin
    $timeformat(3, 2, " ns", 20);
  end

  initial begin
    repeat (1000) @(posedge clk);
    if( uut.count == 0 ) begin
      $display("%0t: %d", $time, uut.count);
      $stop;
    end
  end


  initial begin
    $dumpfile(`DUMPSTR(`VCD_OUTPUT));
    $dumpvars(0, blink_tb);

    repeat (200000) @(posedge clk);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $time);
    $finish;
  end
endmodule

