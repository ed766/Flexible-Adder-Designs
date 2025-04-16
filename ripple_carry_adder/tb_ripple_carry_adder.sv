



`timescale 1ns/1ps
module tb_ripple_carry_adder;

	// Parameter for adder width and number of tests
	parameter WIDTH = 8;
	parameter NUM_TESTS = 20;

	// Testbench signals
	reg  [WIDTH-1:0] A;
	reg  [WIDTH-1:0] B;
	reg          	Cin;
	wire [WIDTH-1:0] Sum;
	wire         	Cout;

	// Gold model result (WIDTH+1 bits to include carry-out)
	reg [WIDTH:0] gold_result;

	// Instantiate the ripple carry adder
	ripple_carry_adder #(
    	.WIDTH(WIDTH)
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
        	// Generate random test values for A, B, and Cin
        	A   = $random;
        	B   = $random;
        	Cin = $random;
        	#5;  // Allow the signals to propagate
       	 
        	// Calculate the expected result using the built-in addition
        	gold_result = A + B + Cin;
       	 
        	// Compare the RCA result with the golden model
        	if ({Cout, Sum} !== gold_result)
            	$display("Test %0d FAILED: A=%0d, B=%0d, Cin=%b, Expected=%0d, Got=%0d",
                     	i, A, B, Cin, gold_result, {Cout, Sum});
        	else
            	$display("Test %0d PASSED: A=%0d, B=%0d, Cin=%b, Expected=%0d, Got=%0d",
                     	i, A, B, Cin, gold_result, {Cout, Sum});
        	#5;
    	end
    	$finish;
	end

endmodule
