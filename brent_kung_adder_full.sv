module brent_kung_adder_full #(
	parameter WIDTH = 32  // Must be a power of two for simplicity
)(
	input  [WIDTH-1:0] A,
	input  [WIDTH-1:0] B,
	input          	Cin,
	output [WIDTH-1:0] Sum,
	output         	Cout
);
	// Step 1: Calculate propagate and generate bits
	wire [WIDTH-1:0] p, g;
    
	genvar i;
	generate
    	for (i = 0; i < WIDTH; i = i + 1) begin : pg_bits
        	assign p[i] = A[i] ^ B[i];
        	assign g[i] = A[i] & B[i];
    	end
	endgenerate
    
	// Step 2: Calculate group propagate and generate signals
	// Number of stages in the prefix tree
	localparam STAGES = $clog2(WIDTH);
    
	// Arrays to store group generate and propagate signals
	// GP[s][i] = group propagate for stage s, index i
	// GG[s][i] = group generate for stage s, index i
	wire [WIDTH-1:0] GP [0:STAGES];
	wire [WIDTH-1:0] GG [0:STAGES];
    
	// Initialize stage 0 with bit-level signals
	generate
    	for (i = 0; i < WIDTH; i = i + 1) begin : stage0
        	assign GP[0][i] = p[i];
        	assign GG[0][i] = g[i];
    	end
	endgenerate
    
	// Build the prefix tree (recursive doubling)
	genvar s, j;
	generate
    	// For each stage
    	for (s = 0; s < STAGES; s = s + 1) begin : stages
        	// For each group in this stage
        	for (j = 0; j < WIDTH; j = j + 1) begin : groups
            	// Only operate on specific indices for each stage
            	if ((j >= (1 << s)) && ((j & ((1 << s) - 1)) == ((1 << s) - 1))) begin
                	// Combine two groups using prefix operator
                	assign GG[s+1][j] = GG[s][j] | (GP[s][j] & GG[s][j - (1 << s)]);
                	assign GP[s+1][j] = GP[s][j] & GP[s][j - (1 << s)];
            	end else begin
                	// Pass through unchanged
                	assign GG[s+1][j] = GG[s][j];
                	assign GP[s+1][j] = GP[s][j];
            	end
        	end
    	end
	endgenerate
    
	// Step 3: Calculate all carries using the prefix tree results
	wire [WIDTH:0] carries;
	assign carries[0] = Cin;
    
	// Final carries calculation
	generate
    	for (i = 0; i < WIDTH; i = i + 1) begin : carry_gen
        	if (i == 0) begin
            	// First bit directly uses Cin
            	assign carries[i+1] = g[i] | (p[i] & Cin);
        	end else if (i == 1) begin
            	// Special case for bit 1
            	assign carries[i+1] = GG[0][i] | (GP[0][i] & carries[i]);
        	end else if (i == 2) begin
            	// Special case for bit 2 - this is the bit that was failing
            	// We need to explicitly consider all previous bits
            	assign carries[i+1] = g[i] | (p[i] & (g[i-1] | (p[i-1] & (g[i-2] | (p[i-2] & Cin)))));
        	end else begin
            	// For other bits, use the prefix tree
            	// Calculate o = largest power of 2 that divides (i+1)
            	localparam integer o = i+1 - (i+1 & i);
           	 
            	if (o == i+1) begin
                	// i+1 is a power of 2, use final stage prefix
                	// We need to account for Cin here as well
                	assign carries[i+1] = GG[STAGES][i] | (GP[STAGES][i] & Cin);
            	end else begin
                	// Calculate stage s = $clog2(o)
                	localparam integer s = $clog2(o);
               	 
                	// Use intermediate stage prefix
                	assign carries[i+1] = GG[s][i] | (GP[s][i] & carries[i+1-o]);
            	end
        	end
    	end
	endgenerate
    
	// Step 4: Calculate final sum bits
	generate
    	for (i = 0; i < WIDTH; i = i + 1) begin : sum_gen
        	assign Sum[i] = p[i] ^ carries[i];
    	end
	endgenerate
    
	// Carry-out is the final carry
	assign Cout = carries[WIDTH];
    
endmodule

// bk_black_cell: A basic black cell for prefix computation.
module bk_black_cell(
	input  g_i, p_i,
	input  g_j, p_j,
	output g_out, p_out
);
	assign g_out = g_j | (p_j & g_i);
	assign p_out = p_j & p_i;
endmodule




