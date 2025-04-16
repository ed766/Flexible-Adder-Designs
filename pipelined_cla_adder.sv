`include "cla_4bit.v"
module pipelined_cla_adder #(
	parameter WIDTH = 32,
	parameter BLOCK_SIZE = 4
)(
	input           	clk,
	input           	reset,
	input  [WIDTH-1:0]  A,
	input  [WIDTH-1:0]  B,
	input           	Cin,
	output reg [WIDTH-1:0] Sum,
	output reg      	Cout
);
	localparam NUM_BLOCKS = WIDTH / BLOCK_SIZE;
    
	// ------------------------------------------------------
	// Stage 1: Compute group propagate and generate for each block
	// ------------------------------------------------------
	// For each block, we instantiate a 4-bit CLA (with dummy Cin)
	// to extract the block-level propagate and generate signals.
	wire [NUM_BLOCKS-1:0] block_P;
	wire [NUM_BLOCKS-1:0] block_G;
    
	genvar i;
	generate
    	for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : stage1
        	// Slice out the block inputs
        	wire [BLOCK_SIZE-1:0] a_block = A[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE];
        	wire [BLOCK_SIZE-1:0] b_block = B[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE];
        	// Use the 4-bit CLA to compute group P and G
        	// (Cin is set to 0 because we only care about P and G here)
        	cla_4bit cla_inst (
            	.A	(a_block),
            	.B	(b_block),
            	.Cin  (1'b0),
            	.Sum  (), // Unused
            	.Cout (), // Unused
            	.P	(block_P[i]),
            	.G	(block_G[i])
        	);
    	end
	endgenerate

	// Register Stage 1 outputs and inputs
	reg [NUM_BLOCKS-1:0] reg_block_P, reg_block_G;
	reg [WIDTH-1:0]  	reg_A, reg_B;
	reg              	reg_Cin;
    
	always @(posedge clk or posedge reset) begin
    	if (reset) begin
        	reg_block_P <= 0;
        	reg_block_G <= 0;
        	reg_A   	<= 0;
        	reg_B   	<= 0;
        	reg_Cin 	<= 0;
    	end else begin
        	reg_block_P <= block_P;
        	reg_block_G <= block_G;
        	reg_A   	<= A;
        	reg_B   	<= B;
        	reg_Cin 	<= Cin;
    	end
	end
    
	// ------------------------------------------------------
	// Stage 2: Compute block carry signals using a parallel lookahead network
	// ------------------------------------------------------
	reg [NUM_BLOCKS:0] block_carry;
	integer j;
	always @(*) begin
    	block_carry[0] = reg_Cin;
    	for (j = 0; j < NUM_BLOCKS; j = j + 1) begin
        	block_carry[j+1] = reg_block_G[j] | (reg_block_P[j] & block_carry[j]);
    	end
	end

	// ------------------------------------------------------
	// Stage 3: Compute final sum using 4-bit CLA blocks with registered inputs
	// and computed block carries.
	// ------------------------------------------------------
	wire [WIDTH-1:0] sum_comb;
	generate
    	for (i = 0; i < NUM_BLOCKS; i = i + 1) begin : stage3
        	cla_4bit cla_inst2 (
            	.A	(reg_A[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
            	.B	(reg_B[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
            	.Cin  (block_carry[i]),
            	.Sum  (sum_comb[(i+1)*BLOCK_SIZE-1 : i*BLOCK_SIZE]),
            	.Cout (), // Unused here
            	.P	(), // Not used in final sum computation
            	.G	()
        	);
    	end
	endgenerate
    
	// Final pipeline register for the overall Sum and Cout
	always @(posedge clk or posedge reset) begin
    	if (reset) begin
        	Sum  <= 0;
        	Cout <= 0;
    	end else begin
        	Sum  <= sum_comb;
        	Cout <= block_carry[NUM_BLOCKS];
    	end
	end

endmodule







