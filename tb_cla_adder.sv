`timescale 1ns/1ps
`include "cla_adder.v"
module tb_cla_adder;

	// Parameters for adder and testbench
	parameter WIDTH = 32;
	parameter BLOCK_SIZE = 4;
	parameter NUM_TESTS = 20;

	// Testbench signals
	reg  [WIDTH-1:0] A;
	reg  [WIDTH-1:0] B;
	reg          	Cin;
	wire [WIDTH-1:0] Sum;
	wire         	Cout;

	// Gold model result (WIDTH+1 bits to include the carry-out)
	reg [WIDTH:0] gold_result;

	// Instantiate the CLA adder
	cla_adder #(
    	.WIDTH(WIDTH),
    	.BLOCK_SIZE(BLOCK_SIZE)
	) uut (
    	.A(A),
    	.B(B),
    	.Cin(Cin),
    	.Sum(Sum),
    	.Cout(Cout)
	);

	integer i;
	initial begin
    	for (i = 0; i < NUM_TESTS; i = i + 1) begin
        	// Generate random test vectors
        	A   = $random;
        	B   = $random;
        	Cin = $random % 2;  // Ensure Cin is 0 or 1
        	#5;  // Allow time for signal propagation

        	// Compute the expected result using built-in addition
        	gold_result = A + B + Cin;

        	// Compare the output of the CLA adder with the golden result
        	if ({Cout, Sum} !== gold_result)
            	$display("Test %0d FAILED: A = %h, B = %h, Cin = %b, Expected = %h, Got = %h",
                     	i, A, B, Cin, gold_result, {Cout, Sum});
        	else
            	$display("Test %0d PASSED: A = %h, B = %h, Cin = %b, Expected = %h, Got = %h",
                     	i, A, B, Cin, gold_result, {Cout, Sum});
        	#5;
    	end
    	$finish;
	end

endmodule
