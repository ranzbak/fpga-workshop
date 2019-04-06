// A simple circuit that can be used to detect brownouts and other hardware issues

module cycle (
  input clk,
  input rst,
  input [10:0] speed,
  output led
);
  reg [7:0] reset_counter = 0;
  reg [7:0] count_cur = 0;
  reg [10:0] count_speed = 0;
  reg [7:0] count_duty = 0;
  reg [7:0] count_duty_next = 0;
  reg duty_dir = 1; // 0 down, 1 up
  reg resetn = 0;

  reg led_reg;

  /*
   * Wait for system system to stabilize 
   */
  always @(posedge clk) begin
    reset_counter <= reset_counter + 1;
    resetn <= resetn | &reset_counter;
  end

  // count_cur up and down
  always @(posedge clk) begin

    // Speed devider
    count_speed <= count_speed + 1;
    if (count_speed == speed) // 124 +- 2 s
      count_speed <= 0;

    // Update counters every X cycles
    if (count_speed == 0) begin

      // Duty cycle counter
      count_cur <= count_cur + 1;
      if (count_cur == 255) 
        count_cur <= 0;

      // PWM the led_g
      led_reg <= 1'b1;
      if(count_cur > count_duty)
        led_reg <= 1'b0;

      // Move duty cycle counter
      if (count_cur == 0) begin
        if (duty_dir == 1'b1) begin
          count_duty_next = count_duty + 1;
        end else begin
          count_duty_next = count_duty - 1;
        end

        // reverse counter duty cycle
        if (count_duty_next == 0 || count_duty_next == 255)
          duty_dir <= ~duty_dir;
      end
    end

    // Assign the variable to the register
    count_duty <= count_duty_next;

    // Reset holds counters 
    if(rst == 1'b0 || resetn == 1'b0) begin
      count_duty  <= 0;
      count_speed <= 0;
      count_cur   <= 0;
      duty_dir    <= 1;
    end 
  end

  assign led = led_reg;

endmodule
