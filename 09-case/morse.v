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
    input [24:0] i_count_on;
    input [24:0] i_count_off;
    output o_led_morse;

    begin
      if(r_count < i_count_on)
        o_led_morse = 1'b0; // !Important blocking assignment
      else if(r_count < (i_count_on + i_count_off))
        o_led_morse = 1'b1; // !Important blocking assignment
      else
        r_count <= 'h0;
    end

  endtask

  // This Task is called to show a did
  task t_morse_did;
    output o_led_morse;
    
    begin
      // On time, Off time 
      // On = h493e00 +- 100ms
      // Off =  h493e00 +- 100ms
      t_morse(23'h249f00, 23'h280000, o_led_morse);
    end
  endtask

  // This Task is called to show a dash
  task t_morse_dash;
    output o_led_morse;
    
    begin
      // On time, Off time 
      // On = h493e00 +- 100ms
      // Off =  h493e00 +- 100ms
      t_morse(23'h6ddd00, 23'h249f00, o_led_morse);
    end
  endtask

  // This Task is called to show a rest
  reg [26:0] r_long_rest = 'h0;
  task t_morse_rest;
    output o_led_morse;
    begin
      r_count <= 'b1;
      r_long_rest <= r_long_rest + 1;
      o_led_morse = 1'b1;
      if (r_long_rest[25] == 1'b1) begin
        r_count <= 'b0;
        r_long_rest <= 'b0;
      end
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
        if(r_count == 0)
          r_morse_state <= s_0_0;
      end
      s_0_0 : begin
        t_morse_did(r_led_r);
        if(r_count == 0)
          r_morse_state <= s_0_1;
      end
      s_0_1 : begin
        t_morse_did(r_led_r);
        if(r_count == 0)
          r_morse_state <= s_0_2;
      end
      s_0_2 : begin
        t_morse_did(r_led_r);
        if(r_count == 0)
          r_morse_state <= o_1_0;
      end
      o_1_0 : begin
        t_morse_dash(r_led_r);
        if(r_count == 0)
          r_morse_state <= o_1_1;
      end
      o_1_1 : begin
        t_morse_dash(r_led_r);
        if(r_count == 0)
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
        // t_morse_rest(r_led_r);
        // if(r_count == 0)
          r_morse_state <= start;
      end
      default : 
        r_morse_state <= start;
    endcase
  end

endmodule
