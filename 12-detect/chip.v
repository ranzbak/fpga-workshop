module chip (
  input   I_RESET_WIRE,
	output	O_LED_R,
	output	O_LED_G,
	output	O_LED_B,
  inout   IO_ONE_WIRE
	);

	wire clk, led_r, led_g, led_b, one_wire, owr_in, owr_out;

  reg reset = 1'b1;
  reg [11:0] reset_count = 4095;

	SB_HFOSC u_hfosc (
        	.CLKHFPU(1'b1),
        	.CLKHFEN(1'b1),
        	.CLKHF(clk)
    	);

  // Keep the timer high for the first 4096 cycles
  // To let the system stabilize 
	always @(posedge clk) 
  begin
    if(reset_count > 0) begin
      reset <= 1'b1;
      reset_count <= reset_count - 1;
    end else begin
      reset <= 1'b0;
    end

    if(I_RESET_WIRE == 1'b1) begin
      reset_count <= 4095;
    end
  end

  // Temperature sensor
	temp my_temp (
    .i_clk(clk),
    .i_rst(reset),
    .o_led_r(led_r),
    .o_led_g(led_g),
    .o_led_b(led_b),
    .i_owr(owr_in),
    .i_owr(owr_out)
  );

  // Configure and connect the IO_ONE_WIRE pin
  SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 0)
  ) io_buf_one_wire (
    .PACKAGE_PIN(IO_ONE_WIRE),
    .OUTPUT_ENABLE(owr_out),
    .D_OUT_0(!owr_out),
    .D_IN_0(owr_in)
  );

  // Connect up the registers to the LED wires
	assign O_LED_R = led_r;
	assign O_LED_G = led_g;
	assign O_LED_B = led_b;


endmodule
