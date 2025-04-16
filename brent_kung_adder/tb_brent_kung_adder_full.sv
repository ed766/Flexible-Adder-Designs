`timescale 1ns/1ps
`include "brent_kung_adder_full.v"
`timescale 1ns/1ps
module tb_brent_kung_adder_full;

	// Parameters for the testbench
	parameter WIDTH = 32;
	parameter NUM_TESTS = 100;

	// Testbench signals
	reg  [WIDTH-1:0] A;
	reg  [WIDTH-1:0] B;
	reg          	Cin;
	wire [WIDTH-1:0] Sum;
	wire         	Cout;

	// Expected (golden) result: WIDTH+1 bits (carry included)
	reg  [WIDTH:0] expected;
	integer i;

	// Instantiate the full Brent–Kung adder module
	brent_kung_adder_full #(WIDTH) dut (
    	.A(A),
    	.B(B),
    	.Cin(Cin),
    	.Sum(Sum),
    	.Cout(Cout)
	);

	initial begin
    	$display("Starting Full Brent-Kung Adder Testbench (WIDTH = %0d)", WIDTH);
    	for(i = 0; i < NUM_TESTS; i = i + 1) begin
        	// Generate random test vectors
        	A = $random;
        	B = $random;
        	Cin = $random % 2;  // Ensure Cin is 0 or 1
        	#10;  // Wait for combinational logic to settle
       	 
        	// Compute expected result using built-in addition (with one extra bit)
        	expected = {1'b0, A} + {1'b0, B} + Cin;
       	 
        	// Compare the DUT's output with the expected result
        	if ({Cout, Sum} !== expected)
            	$display("Test %0d FAILED: A = %h, B = %h, Cin = %b, Expected = %h, Got = %h",
                     	i, A, B, Cin, expected, {Cout, Sum});
        	else
            	$display("Test %0d PASSED: A = %h, B = %h, Cin = %b, Expected = %h, Got = %h",
                     	i, A, B, Cin, expected, {Cout, Sum});
        	#10;
    	end
    	$finish;
	end

endmodule
