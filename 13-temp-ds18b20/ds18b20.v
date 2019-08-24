/*
 * This module assumes that the DS18B20 is powered via the Vcc pin.
 *
 * This Module provides the basic functions to drive the DS18B20 temperature sensor.
 * This sensor uses the 1-wire protocol, and works via a synchronous design.
 * Signals:
 *       i_clk        : Clock signal
 *       i_rst        : Reset signal, high active
 * [4:0] i_command    : Command to execute
 *       i_enable     : Send command to the contoller, pulse to start command
 * [7:0] o_data [3:0] : 64 bit of data out in 8-bit blocks
 *       o_ready      : Is high, as long as there is unread data in the module.
 *       o_busy       : Busy signal, high active
 *       o_irq        : Pulse when command is done, high active
 *       o_detect     : Device detected, high active
 *
 *       i_owr        : One wire input
 *       o_owr        : One wire output
 *
 * No new commands can be issued while o_ready or o_busy is high.
 *
 * Commands:
 * c_reset_detect     : Resets the DS18B20, and looks for the present signal
 * c_skip_rom         : skips the addressing of the DS18B20, and lets the FPGA
 * c_convert_t        : Start a temperature conversion
 * c_read_scratch     : Read the 9 bytes from the scratch pad, check the CRC and return 8
 * c_next_byte        : Return the next byte * can be issued while o_ready is high
 *
 */
