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

	reg [25:0] count;
  
  // Permanent assignments
  // RED LED by default pick bit 25 (0.7 seconds)
	assign led_r = count[r_bit] || count[d_bit] || count[d_bit-1] || count[d_bit-2] || count[d_bit-3];
  // GREEN LED by default pick bit 24 (0.35 seconds)
  assign led_g = count[g_bit] || count[d_bit] || count[d_bit-1] || count[d_bit-2] || count[d_bit-3];
  // BLUE LED by default pick bit 23 (0.13 secounds)
  assign led_b = count[b_bit] || count[d_bit] || count[d_bit-1] || count[d_bit-2] || count[d_bit-3];

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
  end

endmodule
