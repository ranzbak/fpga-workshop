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

	reg [25:0] count;
  
  // Permanent assignments
	assign led_r = count[25];
  assign led_g = count[24];
  assign led_b = count[23];

  // always at clock pulse
	always @(posedge clk)
  begin
    if(rst)
    begin
      count <= 0;
    end
    else
    begin
      count <= count + 1;
    end
  end

endmodule