module ds18b20 #(
  parameter BWD = 32,           // Bus width of the data register
  parameter CDR_N = 48 * 5 - 1, // Normal mode cycle divider
  parameter CDR_O = 48 * 1 - 1  // Overdrive mode cycle divider
)(
  input i_clk,
  input i_rst,
  input [5:0] i_command,
  input i_enable,
  output o_busy,
  output o_irq,
  output o_detect,

  output [15:0] o_data,


  // ONE-WIRE
  input  i_owr,
  output o_owr,
  output o_owr_p
);
  // One-wire registers
  wire [7:0] w_owrstatus;
  reg [7:0] r_owrstatus_prev;
  reg [BWD-1:0] bus_wdt = 32'b0;
  reg bus_adr = 0;
  reg bus_ren = 0;
  reg bus_wen = 0;
  reg r_irq = 1'b0; // IRQ line
  reg r_busy = 1'b0; // BUSY line
  reg [4:0] r_send_count = 0;
  reg [15:0] r_send_word  = 0;

  wire [BWD-1:0] bus_rdt;
  wire bus_irq;

  // Local registers
  reg [5:0]  r_command;
  reg [5:0]  r_command_ret;
  reg [7:0]  r_state = 0;
  reg [7:0]  r__state = 0;
  reg        r_detect = 0;

  // Scratch pad
  parameter p_scratch_len = 15; // Scratch pad is 9 bytes long
  reg [$clog2(p_scratch_len)-1:0] r_scratch_count;
  reg [p_scratch_len:0] r_scratch_buf;

  // Output temperature register
  reg [15:0] r_data = 0;

  /*
  * Instantiate the onewire interface
  *
  * system signals
  * input            clk,
  * input            rst,
  * // CPU bus interface
  * input            bus_ren,  // read  enable registers
  * input            bus_wen,  // write enable registers
  * input  [BAW-1:0] bus_adr,  // address
  * input  [BDW-1:0] bus_wdt,  // write data
  * output [BDW-1:0] bus_rdt,  // read  data
  * output           bus_irq,  // interrupt request
  * // 1-wire interface
  * output [OWN-1:0] owr_p,    // output power enable (When parasitically powering the device)
  * output [OWN-1:0] owr_e,    // output pull down
  * input  [OWN-1:0] owr_i     // input from wire
  *
  * read/write enable, put data on bus, and trigger the enable one cycle
  *
  */
  sockit_owm #(
    .CDR_N(CDR_N),
    .CDR_O(CDR_O),
    .CDR_E(1),
    .OVD_E(0)
    ) my_sockit_owm (
    .clk(i_clk),
    .rst(i_rst),
    .bus_ren(bus_ren),
    .bus_wen(bus_wen),
    .bus_adr(bus_adr),
    .bus_wdt(bus_wdt),
    .bus_rdt(bus_rdt),
    .bus_irq(bus_irq),
    .owr_p(o_owr_p),
    .owr_e(o_owr),
    .owr_i(i_owr)
  );

  // Command enumeration
  parameter
    c_idle          = 0,
    c_reset_detect  = 1,
    c_skip_rom      = 2,
    c_convert_t     = 3,
    c_read_scratch  = 4,
    c_output_temp   = 5,
    c_poll_wait     = 6,

    // Do not use in sub modules
    c__read_byte    = 10,
    c__write_word   = 11;

  // State machine enumeration
  parameter
    s_start        = 0,
    s_wait         = 1,
    s_done         = 2,
    s_reset_detect = 3,
    s_skip_rom     = 4,
    s_convert_t    = 5,
    s_read_scratch = 6,
    s_c_next_byte  = 7,
    s_write_bit    = 21,
    s_wait_bit     = 22,
    s_read_bit     = 30,
    s_read_9_bytes = 40,
    s_start_cycle  = 41,

    // Fail state
    s_error         = 99;


  // shorthand for the 8 bit status register of OWM
  assign w_owrstatus = bus_rdt[7:0];

  /*
   * ===============================
   * Reset the DS18:20 and detect the device
   * ===============================
   */
  task t_reset_detect_command;
    begin
      case (r_state)
        s_start : begin
          // Setup the registers to start a reset and detect cycle
          bus_ren <= 1'b0;   // Read enable
          bus_wen <= 1'b1;   // Write enable
          bus_adr <= 1'b0;   // Address bus implicit for clarity
          bus_wdt <= 32'h0000000A; // bit 1,4 reset and detect

          r_state <= s_wait;
        end

        s_wait : begin
          bus_ren <= 1'b1;   // Read enable
          bus_adr <= 1'b0;   // Address bus implicit for clarity

          // Wait till the end of the cycle
          if ( r_owrstatus_prev[3] == 1'b1 && w_owrstatus[3] == 1'b0 ) begin
            if ( w_owrstatus[0] == 1'b0 ) begin
              // device detected
              r_detect <= 1'b1;
            end else begin
              // no device detected
              r_detect <= 1'b0;
            end
            r_irq <= 1'b1;
            r_busy <= 1'b0;
            r_command <= c_idle;
          end
        end

      endcase
    end
  endtask

  /*
   * This task sends commands and pulls the correct pins high
   */
  task t_send_command;
    input [7:0] a_send_command;
    case (r_state)
      // Setup the sending of the command 0xCC
      s_start : begin
        // Set return vector
        r_command_ret <= r_command;
        r_command <= c__write_word;
        r__state <= s_start;
        // Send Skip rom + the command specified
        r_send_word <= { a_send_command, 8'hCC };
        r_state <= s_done;
        r_busy <= 1'b1;
      end

      // Gets called when the sending of the byte is done
      s_done : begin
        r_busy <= 1'b0;
        r_irq <= 1'b1;
        r_command <= c_idle;
      end
    endcase
  endtask

  /*
   * This task reads the 9 bits of the scratch pad.
   * The temperature is put on the o_data, as 16 bit signed value.
   */
  task t_read_temp;

    begin
      case (r_state)
        // Initialize task
        s_start : begin
          r_scratch_count <= 'b0;
          r_scratch_buf <= 'b0;
          r_state <= s_start_cycle;
        end

        // Setup, wait for the conversion to complete
        s_start_cycle : begin
          // Initiate read cycle by writing '1'
          bus_ren <= 1'b0;   // Read enable
          bus_wen <= 1'b1;   // Write enable
          bus_adr <= 1'b0;   // Address bus implicit for clarity
          bus_wdt <= 32'h00000009; // 0 and 3 to  start a cycle and write 1
          // Wait for the result
          r_state <= s_wait;

          // Indicate waiting is in progress
          r_busy <= 1'b1;
        end

        // Read the result, if 0, return
        s_wait : begin
          bus_ren <= 1'b1;   // Read enable
          bus_adr <= 1'b0;   // Address bus implicit for clarity

          if(r_owrstatus_prev[3] == 1'b1 && w_owrstatus[3] == 1'b0) begin
            r_scratch_count <= r_scratch_count + 1;

            // Save bit to the buffer
            r_scratch_buf[r_scratch_count] <= w_owrstatus[0];

            // On byte (p_scratch_len - 1), we are done
            if(r_scratch_count == p_scratch_len) begin
              r_data  <= r_scratch_buf[15:0];
              r_state <= s_done;
            end else
              r_state <= s_start_cycle;
          end
        end

        // When done
        s_done : begin
          r_busy <= 1'b0;
          r_irq <= 1'b1;
          r_command <= c_idle;
        end
      endcase
    end
  endtask

  /*
   * Read until a one is received, to indicate a conversion or copy is
   * complete.
   */
  task t_poll_wait;
    case (r_state)
      // Setup, wait for the conversion to complete
      s_start : begin
        // Initiate read cycle by writing '1'
        bus_ren <= 1'b0;   // Read enable
        bus_wen <= 1'b1;   // Write enable
        bus_adr <= 1'b0;   // Address bus implicit for clarity
        bus_wdt <= 32'h00000009; // bit 0,3  reset and detect
        // Wait for the result
        r_state <= s_wait;

        // Indicate waiting is in progress
        r_busy <= 1'b1;
      end

      // Read the result, if 0, return
      s_wait : begin
        bus_ren <= 1'b1;   // Read enable
        bus_adr <= 1'b0;   // Address bus implicit for clarity

        if(w_owrstatus[3] == 1'b0) begin
          if (w_owrstatus[0] == 1'b1) begin
            // When a 1 is found, we are done
            r_state <= s_done;
          end else begin
            // When a 0 is found do another read
            r_state <= s_start; // Conversion still in progress
          end
        end
      end

      // When done
      s_done : begin
        r_busy <= 1'b0;
        r_irq <= 1'b1;
        r_command <= c_idle;
      end
    endcase
  endtask

  task t__write_word;
    begin
      case (r__state)
        s_start : begin
          r_send_count <= 0;

          r__state <= s_write_bit;
        end

        s_write_bit : begin
          // Send a transmit bit command
          bus_ren <= 1'b0;   // Read enable
          bus_wen <= 1'b1;   // Write enable
          bus_adr <= 1'b0;   // Address bus implicit for clarity
          bus_wdt <= 32'h00000008 | {31'b0, r_send_word[r_send_count[3:0]]}; // bit 1,4 reset and detect

          // Handle end of char transmission
          if (r_send_count == 'd16) begin
            r__state <= s_start;  // restore sub state
            r_command <= r_command_ret; // return to regular state machine
          end else begin
            r__state <= s_wait_bit;     // Next bit

            // next bit
            r_send_count <= r_send_count+1;
          end
        end

        // Wait for sending of the byte to complete
        s_wait_bit : begin
          bus_ren <= 1'b1;   // Read enable
          bus_adr <= 1'b0;   // Address bus implicit for clarity

          // Wait for the end of the write cycle
          if ( r_owrstatus_prev[3] == 1'b1 && w_owrstatus[3] == 1'b0 ) begin
            r__state <= s_write_bit;
          end
        end
      endcase
    end
  endtask

  /*
   *  Main state machine
   */
  always @(posedge i_clk)
  begin
    // Zero registers by default
    bus_ren <= 1'b0;
    bus_wen <= 1'b0;
    bus_adr <= 1'b0;
    r_irq   <= 1'b0;

    // Set status reg previous
    r_owrstatus_prev <= w_owrstatus;

    /*
     * ===============================
     * Decode commands
     * ===============================
     */
    if ( i_enable == 1'b1 && r_command == c_idle) begin
      r_command <= i_command;
      r_state   <= s_start;
      r_busy    <= 1'b1;
    end

    case(r_command)
      c_reset_detect :
        t_reset_detect_command();

      c_convert_t :
        t_send_command(8'h44);

      c_read_scratch :
        t_send_command(8'hBE);

      c_poll_wait :
        t_poll_wait();

      c_output_temp :
        t_read_temp();

      c__write_word :
        t__write_word();
    endcase

    // Handle reset
    if (i_rst == 1'b1) begin
      r_detect  <= 1'b0;
      r_command <= c_idle;
      r_state   <= s_start;
      r_busy    <= 1'b0;
    end

  end

  // Register assignments
  assign o_irq = r_irq;
  assign o_busy = r_busy;
  assign o_detect = r_detect;

  // Data out
  assign o_data = r_data;

endmodule
