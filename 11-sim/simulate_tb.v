module testbench;
  reg clk;
  always #5 clk = (clk === 1'b0);

  wire ok;

  simulate uut (
    .clk(clk),
    .led(ok),
    .speed(11'd2)
  );

  reg [4095:0] vcdfile;

  initial begin
    $timeformat(3, 2, " ns", 20);

    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
  end

  always @(posedge clk) begin
    if( uut.simulate_cycle.count_cur > 1023 ) begin
      $display("%0t: %d", $time, uut.simulate_cycle.count_cur);
      $stop;
    end
  end


  initial begin
    repeat (400000) @(posedge clk);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $time);
    $finish;
  end
endmodule

