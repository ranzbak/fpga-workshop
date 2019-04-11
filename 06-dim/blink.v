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
  parameter r_bit_r=25; // (1.4Hz)
  parameter r_bit_g=24; // (2.8Hz)
  parameter r_bit_b=23; // (5.7Hz)

  // Have a counter of 25 bits (0.7Hz)
  parameter p_bit_count = 25;
  // Dim bits bit 16 around (800Hz)
  parameter p_bit_d     = 16;

	reg [p_bit_count:0] r_count;
  
  // Permanent assignments
  // RED LED by default pick bit 25 (0.7 seconds)
	assign o_led_r = r_count[r_bit_r] || r_count[p_bit_d] || r_count[p_bit_d-1] || r_count[p_bit_d-2] || r_count[p_bit_d-3];
  // GREEN LED by default pick bit 24 (0.35 seconds)
  assign o_led_g = r_count[r_bit_g] || r_count[p_bit_d] || r_count[p_bit_d-1] || r_count[p_bit_d-2] || r_count[p_bit_d-3];
  // BLUE LED by default pick bit 23 (0.13 secounds)
  assign o_led_b = r_count[r_bit_b] || r_count[p_bit_d] || r_count[p_bit_d-1] || r_count[p_bit_d-2] || r_count[p_bit_d-3];

  // always at clock pulse
	always @(posedge i_clk)
  begin
    if(i_rst) begin
      // Hold to zero during reset
      r_count = 0;
    end else begin
      // Count!
      r_count <= r_count + 1;
    end
  end

endmodule
