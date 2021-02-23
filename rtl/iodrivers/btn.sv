/**
 * btnd: Button Driver
 *	inputs:
 *		btn : button input
 *	outputs:
 *		sts : button status
 * notes:
**/
module btnd(input logic btn, output logic sts);
	always_comb
	begin
        sts = ~btn;
	end
endmodule
