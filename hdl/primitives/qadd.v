/*
******************************************************************************
* @file    : qadd.v
* @project : DSP Building Blocks
* @brief   : module to add two numbers given in fixed point format
* @creator : S. R. Zinka (srinivas . zinka [at] gmail . com)
******************************************************************************
* This code is licensed under the MIT License.
******************************************************************************
*/

module qadd #(
	parameter Q = 15, // number of fractional bits
	parameter N = 32  // total number of bits 
	)
	(
    input  wire [N-1:0] a,  // addend 1
    input  wire [N-1:0] b,  // addend 2
    output reg  [N-1:0] c   // sum
    );

always @(a,b) begin

	// both negative or both positive
	if(a[N-1] == b[N-1]) begin						//	since they have the same sign, absolute magnitude increases

		c[N-2:0] = a[N-2:0] + b[N-2:0];		 		//	so we just add the two numbers
		c[N-1] = a[N-1];							//	and set the sign appropriately
		
		end		

	//	subtract a-b
	else if(a[N-1] == 0 && b[N-1] == 1) begin		

		if( a[N-2:0] > b[N-2:0] ) begin				//	if a is greater than b,
			c[N-2:0] = a[N-2:0] - b[N-2:0];			//	then just subtract b from a
			c[N-1] = 0;								//	and manually set the sign to positive
			end
		else begin									//	if a is less than b,
			c[N-2:0] = b[N-2:0] - a[N-2:0];			//	we'll actually subtract a from b
			if (c[N-2:0] == 0) c[N-1] = 0;			//	I don't like negative zero....
			else c[N-1] = 1;						//	and manually set the sign to negative
			end

		end

	//  subtract b-a
	else begin	

		if( a[N-2:0] > b[N-2:0] ) begin				//  if a is greater than b,
			c[N-2:0] = a[N-2:0] - b[N-2:0];			//	we'll actually subtract b from a
			if (c[N-2:0] == 0)
				c[N-1] = 0;							//	I don't like negative zero....
			else
				c[N-1] = 1;							//	and manually set the sign to negative
			end
		else begin									//	if a is less than b,
			c[N-2:0] = b[N-2:0] - a[N-2:0];			//	then just subtract a from b
			c[N-1] = 0;								//	and manually set the sign to positive
			end
		end

	end

endmodule
