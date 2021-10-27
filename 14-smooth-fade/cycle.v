// A simple circuit that can be used to detect brownouts and other hardware issues

module cycle (
  input i_clk,
  input i_rst,
  input [10:0] i_speed,
  output o_led
);
  reg [7:0] r_rst_counter = 0;
  reg [7:0] r_count_cur = 0;
  reg [10:0] r_count_speed = 0;
  reg [7:0] r_count_duty = 0;
  reg [7:0] r_count_duty_next = 0;
  reg r_duty_dir = 1; // 0 down, 1 up
  reg r_rstn = 0;

  reg r_led;

  /*
   * Wait for system system to stabilize 
   */
  always @(posedge i_clk) begin
    r_rst_counter <= r_rst_counter + 1;
    r_rstn <= r_rstn | &r_rst_counter;
  end

  // count_cur up and down
  always @(posedge i_clk) begin

    // Speed devider
    r_count_speed <= r_count_speed + 1;
    if (r_count_speed == i_speed) // 124 +- 2 s
      r_count_speed <= 0;

    // Update counters every X cycles
    if (r_count_speed == 0) begin

      // Duty cycle counter
      r_count_cur <= r_count_cur + 1;
      if (r_count_cur == 8'hff) 
        r_count_cur <= 0;

      // PWM the led_g
      r_led <= 1'b1;
      if((r_count_cur) > r_count_duty)
        r_led <= 1'b0;

      // Move duty cycle counter
      if (r_count_cur == 0) begin
        if (r_duty_dir == 1'b1) begin
          r_count_duty_next = r_count_duty + 1;
        end else begin
          r_count_duty_next = r_count_duty - 1;
        end

        // reverse counter duty cycle
        if (r_count_duty_next == 0 || r_count_duty_next == 255)
          r_duty_dir <= ~r_duty_dir;
      end
    end

    // Assign the variable to the register
    r_count_duty <= r_count_duty_next;


    // Reset holds counters 
    if(i_rst == 1'b1 || r_rstn == 1'b0) begin
      r_count_duty  <= 0;
      r_count_speed <= 0;
      r_count_cur   <= 0;
      r_duty_dir    <= 1;
    end 

  end

  assign o_led = r_led;

endmodule
