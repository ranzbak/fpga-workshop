module testbench;
  reg r_clk;
  always #5 r_clk = (r_clk === 1'b0);

  wire w_ok;

  simulate uut (
    .i_clk(r_clk),
    .i_speed(11'd2),
    .o_led(w_ok)
  );

  reg [4095:0] vcdfile;

  initial begin
    $timeformat(3, 2, " ns", 20);

    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
  end

  always @(posedge r_clk) begin
    if( uut.simulate_cycle.r_count_cur > 1023 ) begin
      $display("%0t: %d", $time, uut.simulate_cycle.r_count_cur);
      $stop;
    end
  end


  initial begin
    repeat (400000) @(posedge r_clk);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $time);
    $finish;
  end
endmodule

