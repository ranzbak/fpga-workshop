module testbench;
  reg r_clk;
  reg r_rst;
  always #2 r_clk = (r_clk === 1'b0);

  wire w_led_r;
  wire w_led_g;
  wire w_led_b;


  // Instanciate the module
  led uut (
    .i_clk(r_clk),
    .i_rst(r_rst),
    .o_led_r(w_led_r),
    .o_led_g(w_led_g),
    .o_led_b(w_led_b)
    );

  reg [4095:0] vcdfile;

  initial begin
    r_rst = 1'b1;
    // Clear reset after 20 time units
    #10 r_rst = 1'b0;
  end

  initial begin
    $timeformat(3, 2, " ns", 20);

    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
  end


  initial begin
    repeat (100) @(posedge r_clk);
    $display("SUCCESS: Simulation run for 100 cycles/ %0t.", $time);
    $finish;
  end
endmodule


