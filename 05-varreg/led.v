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

module led(input clk, input rst, output led_r, output led_g, output led_b);

  // Source
  reg led_g_var;
  reg led_r_reg;

  // Dest
  reg dest_led_g_var;
  reg dest_led_r_reg;
  
  // Permanent assignments
  assign led_b = 1'b1;

  // always at clock pulse
  always @(posedge clk)
  begin
    // Set RED and GREEN to on (low is on)  
    led_r_reg <= 1'b0;
    led_g_var =  1'b0;
 
    // Copy the register and the variable to the output wires 
    dest_led_r_reg <= led_r_reg; 
    dest_led_g_var <= led_g_var;
  
    // Set RED and GREEN to off (higt is off)
    led_r_reg <= 1'b1;
    led_g_var = 1'b1;

    // After programming for the first time uncomment the two lines below
    //led_r <= led_r_reg; 
    //led_g <= led_g_var;
  end

  // Assign the registers to the output
  assign led_r = dest_led_r_reg;
  assign led_g = dest_led_g_var;

endmodule
