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

module blink(input clk, input rst, output led_r, output led_g, output led_b);
  // Cycle bits
  parameter r_bit=25;
  parameter g_bit=24;
  parameter b_bit=23;

  // Dim bits bit 16 around 800Hz)
  parameter d_bit=16;

  // output registers
  reg out_led_r;
  reg out_led_g;
  reg out_led_b;

	reg [25:0] count;

  // Dim the LED
  task dim;
    input led_in; 
    output led_out;
    begin 
      // Count can be used from the module context
      led_out = led_in || 
                  count[d_bit] || 
                  count[d_bit-1] || 
                  count[d_bit-2] || 
                  count[d_bit-3];
    end
  endtask
  
  // always at clock pulse
	always @(posedge clk)
  begin
    if(rst)
    begin
      count = 0;
    end
    else
    begin
      count <= count + 1;
    end

    // Run the tasks to set the LED's
    dim(count[r_bit], out_led_r);
    dim(count[g_bit], out_led_g);
    dim(count[b_bit], out_led_b);
  end

  // Assign output register to output wires
  assign led_r = out_led_r;
  assign led_g = out_led_g;
  assign led_b = out_led_b;
endmodule

