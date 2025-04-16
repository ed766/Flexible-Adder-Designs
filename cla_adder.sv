//CLA-4bit
module cla_4bit(
	input  [3:0] A,
	input  [3:0] B,
	input    	Cin,
	output [3:0] Sum,
	output   	Cout,
	output   	P,   // Group propagate: 1 if all bits propagate
	output   	G	// Group generate: 1 if the block generates a carry
);
	wire [3:0] p, g;
	wire [4:0] c;
    
	assign c[0] = Cin;
	assign p = A ^ B;  	// Individual propagate signals
	assign g = A & B;  	// Individual generate signals
    
	// Compute carry for each bit using CLA equations
	assign c[1] = g[0] | (p[0] & c[0]);
	assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
	assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
	assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);
    
	assign Sum  = p ^ c[3:0];
	assign Cout = c[4];
    
	// Group propagate: all bits must propagate
	assign P = &p;
	// Group generate: the block produces a carry-out
	assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
endmodule





//Generic CLA with configurable width
`include "cla_4bit.v"
module cla_adder #(
	parameter WIDTH = 32,
	parameter BLOCK_SIZE = 4
)(
	input  [WIDTH-1:0] A,
	input  [WIDTH-1:0] B,
	input          	Cin,
	output [WIDTH-1:0] Sum,
	output         	Cout
);
	localparam NUM_BLOCKS = WIDTH / BLOCK_SIZE;
	// Carry signal between blocks
	wire [NUM_BLOCKS:0] carry;
	assign carry[0] = Cin;
    
	genvar i;
	generate
    	for(i = 0; i < NUM_BLOCKS; i = i + 1) begin : cla_blocks
        	cla_4bit cla_block (
            	.A	(A[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
            	.B	(B[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
            	.Cin  (carry[i]),
            	.Sum  (Sum[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
            	.Cout (carry[i+1]),
            	.P	(), // Not used at the top level here
            	.G	()
        	);
    	end
	endgenerate
	assign Cout = carry[NUM_BLOCKS];
endmodule









