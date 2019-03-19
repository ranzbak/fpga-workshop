module testbench;
  reg clk;
  reg rst;
  always #2 clk = (clk === 1'b0);

  wire led_r;
  wire led_g;
  wire led_b;


  // Instanciate the module
	blink #(
    .r_bit(9),
    .g_bit(10),
    .b_bit(11),
    .d_bit(4)
    ) uut (
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

    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
  end

  initial begin
    repeat (1000) @(posedge clk);
    if( uut.count == 0 ) begin
      $display("%0t: %d", $time, uut.count);
      $stop;
    end
  end


  initial begin
    repeat (200000) @(posedge clk);
    $display("SUCCESS: Simulation run for 200000 cycles/ %0t.", $time);
    $finish;
  end
endmodule

