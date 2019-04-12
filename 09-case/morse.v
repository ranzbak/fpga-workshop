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

module morse (
  input  i_clk,
  input  i_rst,
  output o_led_r,
  output o_led_g,
  output o_led_b
  );

	reg [25:0] r_count = 0;
  reg [6:0]  r_morse_state = 0;
  reg        r_led_r = 0;
  reg        r_led_g = 0;
  reg        r_led_b = 0;

  task t_morse;
    input [23:0] i_count_on;
    input [23:0] i_count_off;
    output o_led_morse;

    begin
      if(r_count < i_count_on)
        o_led_morse = 1'b0; // !Important blocking assignment
      else if(r_count < (i_count_on + i_count_off))
        o_led_morse = 1'b1; // !Important blocking assignment
      else
        r_count <= 26'h0;
    end

  endtask

  // This Task is called to show a dash
  task t_morse_did;
    output o_led_morse;
    
    begin
      // On time, Off time 
      // On = h493e00 +- 100ms
      // Off =  h493e00 +- 100ms
      t_morse(24'h493e00, 24'h500000, o_led_morse);
    end
  endtask

  // This Task is called to show a dash
  task t_morse_dash;
    output o_led_morse;
    
    begin
      // On time, Off time 
      // On = h493e00 +- 100ms
      // Off =  h493e00 +- 100ms
      t_morse(24'hdbba00, 24'h493e00, o_led_morse);
    end
  endtask

  // This Task is called to show a dash
  task t_morse_rest;
    reg r_bogus;

    begin
      // On time, Off time 
      // On = h000000 Not on
      // Off = hffffff +- 0.35 seconds 
      t_morse(24'h000000, 24'hffffff, r_bogus);
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
  assign o_led_r = r_led_r;
  assign o_led_g = r_led_g;
  assign o_led_b = r_led_b;
  
  // always at clock pulse
	always @(posedge i_clk)
  begin
    r_count <= r_count + 1;
    r_led_g <= 1'b1;
    r_led_b <= 1'b1;

    case(r_morse_state)
      start : begin
        t_morse_rest(r_led_r);
        if(r_count == 26'h0)
          r_morse_state <= s_0_0;
      end
      s_0_0 : begin
        t_morse_did(r_led_r);
        if(r_count == 26'h0)
          r_morse_state <= s_0_1;
      end
      s_0_1 : begin
        t_morse_did(r_led_r);
        if(r_count == 26'h0)
          r_morse_state <= s_0_2;
      end
      s_0_2 : begin
        t_morse_did(r_led_r);
        if(r_count == 26'h0)
          r_morse_state <= o_1_0;
      end
      o_1_0 : begin
        r_led_b <= 1'b1;
        t_morse_dash(r_led_r);
        if(r_count == 26'h0)
          r_morse_state <= o_1_1;
      end
      o_1_1 : begin
        t_morse_dash(r_led_r);
        if(r_count == 26'h0)
          r_morse_state <= o_1_2;
      end
      o_1_2 : begin
        t_morse_dash(r_led_r);
        if(r_count == 0)
          r_morse_state <= s_2_0;
      end
      s_2_0 : begin
        t_morse_did(r_led_r);
        if(r_count == 0)
          r_morse_state <= s_2_1;
      end
      s_2_1 : begin
        t_morse_did(r_led_r);
        if(r_count == 0)
          r_morse_state <= s_2_2;
      end
      s_2_2 : begin
        t_morse_did(r_led_r);
        if(r_count == 0)
          r_morse_state <= rest;
      end
      rest : begin
        t_morse_rest(r_led_r);
        if(r_count == 0)
          r_morse_state <= start;
      end
      default : 
        r_morse_state <= start;
    endcase
  end

endmodule
