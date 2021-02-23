
//TODO: combine case statements, no need to do it twice!

// procedure here:
// > keep existing interrupts
// > add any specified to set
// > remove any specified to clear
// > IFS and IFC can cancel each other out
// > add any from the IF sources
// > mask result with IEN

module ifr(
  input logic clock, 
  // data memory logic
  input logic [31:0] addr,
  output logic [31:0] data_r,
  output logic [31:0] data_w, 
  input logic wr_en,
  // hardware memory logic
  input logic [31:0] src,
  output logic interrupt
);
  // internal registers
  logic [31:0] IFS; // base + 3
  logic [31:0] IFC; // base + 2
  logic [31:0] IF ; // base + 1
  logic [31:0] IEN; // base + 0

  always_ff @(posedge clock)
  begin
    if (wr_en)
      case (addr)
        32'h0 : IEN = data_w;
        // 32'h1 : IF = data_w; // DO NOT allow IF to be set by program
        32'h2 : IFC = data_w;
        32'h3 : IFS = data_w;
      endcase
    IF = (((IF | IFS) & ~IFC) | src) & IEN;
    IFS = 32'b0;
    IFC = 32'b0;
    
    case (addr)
      32'h0 : data_r = IEN;
      32'h1 : data_r = IF ;
      32'h2 : data_r = IFC;
      32'h3 : data_r = IFS;
    endcase
  end

  assign interrupt = (IF == 32'b0) ? 0 : 1;

endmodule