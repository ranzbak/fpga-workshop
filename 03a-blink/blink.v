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

  reg count0_c = 1'b0;
  reg [13:0] count0 = 14'h0000;
  reg [13:0] count1 = 14'h0000;
  
  // Permanent assignment
  assign led_r = count1[12];
  assign led_g = count1[11];
  assign led_b = count1[10];

  // always at clock pulse
  always @(posedge clk)
  begin
    if(rst)
    begin
      count0 <= 0;
      //count1 <= 0;
    end
    else
    begin
      // First clock cycle with carry pulse
      count0 <= count0 + 1;
      count0_c <= count0[13];

      // Second clock cycle
      if(count0_c == 1'b1 && count0[13] == 1'b0) begin
        count1 <= count1 + 1;
      end  
    end
  end

endmodule
