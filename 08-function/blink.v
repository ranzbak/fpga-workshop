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

  // Dim bit, selects the PWM frequency
  parameter p_bit_dev=16;

  // Count register
	reg [25:0] r_count;

  // Dim the LED
  function f_dim;
    input i_led; 

    begin 
      // Count can be used from the module context
      f_dim = i_led ||
            r_count[p_bit_dev] || 
            r_count[p_bit_dev-1] || 
            r_count[p_bit_dev-2] || 
            r_count[p_bit_dev-3];
    end
  endfunction
  
  // Permanent assignments
  assign o_led_r = f_dim(r_count[p_bit_r]);
  assign o_led_g = f_dim(r_count[p_bit_g]);
  assign o_led_b = f_dim(r_count[p_bit_b]);

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
  end

endmodule
