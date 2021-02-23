/**
 * rvfpga: RISC-V FPGA Top Level Module
 *	inputs:
 *		KEY0 : nibble input
 *	outputs:
 *		LED9 : systemclock, scaled down to ~ 1 Hz
 * notes:
**/
module rvfpga(
	input CLOCK_50, input CLOCK2_50, input CLOCK3_50, input CLOCK4_50,
	input [3:0] KEY, input [9:0] SW, output [9:0] LEDR,
	output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2, output [6:0] HEX3, output [6:0] HEX4, output [6:0] HEX5,

	output [12:0] DRAM_ADDR, output [1:0] DRAM_BA, output DRAM_CAS_N, output DRAM_CKE, output DRAM_CLK,
	output DRAM_CS_N, inout [15:0] DRAM_DQ, output DRAM_LDQM, output DRAM_RAS_N, output DRAM_UDQM, output DRAM_WE_N,

	input TD_CLK27,	input [7:0] TD_DATA, input TD_HS, output TD_RESET_N, input TD_VS,
	output VGA_BLANK_N, output [7:0] VGA_B, output VGA_CLK, output [7:0] VGA_G, output VGA_HS, output [7:0] VGA_R, output VGA_SYNC_N, output VGA_VS,
	input AUD_ADCDAT, inout AUD_ADCLRCK, inout AUD_BCLK, output AUD_DACDAT, inout AUD_DACLRCK, output AUD_XCK,
	inout PS2_CLK, inout PS2_CLK2, inout PS2_DAT, inout PS2_DAT2,
	output ADC_CONVST, output ADC_DIN, input ADC_DOUT, output ADC_SCLK,
	output FPGA_I2C_SCLK, inout FPGA_I2C_SDAT,
	input IRDA_RXD, output IRDA_TXD
);
	// Clock and reset signals
	logic clk, rst;
	logic rstz;

	// Instruction memory interface
	logic [31:0] instr_addr;
	logic [31:0] instr_data;
	logic instr_req;
	logic instr_ack;

	// Data memory interface
	logic [31:0] data_addr;
	logic [31:0] data_rd_data;
	logic [31:0] data_wr_data;
	logic [3:0] data_mask;
	logic data_wr_en;
	logic data_req;
	logic data_ack;

	// Interrupt Sources
	logic software_interrupt;
	logic timer_interrupt;
	logic external_interrupt;

	logic clock_pll;
	pll_clock U_PLL(
		.refclk(CLOCK_50),
		.rst(rst),
		.outclk_0(clk_pll)
	);

	logic clk_div;
	clkdiv #(.DIVIDER (250000)) U_CLKDIV(
		.clk_in(clk_pll),
		.rst(rst),
		.clk_out(clk_div)
	);

	assign clk = clk_div;


	logic [31:0] sevsegval = 32'b0;
	always_ff @(posedge clk)
	begin
		if (data_wr_en == 1'b1)
		begin
			sevsegval = data_wr_data;
			data_ack = 1'b1;	
		end
		else
		begin
			data_ack = 1'b0;
		end
	end

	ledd U_LED9(clk, LEDR[9]);				// clock LED
	ledd U_LED8(rst , LEDR[8]);				// reset LED

	btnd U_KEY0(.btn(KEY[0]), .sts(rst));	// reset BTN
	btnd U_KEY1(.btn(~KEY[1]), .sts(rstz)); // resetz BTN

	// logic instr_req;
	assign instr_ack = 1'b1;
	instr_rom U_ROM_INSTR(
		.address(instr_addr[11:2]), // shortening here... should probably keep in mind
		.clock(clk),
		.q(instr_data)
	);

	// TODO: req and ack?
	// logic data_req;
	// assign data_ack = 1'b1;
	data_ram U_RAM_DATA(
		.byteena_a(data_mask),
		.clock(clk),
		.data(data_wr_data),
		.rdaddress(data_addr),
		.wraddress(data_addr),
		.wren(data_wr_en),
		.q(data_rd_data)
	);
	
	hexdd U_SEG0(.hex(sevsegval[3:0]), .disp(HEX0));
	hexdd U_SEG1(.hex(sevsegval[7:4]), .disp(HEX1));
	// hexdd U_SEG2(.hex(data_addr[3:0]), .disp(HEX2));
	// hexdd U_SEG3(.hex(data_addr[7:4]), .disp(HEX3));
	// hexdd U_SEG4(.hex(4'b0), .disp(HEX4));
	hexdd U_SEG5(.hex(instr_addr[5:2]), .disp(HEX5));
	
	kronos_core #(
	  .BOOT_ADDR            (32'h0),
	  .FAST_BRANCH          (0    ),
	  .EN_COUNTERS          (1    ),
	  .EN_COUNTERS64B       (0    ),
	  .CATCH_ILLEGAL_INSTR  (1    ),
	  .CATCH_MISALIGNED_JMP (0    ),
	  .CATCH_MISALIGNED_LDST(0    )
	) U_CORE (
		 .clk               (clk               ),
		 .rstz              (rstz              ),
		 .instr_addr        (instr_addr        ),
		 .instr_data        (instr_data        ),
		 .instr_req         (instr_req         ),
		 .instr_ack         (instr_ack         ),
		 .data_addr         (data_addr         ),
		 .data_rd_data      (data_rd_data      ),
		 .data_wr_data      (data_wr_data      ),
		 .data_mask         (data_mask         ),
		 .data_wr_en        (data_wr_en        ),
		 .data_req          (data_req          ),
		 .data_ack          (data_ack          ),
		 .software_interrupt(software_interrupt),
		 .timer_interrupt   (timer_interrupt   ),
		 .external_interrupt(external_interrupt)
	);
	
endmodule
