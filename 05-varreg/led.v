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

module led(input i_clk, input i_rst, output o_led_r, output o_led_g, output o_led_b);

  // Source
  reg r_led_g_var;
  reg r_led_r_reg;

  // Dest
  reg r_dest_led_g_var;
  reg r_dest_led_r_reg;
  
  // Permanent assignments
  assign o_led_b = 1'b1;

  // always at clock pulse
  always @(posedge i_clk)
  begin
    // Set RED and GREEN to on (low is on)  
    r_led_r_reg <= 1'b0;
    r_led_g_var =  1'b0;
 
    // Copy the register and the variable to the output wires 
    r_dest_led_r_reg <= r_led_r_reg; 
    r_dest_led_g_var <= r_led_g_var;
  
    // Set RED and GREEN to off (higt is off)
    r_led_r_reg <= 1'b1;
    r_led_g_var = 1'b1;

    // After programming for the first time uncomment the two lines below
    //r_led_r <= r_led_r_reg; 
    //r_led_g <= r_led_g_var;
  end

  // Assign the registers to the output
  assign o_led_r = r_dest_led_r_reg;
  assign o_led_g = r_dest_led_g_var;

endmodule
