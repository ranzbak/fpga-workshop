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

module blink(input i_clk, input i_rst, output o_led_r, output o_led_g, output o_led_b);
  // Cycle bits
  parameter p_bit_r=25;
  parameter p_bit_g=24;
  parameter p_bit_b=23;

  // Dim bits bit 16 around 800Hz)
  parameter p_bit_dev=16;

  // output registers
  reg r_led_r;
  reg r_led_g;
  reg r_led_b;

  reg [25:0] r_count = 'b0;

  // Dim the LED
  task dim;
    input i_led; 
    output o_led;
    begin 
      // Count can be used from the module context
      o_led = i_led || 
        r_count[p_bit_dev] || 
        r_count[p_bit_dev-1] || 
        r_count[p_bit_dev-2] || 
        r_count[p_bit_dev-3];
    end
  endtask
  
  // always at clock pulse
  always @(posedge i_clk)
  begin
    if(i_rst)
    begin
      r_count = 0;
    end
    else
    begin
      r_count <= r_count + 1;
    end

    // Run the tasks to set the LED's
    dim(r_count[p_bit_r], r_led_r);
    dim(r_count[p_bit_g], r_led_g);
    dim(r_count[p_bit_b], r_led_b);
  end

  // Assign output register to output wires
  assign o_led_r = r_led_r;
  assign o_led_g = r_led_g;
  assign o_led_b = r_led_b;
endmodule

