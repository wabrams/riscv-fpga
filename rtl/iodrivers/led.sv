/**
 * ledd: LED Driver
 *	inputs:
 *		sig : signal input
 *	outputs:
 *		sts : led status
 * notes:
 *  as I have trouble remembering if LEDs are inverted or
 *  not between the DE10-Standard and DE10-Lite, this ensures
 *  that if the input is HIGH, the LED is ON
 *  (figure it out here once, and then just implement w/ module)
**/
module ledd(input logic sig, output logic sts);
	always_comb
	begin
        sts = sig;
	end
endmodule