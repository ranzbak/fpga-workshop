
module temp #(
    parameter BWD = 32,           // Bus width of the data register
    parameter CDR_N = 48 * 5 - 1, // Normal mode cycle devider
    parameter CDR_O = 48 * 1 - 1  // Overdrive mode cycle devider
  ) (
    input  clk,
    input  rst,
    output led_r,
    output led_g,
    output led_b,
    input  owr_in,
    output owr_out
  );

  // State machine registers
  reg [7:0] cur_state = 'b0;

  // One-wire registers
  reg bus_ren = 0;
  reg bus_wen = 0;
  reg bus_adr = 0;
  reg [BWD-1:0] bus_wdt = 32'b0;
  wire [BWD-1:0] bus_rdt;
  wire bus_irq;
  wire owr_p; // Strong pullup

  // One wire state register
  wire [7:0] status_reg;
  reg  [7:0] status_reg_prev;

  // LED regs
  reg led_r_reg;
  reg led_g_reg;
  reg led_b_reg;

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
  sockit_owm my_onewire (
		.clk(clk),
		.rst(rst),
    .bus_ren(bus_ren),
    .bus_wen(bus_wen),
    .bus_adr(bus_adr),
    .bus_wdt(bus_wdt),
    .bus_rdt(bus_rdt),
    .bus_irq(bus_irq),
    .owr_p(owr_p), // not used
    .owr_e(owr_out),
    .owr_i(owr_in)
	);
  // Setup module clk devider for 48 MHz 
  defparam my_onewire.CDR_N = 48 * 5 - 1;        // CDR_N = f_CLK * BTP_N - 1
  defparam my_onewire.CDR_O = 48 * 1 - 1;        // CDR_O = f_CLK * BTP_O - 1

  // Short hands
  assign status_reg = bus_rdt[7:0];

  // Statement Enum
  parameter
    start      = 0,  // Start of the initialization
    reset      = 1,  // Initiate Reset 
    w_reset    = 2,  // Wait for reset to finish
    detect     = 4,  // Send the detect command
    w_detect   = 5,  // Wait for the detection to finish
    found      = 6,  // Green of the sensor is present
    fail       = 99; // triggered when something went wrong

  // always at clock pulse
	always @(posedge clk)
  begin
    // Zero registers by default
    bus_ren <= 1'b0;
    bus_wen <= 1'b0;
    bus_adr <= 1'b0;

    // All LED's OFF
    led_r_reg<= 1'b1;
    led_g_reg<= 1'b1;
    led_b_reg<= 1'b1;

    // fill previous register
    status_reg_prev <= status_reg;

    // Reset
    if (rst == 1'b1) begin
      cur_state <= reset;
    end

    // Statemachine to handle chip interaction
    case (cur_state)
      start : begin
        // Wait for reset to clear
        if(rst == 0) 
          cur_state <= reset;
      end
      reset : begin
        // Wait until the reset goes low
        if ( rst == 1'b0 )
          cur_state <= detect;
      end
      detect : begin
        // Setup the registers to start a reset and detect cycle
        bus_ren <= 1'b0;   // Read enable
        bus_wen <= 1'b1;   // Write enable
        bus_adr <= 1'b0;   // Address bus implicit for clarity
        bus_wdt <= 32'h0000000A; // bit 1,4 reset and detect 

        // After one cycle wait for the detect
        cur_state <= w_detect;
      end
      w_detect : begin
        bus_ren <= 1'b1;   // Read enable
        bus_adr <= 1'b0;   // Address bus implicit for clarity

        // Wait till the end of the cycle
        if ( status_reg_prev[3] == 1'b1 && status_reg[3] == 1'b0 ) begin
          if ( status_reg[0] == 1'b0 ) begin
           // no device detected
           cur_state <= found;
          end else begin
           // device found
           cur_state <= fail;
          end 
        end

        // Red and Blue LED during search
        led_r_reg <= 1'b1; // Orange
        led_g_reg <= 1'b1;
      end
      found : begin
        // The green LED to indicate success
        led_g_reg <= 1'b0;
      end
      fail : begin
        // The RED LED to indicate failure
        led_r_reg <= 1'b0;
      end
      default : begin
        // Illegal state go to fail
        //cur_state <= fail;
        led_r_reg <= 1'b0;
        led_g_reg <= 1'b0;
        led_b_reg <= 1'b0;
      end
    endcase
  end

  // Assign LED registers to wires
  assign led_r = led_r_reg;
  assign led_g = led_g_reg;
  assign led_b = led_b_reg;

endmodule
