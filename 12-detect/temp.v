
module temp #(
    parameter BWD = 32,           // Bus width of the data register
    parameter CDR_N = 48 * 6 - 1, // Normal mode cycle divider
    parameter CDR_O = 48 * 1 - 1  // Overdrive mode cycle divider
  ) (
    input  i_clk,
    input  i_rst,
    output o_led_r,
    output o_led_g,
    output o_led_b,
    input  i_owr,
    output o_owr
  );

  // State machine registers
  reg [7:0] r_cur_state = 'b0;

  // One-wire registers
  reg r_bus_ren = 0;
  reg r_bus_wen = 0;
  reg r_bus_adr = 0;
  reg [BWD-1:0] r_bus_wdt = 32'b0;
  wire [BWD-1:0] r_bus_rdt;
  wire r_bus_irq;
  wire w_owr_p; // Strong pullup

  // One wire state register
  wire [7:0] w_status_reg;
  reg  [7:0] r_status_reg_prev;

  reg [14:0] r_idle_time = 'd20000;

  // LED regs
  reg r_led_r;
  reg r_led_g;
  reg r_led_b;

  /*
  * Instantiate the onewire interface
  *
  * system signals
  * input            i_clk,
  * input            i_rst,
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
    ) my_onewire (
		.clk(i_clk),
		.rst(i_rst),
    .bus_ren(r_bus_ren),
    .bus_wen(r_bus_wen),
    .bus_adr(r_bus_adr),
    .bus_wdt(r_bus_wdt),
    .bus_rdt(r_bus_rdt),
    .bus_irq(r_bus_irq),
    .owr_p(w_owr_p), // not used
    .owr_e(o_owr),
    .owr_i(i_owr)
	);
  // Setup module clock divider for 48 MHz 
  // defparam my_onewire.CDR_N = CDR_N;  // CDR_N = f_CLK * BTP_N - 1
  // defparam my_onewire.CDR_O = CDR_O;  // CDR_O = f_CLK * BTP_O - 1
  // defparam my_onewire.CDR_E = 0;      // Constant clock frequency, no need for a dynamic clock divider
  // defparam my_onewire.OVD_E = 0;      // Disable overdrive

  // Short hands
  assign w_status_reg = r_bus_rdt[7:0];

  // Statement Enum
  parameter
    start         = 0,  // Start of the initialization
    reset         = 1,  // Initiate Reset
    w_reset       = 2,  // Wait for reset to finish
    detect        = 4,  // Send the detect command
    w_detect      = 5,  // Wait for the detection to finish
    detected      = 6,  // Green of the sensor is present

    fail          = 99; // triggered when something went wrong

  // always at clock pulse
	always @(posedge i_clk)
  begin
    // Zero registers by default
    r_bus_ren <= 1'b0;
    r_bus_wen <= 1'b0;
    r_bus_adr <= 1'b0;

    // All LED's OFF
    r_led_r<= 1'b1;
    r_led_g<= 1'b1;
    r_led_b<= 1'b1;

    // fill previous register
    r_status_reg_prev <= w_status_reg;

    // Reset
    if (i_rst == 1'b1) begin
      r_cur_state <= reset;
    end

    // State machine to handle chip interaction
    case (r_cur_state)

      // Start status Initializations can be done here
      start : begin
        // Wait for reset to clear
        if(i_rst == 0) 
          r_cur_state <= reset;
      end

      // Wait until the rst goes low
      reset : begin
        if ( i_rst == 1'b0 )
          r_cur_state <= detect;
      end

      /*
       * ===============================
       * Initiate the detection sequence
       * ===============================
       */
      detect : begin
        // Setup the registers to start a reset and detect cycle
        r_bus_ren <= 1'b0;   // Read enable
        r_bus_wen <= 1'b1;   // Write enable
        r_bus_adr <= 1'b0;   // Address bus implicit for clarity
        r_bus_wdt <= 32'h0000000A; // bit 1,4 reset and detect 

        // After one cycle wait for the detect
        r_cur_state <= w_detect;
      end

      /*
       * ===============================
       * Wait for the detection result
       * ===============================
       */
      w_detect : begin
        r_bus_ren <= 1'b1;   // Read enable
        r_bus_adr <= 1'b0;   // Address bus implicit for clarity

        // Wait till the end of the cycle
        if ( r_status_reg_prev[3] == 1'b1 && w_status_reg[3] == 1'b0 ) begin
          if ( w_status_reg[0] == 1'b0 ) begin
           // device detected
           r_cur_state <= detected;
          end else begin
           // no device detected
           r_cur_state <= fail;
          end 
        end

        // Red and Blue LED during search
        r_led_r <= 1'b1; // Orange
        r_led_g <= 1'b1;
      end

      /*
       * ===============================
       * We found a device on the one wire
       * ===============================
       */
      detected : begin
        // The green LED to indicate success
        r_led_g <= 1'b0;

        // Wait and detect again
        r_idle_time <= r_idle_time - 1;
        if ( r_idle_time == 0 ) begin
          r_idle_time <= 'd20000;
          r_cur_state <= start;
        end
      end

      /*
       * ===============================
       * Something failed, constant red light
       * ===============================
       */
      fail : begin
        // The RED LED to indicate failure
        r_led_r <= 1'b0;

        // Wait before trying again
        r_idle_time <= r_idle_time - 1;
        if ( r_idle_time == 0 ) begin
          r_idle_time <= 'd20000;
          r_cur_state <= start;
        end
      end
      default : begin
        // Illegal state, should *NOT* happen
        r_led_r <= 1'b0;
        r_led_g <= 1'b0;
        r_led_b <= 1'b0;
      end
    endcase
  end

  // Assign LED registers to wires
  assign o_led_r = r_led_r;
  assign o_led_g = r_led_g;
  assign o_led_b = r_led_b;

endmodule
