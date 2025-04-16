`timescale 1ns/1ps
`include "pipelined_cla_adder.v"
module tb_pipelined_cla;

	// Parameters
	parameter WIDTH = 32;
	parameter BLOCK_SIZE = 4;
	parameter NUM_CYCLES = 50;  // Total number of clock cycles to simulate

	// Signals for DUT
	reg           	clk;
	reg           	reset;
	reg  [WIDTH-1:0]  A;
	reg  [WIDTH-1:0]  B;
	reg           	Cin;
	wire [WIDTH-1:0]  Sum;
	wire          	Cout;

	// Instantiate the pipelined CLA adder
	pipelined_cla_adder #(
    	.WIDTH(WIDTH),
    	.BLOCK_SIZE(BLOCK_SIZE)
	) uut (
    	.clk(clk),
    	.reset(reset),
    	.A(A),
    	.B(B),
    	.Cin(Cin),
    	.Sum(Sum),
    	.Cout(Cout)
	);

	// Pipeline registers for expected result (WIDTH+1 bits to include carry)
	// The pipelined CLA has a latency of 2 cycles.
	reg [WIDTH:0] gold_pipe0, gold_pipe1;
	reg [31:0] cycle_count;

	// Clock generation: 10ns period
	initial begin
    	clk = 0;
    	forever #5 clk = ~clk;
	end

	// Reset generation
	initial begin
    	reset = 1;
    	#12;  // Hold reset for a little more than one half cycle
    	reset = 0;
	end

	// Cycle counter for diagnostic messages
	always @(posedge clk) begin
    	if (reset)
        	cycle_count <= 0;
    	else
        	cycle_count <= cycle_count + 1;
	end

	// Generate random test vectors on every rising edge (when not in reset)
	always @(posedge clk) begin
    	if (!reset) begin
        	A   <= $random;
        	B   <= $random;
        	Cin <= $random % 2;
    	end
	end

	// Compute the golden result for the current inputs and shift it through a 2-cycle pipeline.
	// This aligns with the pipelined CLA's latency.
	always @(posedge clk) begin
    	if (reset) begin
        	gold_pipe0 <= 0;
        	gold_pipe1 <= 0;
    	end else begin
        	gold_pipe1 <= gold_pipe0;
        	gold_pipe0 <= A + B + Cin;
    	end
	end

	// Compare the pipelined CLA output with the expected result.
	// The expected result corresponding to the input from two cycles ago is in gold_pipe1.
	always @(posedge clk) begin
    	if (!reset && cycle_count > 2) begin
        	if ({Cout, Sum} !== gold_pipe1)
            	$display("Cycle %0d: MISMATCH. Expected: %h, Got: %h",
                      	cycle_count, gold_pipe1, {Cout, Sum});
        	else
            	$display("Cycle %0d: MATCH. Expected: %h, Got: %h",
                      	cycle_count, gold_pipe1, {Cout, Sum});
    	end
	end

	// Terminate simulation after a set number of cycles
	initial begin
    	# (NUM_CYCLES * 10);  // 10ns per cycle
    	$finish;
	end

endmodule
