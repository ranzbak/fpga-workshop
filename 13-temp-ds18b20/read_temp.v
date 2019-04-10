module read_temp #(
    parameter BWD = 32,           // Bus width of the data register
    parameter CDR_N = 48 * 7 - 1, // Normal mode cycle divider
    parameter CDR_O = 48 * 1 - 1  // Overdrive mode cycle divider
  ) (
    input  i_clk,     // Basic IO
    input  i_rst,
    output o_led_r,   // RGB LED's
    output o_led_g,
    output o_led_b,
    input  i_owr,  // One-wire in and out
    output o_owr,
    output o_owr_p
  );

  // State machine registers
  reg [7:0] r_state = 'b0;

  // LED registeres
  reg r_led_r;
  reg r_led_g;
  reg r_led_b;

  // DS18B20
  reg [5:0]   r_command = 'b0;
  reg         r_enable  = 'b0;

  wire        w_busy;
  wire        w_irq;
  wire        w_detect;
  wire [15:0] w_data;

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
    .o_owr(o_owr),
    .o_owr_p(o_owr_p)
  );

  /*
   * The temperatures the LEDS change on are
   * 25 'C = 'h0191
   * 20 'C = 'h0151
   * Temperature indication
   * T<20'C      Blue
   * 20'C<T<25'C Green
   * T>25'C      Red
   */
  parameter
    p_temp_high    = 'h0191,
    p_temp_low     = 'h0151;

  // Command enumeration
  parameter
    c_idle         = 0,
    c_reset_detect = 1,
    c_skip_rom     = 2,
    c_convert_t    = 3,
    c_read_scratch = 4,
    c_output_temp  = 5,
    c_poll_wait    = 6;

  // State enumeration
  parameter
    s_start             = 0,
    // First cycle to trigger the conversion
    s_reset_detect      = 1,
    s_wait_detect       = 2,
    s_skip_rom          = 3,
    s_wait_skip_rom     = 4,
    s_convert           = 5,
    s_poll_convert      = 6,
    s_poll_wait_convert = 7,
    s_wait_convert      = 8,
    // Second cycle to read the result
    s_2_reset_detect    = 10,
    s_2_wait_detect     = 11,
    s_2_skip_rom        = 12,
    s_2_wait_skip_rom   = 13,
    s_2_read_scratch    = 14,
    s_2_wait_scratch    = 15,
    s_2_get_temp        = 16,
    s_2_wait_temp       = 17,
    s_2_proc_temp       = 18,
    // Generic states
    s_error           = 99;

  // Task send command
  task send_command;
    input [5:0]a_command;
    input [7:0]a_next_state;
    begin
      // Send command
      r_command <= a_command;
      r_enable <= 1'b1;
      // Next stage
      r_state <= a_next_state;
    end
  endtask

  // Wait for the reset/detect to finish
  task wait_detect_command;
    input [7:0] a_next_state;
    input [7:0] a_no_detect_state;

    // Check the status register when the irq is passed
    begin
      if (w_irq == 1'b1) begin
        if (w_detect == 1'b1)
          r_state <= a_next_state;
        else
          r_state <= a_no_detect_state;
      end
    end
  endtask

  // Task wait for command to complete
  task wait_command;
    input [7:0] a_next_state;

    begin
      if (w_irq == 1'b1) begin
        r_state <= a_next_state;
      end
    end
  endtask

  // Process the temperature and output results using the RGB LED
  task proc_temp;
    input [7:0] a_next_state;
    input [15:0] a_data;

    begin
      // By default all LEDS off
      r_led_r <= 1'b1;
      r_led_g <= 1'b1;
      r_led_b <= 1'b1;

      // Enable the correct LED
      if(a_data > p_temp_high)
        r_led_r <= 1'b0;
      else if (a_data < p_temp_low)
        r_led_b <= 1'b0;
      else
        r_led_g <= 1'b0;

      // Measure next value
      r_state <= a_next_state;
    end
  endtask

  // Main state machine
  always @(posedge i_clk)
  begin
    // Signals to their default state
    r_enable <= 1'b0;
    r_command <= c_idle;

    // Handle reset
    if (i_rst == 1'b1) begin
      // NO LEDS during reset
      r_led_r <= 1'b1; // LEDS
      r_led_g <= 1'b1;
      r_led_b <= 1'b1;
      // Start over
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
      s_reset_detect :
        // Send command
        send_command(c_reset_detect, s_wait_detect);

      // Wait for detection
      s_wait_detect :
        wait_detect_command(s_convert, s_error);

      // Send Convert temperature command 44h
      s_convert :
        send_command(c_convert_t, s_wait_convert);

      // Wait for the conversion to finish sending
      s_wait_convert :
        wait_command(s_poll_convert);

      // Poll for conversion to have finished
      s_poll_convert :
        send_command(c_poll_wait, s_poll_wait_convert);

      // Wait for the conversion to finish sending
      s_poll_wait_convert :
        wait_command(s_2_reset_detect);

      // Reset the DS18B20 and detect for round 2
      s_2_reset_detect :
        send_command(c_reset_detect, s_2_wait_detect);

      // Wait for the detection
      s_2_wait_detect :
        wait_detect_command(s_2_read_scratch, s_2_read_scratch);

      // Send the read scratch command
      s_2_read_scratch :
        send_command(c_read_scratch, s_2_wait_scratch);

      // Wait for the read scratch to be finished
      s_2_wait_scratch :
        wait_command(s_2_get_temp);

      // Retrieve the 9 bytes to the FPGA
      s_2_get_temp :
        // nothing yet
        send_command(c_output_temp, s_2_wait_temp);

      // Wait for all bytes to arrive
      s_2_wait_temp :
        wait_command(s_2_proc_temp);

      // Process the temperature, and show leds
      s_2_proc_temp :
        proc_temp(s_start, w_data);

      // Error
      s_error : begin
        // Red LED until reset for now
        // TODO: Change this
        r_led_r <= 1'b0;
        r_led_g <= 1'b0;
        r_led_b <= 1'b0;
      end

      // Handles default
      default : begin
        // Just go to error when non-existing states are set
        r_state <= s_error;
      end
    endcase
  end

  // assign outputs
  assign o_led_r = r_led_r; // LEDS
  assign o_led_g = r_led_g;
  assign o_led_b = r_led_b;

endmodule
