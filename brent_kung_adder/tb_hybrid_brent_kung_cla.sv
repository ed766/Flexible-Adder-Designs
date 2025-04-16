`include "hybrid_brent_kung_cla.sv"
`timescale 1ns/1ps
module tb_hybrid_brent_kung_cla;
	parameter N = 16;  // Change this to test different bit widths
	parameter GROUP_SIZE = 4;

	reg  [N-1:0] A, B;
	reg      	Cin;
	wire [N-1:0] Sum;
	wire     	Cout;

	// Instantiate the hybrid adder
	hybrid_brent_kung_cla #(N, GROUP_SIZE) uut (
    	.A(A),
    	.B(B),
    	.Cin(Cin),
    	.Sum(Sum),
    	.Cout(Cout)
	);

	// Golden Model: Simple Ripple-Carry Adder for Reference
	reg [N:0] golden_sum; // N+1 bits to store the carry-out
	integer i, errors = 0;

	initial begin
    	$display("Starting Hybrid Brent-Kung + CLA Testbench...");
   	 
    	// Run multiple random test cases
    	for (i = 0; i < 100; i = i + 1) begin
        	A = $random;
        	B = $random;
        	Cin = $random % 2;

       	 
#5; // Wait for the adder to process

        	// Compute expected result (golden model)
        	golden_sum = A + B + Cin;

        	// Compare results
        	if ((Sum !== golden_sum[N-1:0]) || (Cout !== golden_sum[N])) begin
            	$display("ERROR at test %d: A=%h, B=%h, Cin=%b | Expected Sum=%h, Cout=%b but got Sum=%h, Cout=%b",
                     	i, A, B, Cin, golden_sum[N-1:0], golden_sum[N], Sum, Cout);
            	errors = errors + 1;
	end
    	else begin
    	$display("Success! at test %d: A=%h, B=%h, Cin=%b | Expected Sum=%h, Cout=%b but got Sum=%h, Cout=%b",i, A, B, Cin, golden_sum[N-1:0], golden_sum[N], Sum, Cout);
    	end
    
    	end

    	if (errors == 0)
        	$display("All tests passed successfully!");
    	else
        	$display("Test completed with %d errors.", errors);

    	$finish;
	end
endmodule
