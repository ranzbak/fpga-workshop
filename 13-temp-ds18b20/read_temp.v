module read_temp #(
    parameter BWD = 32,           // Bus width of the data register
    parameter CDR_N = 48 * 6 - 1, // Normal mode cycle divider
    parameter CDR_O = 48 * 1 - 1  // Overdrive mode cycle divider
  ) (
    input  i_clk,     // Basic IO
    input  i_rst,
    output o_led_r,   // RGB LED's
    output o_led_g,
    output o_led_b,
    input  i_owr,  // One-wire in and out
    output o_owr
  );

  // State machine registers
  reg [7:0] r_state = 'b0;

  // LED registeres
  reg r_led_r;
  reg r_led_g;
  reg r_led_b;

  // DS18B20 
  reg [5:0]  r_command = 'b0;
  reg        r_enable  = 'b0;

  wire       w_busy;
  wire       w_irq;
  wire       w_detect;
  wire [7:0] w_data;

  // DS18B20 controller module
  ds18b20 #(
    .BWD(BWD),           // Bus width of the data register
    .CDR_N(CDR_N), // Normal mode cycle divider
    .CDR_O(CDR_O)  // Overdrive mode cycle divider
  ) my_ds18b20 (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_command(r_command),
    .i_enable(r_enable),
    .o_busy(w_busy),
    .o_irq(w_irq),
    .o_detect(w_detect),

    .o_data(w_data),
    // ONE-WIRE
    .i_owr(i_owr),
    .o_owr(o_owr)
  );

  // Command enumeration
  parameter 
    c_idle          = 0,
    c_reset_detect  = 1,
    c_skip_rom      = 2,
    c_convert_t     = 3,
    c_read_scratch  = 4,
    c_next_byte     = 5;

  // State enumeration
  parameter 
    s_start         = 0,
    s_reset_detect  = 1,
    s_wait_detect   = 2;


  // Main state machine
  always @(posedge i_clk)
  begin
    // Signals to their default state
    r_enable <= 1'b0;
    r_command <= c_idle;
    r_led_r <= 1'b1; // LEDS
    r_led_g <= 1'b1;
    r_led_b <= 1'b1;

    // Handle reset
    if (i_rst == 1'b1) begin
      r_state <= s_start;
    end 

    // State machine
    case (r_state)
      // Start read
      s_start : begin
        // Wait for the reset to clear
        if (i_rst == 1'b0) begin
          r_state <= s_reset_detect;
        end
      end

      // Send reset/detect signal
      s_reset_detect : begin
        // Send command
        r_command <= c_reset_detect;
        r_enable <= 1'b1;
        // Next stage
        r_state <= s_wait_detect;
      end

      // Wait for detection
      s_wait_detect : begin
        // Check the status register when the irq is passed
        if (w_busy == 1'b0) begin
          if (w_detect == 1'b1) begin
            r_led_g <= 1'b0;
          end else begin
            r_led_r <= 1'b0; 
          end
        end
      end
    endcase
  end

  // assign outputs
  assign o_led_r = r_led_r; // LEDS
  assign o_led_g = r_led_g;
  assign o_led_b = r_led_b;


endmodule
