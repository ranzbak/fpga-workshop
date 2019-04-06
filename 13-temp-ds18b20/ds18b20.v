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
  parameter CDR_N = 48 * 6 - 1, // Normal mode cycle divider
  parameter CDR_O = 48 * 1 - 1  // Overdrive mode cycle divider
)(
  input i_clk,
  input i_rst,
  input [5:0] i_command,
  input i_enable,
  output o_busy,
  output o_irq,
  output o_detect,

  output [7:0] o_data,
  // ONE-WIRE
  input  i_owr,
  output o_owr
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
  reg [2:0] r_send_count = 0;
  reg [7:0] r_send_char  = 0;

  wire [BWD-1:0] bus_rdt;
  wire bus_irq;
  wire owr_p; // Strong pullup

  // Local registers
  reg [5:0] r_command;
  reg [5:0] r_command_ret;
  reg [7:0] r_state = 0;
  reg [7:0] r__state = 0;
  reg       r_detect = 0;
  reg [7:0] r_data = 0;

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
    .owr_p(owr_p), // not used
    .owr_e(o_owr),
    .owr_i(i_owr)
	);

  // shorthand for the 8 bit status register of OWM
  assign w_owrstatus = bus_rdt[7:0];

  // Command enumeration
  parameter 
    c_idle          = 0,
    c_reset_detect  = 1,
    c_skip_rom      = 2,
    c_convert_t     = 3,
    c_read_scratch  = 4,
    c_next_byte     = 5,

    // Do not use in sub modules
    c__read_byte    = 10,
    c__write_byte   = 11;

  // State machine enumeration
  parameter
    s_start        = 0,
    s_wait         = 1,
    s_reset_detect = 2,
    s_skip_rom     = 3,
    s_convert_t    = 4,
    s_read_scratch = 5,
    s_c_next_byte  = 6,
    s_write_bit    = 21,
    s_wait_bit     = 22,
    s_read_bit     = 30,
    s_read_9_bytes = 40,

    // Fail state
    s_error         = 99;

  // Main state machine
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

    /*
     * ===============================
     * Reset the DS18:20 and detect the device
     * ===============================
     */
    if (r_command == c_reset_detect) begin
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

    /*
     * ===============================
     * Send the skip rom command
     * ===============================
     */
    if (r_command == c_skip_rom); begin
      case (r_state)
        // Setup the sending of the command 0xCC
        s_start : begin
          
        end

      endcase
    end

    /*
     * ===============================
     * Sending of a byte
     * ===============================
     * reg       r_enable    : Pull high to start the transfer
     * reg [7:0] r_send_char : The 8-bit array (char) to send
     * reg       r_send_irq  : high 1 cycle when send is done (active high)
     * reg       r_send_busy : high during transfer
     */
    if (r_command == c__read_byte) begin
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
          bus_wdt <= 32'h00000008 | {31'b0, r_send_char[r_send_count]}; // bit 1,4 reset and detect 

          // Handle end of char transmission
          if (r_send_count == 'd7) begin
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
  assign o_data = r_data;

endmodule
