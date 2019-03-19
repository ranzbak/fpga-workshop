  
  // Verilog code
  always @(posedge clock)
  begin
    if (index < 10)
    begin
      data[index] <= data[index] + 1;
      index       <= index + 1;
    end
  end

  // Performs a shift left using a for loop
  always @(posedge i_Clock)
	begin
		for(ii=0; ii<3; ii=ii+1)
			r_Shift_With_For[ii+1] <= r_Shift_With_For[ii];
	end
     
  // Performs a shift left using regular statements
  always @(posedge i_Clock)
	begin
		r_Shift_Regular[1] <= r_Shift_Regular[0];
		r_Shift_Regular[2] <= r_Shift_Regular[1];
		r_Shift_Regular[3] <= r_Shift_Regular[2];
	end    



