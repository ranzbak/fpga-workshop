// A simple circuit that can be used to detect brownouts and other hardware issues

module cycle #(
  parameter START_POS=0
) (
  input i_clk,
  input i_rst,
  input [19:0] i_speed,
  output o_led
);
  reg [7:0] r_rst_counter = 0;
  reg [7:0] r_count_out = 0;
  reg [16:0] r_count_raw = {START_POS, 6'h00};
  reg [19:0] r_count_speed = 0;
  reg [7:0] r_count_duty = 0;
  reg [7:0] r_count_duty_next = 0;
  reg r_rstn = 0;

  reg r_led;

  wire [10:0] w_count_cur;


  /*
   * Wait for system system to stabilize 
   */
  always @(posedge i_clk) begin
    r_rst_counter <= r_rst_counter + 1;
    r_rstn <= r_rstn | &r_rst_counter;
  end

  /*
   * Speed devider
   */
  always @(posedge i_clk) begin
    r_count_speed <= r_count_speed + 1;
    if (r_count_speed == i_speed) // 124 +- 2 s
      r_count_speed <= 0;

    if(i_rst == 1'b1 || r_rstn == 1'b0) begin
      r_count_speed <= 'b0;
    end
  end

  // count_cur up and down
  always @(posedge i_clk) begin
    // Update counters every X cycles
    if (r_count_speed == 0) begin

      // PWM the led_g
      r_count_duty <= r_count_duty + 1;
      if (r_count_duty == 8'hff) r_count_duty <= 'b0;

      r_led <= 1'b1;
      if(r_count_out > r_count_duty)
        r_led <= 1'b0;

      /**
       * Create the shape that cycles the colors
       *   __
       *  /  \__
       *  0 1024 1535
       * *************************
       *  This over three channels with 512 phase difference makes a nice. color cycle
       *         __
       *  RED   /  \__
       *           __
       *  GREEN __/  \
       *        _    _
       *  BLUE   \__/  
       */

      if (w_count_cur < 256) begin
        r_count_out <= w_count_cur;
      end else if (w_count_cur <= 768) begin
        r_count_out <= 8'hff;
      end else if (w_count_cur <= 1024) begin
        r_count_out <= 1024 - w_count_cur;
      end else begin
        r_count_out <= 8'b0;
      end

      // Move duty cycle counter
      r_count_raw <= r_count_raw + 1;
      if (w_count_cur == 1536) begin
        r_count_raw <= 'b0;
      end

    end

    // Reset holds counters 
    if(i_rst == 1'b1 || r_rstn == 1'b0) begin
      r_count_duty  <= 0;
      r_count_raw   <= {START_POS, 6'b0};
    end 

  end

  assign o_led = r_led;
  assign w_count_cur = r_count_raw[16:6];

endmodule
