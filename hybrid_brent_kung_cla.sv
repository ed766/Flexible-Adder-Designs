`timescale 1ns/1ps
module hybrid_brent_kung_cla #(parameter N = 16, parameter GROUP_SIZE = 4) (
	input logic [N-1:0] A, B,
	input  logic   	Cin,
	output logic[N-1:0] Sum,
	output logic    	Cout
);
	localparam GROUPS = N / GROUP_SIZE;

	// Step 1: Bit-level generate and propagate signals.
	logic [N-1:0] G, P;
	genvar i;
	generate
    	for (i = 0; i < N; i++) begin : bit_level_loop
        	assign G[i] = A[i] & B[i];
        	assign P[i] = A[i] ^ B[i];
    	end
	endgenerate

	// Step 2: Group-level generate and propagate.
	logic [GROUPS-1:0] G_group, P_group;
	genvar g;
	generate
    	for (g = 0; g < GROUPS; g++) begin : group_block
        	// Extract group bits.
        	logic [GROUP_SIZE-1:0] Gi, Pi;
        	assign Gi = G[(g+1)*GROUP_SIZE-1 : g*GROUP_SIZE];
        	assign Pi = P[(g+1)*GROUP_SIZE-1 : g*GROUP_SIZE];
       	 
        	// Ripple within the group (assuming an initial carry of 0).
        	logic [GROUP_SIZE-1:0] G_int, P_int;
        	assign G_int[0] = Gi[0];
        	assign P_int[0] = Pi[0];
        	genvar j;
        	for (j = 1; j < GROUP_SIZE; j++) begin : inner_group
            	assign G_int[j] = Gi[j] | (Pi[j] & G_int[j-1]);
            	assign P_int[j] = Pi[j] & P_int[j-1];
        	end
        	assign G_group[g] = G_int[GROUP_SIZE-1];
        	assign P_group[g] = P_int[GROUP_SIZE-1];
    	end
	endgenerate

	// Step 3: Compute group-level carries (CLA-style).
	logic [GROUPS:0] C_grp;
	assign C_grp[0] = Cin;
	generate
    	for (g = 0; g < GROUPS; g++) begin : carry_group
        	assign C_grp[g+1] = G_group[g] | (P_group[g] & C_grp[g]);
    	end
	endgenerate

	// Step 4: Compute individual sum bits using a local ripple chain.
	generate
    	for (g = 0; g < GROUPS; g++) begin : sum_group
        	// Local ripple carry for this group.
        	logic [GROUP_SIZE:0] local_c;
        	assign local_c[0] = C_grp[g];
        	genvar k;
        	for (k = 0; k < GROUP_SIZE; k++) begin : local_ripple
            	assign local_c[k+1] = G[g*GROUP_SIZE + k] | (P[g*GROUP_SIZE + k] & local_c[k]);
            	assign Sum[g*GROUP_SIZE + k] = P[g*GROUP_SIZE + k] ^ local_c[k];
        	end
    	end
	endgenerate

	assign Cout = C_grp[GROUPS];
endmodule




