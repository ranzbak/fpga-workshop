/******************************************************************************
*                                                                             *
* Copyright 2016 myStorm Copyright and related                                *
* rights are licensed under the Solderpad Hardware License, Version 0.51      *
* (the “License”); you may not use this file except in compliance with        *
* the License. You may obtain a copy of the License at                        *
* http://solderpad.org/licenses/SHL-0.51. Unless required by applicable       *
* law or agreed to in writing, software, hardware and materials               *
* distributed under this License is distributed on an “AS IS” BASIS,          *
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or             *
* implied. See the License for the specific language governing                *
* permissions and limitations under the License.                              *
*                                                                             *
******************************************************************************/

module morse(input clk, input rst, output led_r, output led_g, output led_b);

	reg [25:0] count = 0;
  reg [6:0] morse_state = 0;
  reg led_r_reg = 0;
  reg led_g_reg = 0;
  reg led_b_reg = 0;

  task morse;
    input [23:0] count_on;
    input [23:0] count_off;
    output reg led_morse;

    begin
      if(count < count_on)
        led_morse <= 1'b0;
      else if(count < (count_on + count_off))
        led_morse <= 1'b1;
      else
        count <= 26'h0;
    end

  endtask

  // This Task is called to show a dash
  task morse_did;
    output led_morse;
    
    begin
      // On time, Off time 
      // On = h493e00 +- 100ms
      // Off =  h493e00 +- 100ms
      morse(24'h493e00, 24'h500000, led_morse);
    end
  endtask

  // This Task is called to show a dash
  task morse_dash;
    output led_morse;
    
    begin
      // On time, Off time 
      // On = h493e00 +- 100ms
      // Off =  h493e00 +- 100ms
      morse(24'hdbba00, 24'h493e00, led_morse);
    end
  endtask

  // This Task is called to show a dash
  task morse_rest;
    
    begin
      // On time, Off time 
      // On = h000000 Not on
      // Off = hffffff +- 0.35 seconds 
      morse(24'h000000, 24'hffffff);
    end
  endtask

  // Verilog has no enum in the 2005 implementation
  // So we use Parameter instead
  parameter 
    start = 0, // Off
    s_0_0 = 1, // . S
    s_0_1 = 2, // .
    s_0_2 = 3, // .
    o_1_0 = 4, // - O
    o_1_1 = 5, // -
    o_1_2 = 6, // -
    s_2_0 = 7, // . S
    s_2_1 = 8, // .
    s_2_2 = 9, // .
    rest  = 10; // Off
  
  // Assign the register to the wire
  assign led_r = led_r_reg;
  assign led_g = led_g_reg;
  assign led_b = led_b_reg;
  
  // always at clock pulse
	always @(posedge clk)
  begin
    count <= count + 1;
    led_g_reg <= 1'b1;
    led_b_reg <= 1'b1;

    case(morse_state)
      start : begin
        morse_rest(led_r_reg);
        if(count == 26'h0)
          morse_state <= s_0_0;
      end
      s_0_0 : begin
        morse_did(led_r_reg);
        if(count == 26'h0)
          morse_state <= s_0_1;
      end
      s_0_1 : begin
        morse_did(led_r_reg);
        if(count == 26'h0)
          morse_state <= s_0_2;
      end
      s_0_2 : begin
        morse_did(led_r_reg);
        if(count == 26'h0)
          morse_state <= o_1_0;
      end
      o_1_0 : begin
        led_b_reg <= 1'b1;
        morse_dash(led_r_reg);
        if(count == 26'h0)
          morse_state <= o_1_1;
      end
      o_1_1 : begin
        morse_dash(led_r_reg);
        if(count == 26'h0)
          morse_state <= o_1_2;
      end
      o_1_2 : begin
        morse_dash(led_r_reg);
        if(count == 0)
          morse_state <= s_2_0;
      end
      s_2_0 : begin
        morse_did(led_r_reg);
        if(count == 0)
          morse_state <= s_2_1;
      end
      s_2_1 : begin
        morse_did(led_r_reg);
        if(count == 0)
          morse_state <= s_2_2;
      end
      s_2_2 : begin
        morse_did(led_r_reg);
        if(count == 0)
          morse_state <= rest;
      end
      rest : begin
        morse_rest(led_r_reg);
        if(count == 0)
          morse_state <= start;
      end
      default : 
        morse_state <= start;
    endcase
  end

endmodule


  parameter
    start        = 0, // Start the sequence
    waitforinput = 1, // Wait for input
    decode       = 2, // Decode received character
    execute      = 3, // Implement command
    done         = 4; // Done, return to start

