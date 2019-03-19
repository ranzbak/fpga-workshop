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

  // Dim the LED
  task dim;
    input led_in; 
    output led_out;
    begin 
      // Count can be used from the module context
      led_out = led_in || count[15] || count[14] || count[13] || count[12];
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
    dim(count[25], led_r);
    dim(count[24], led_g);
    dim(count[23], led_b);
  end

endmodule

