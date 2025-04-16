module ripple_carry_adder #(
	parameter WIDTH = 32
)(
	input  [WIDTH-1:0] A,
	input  [WIDTH-1:0] B,
	input          	Cin,
	output [WIDTH-1:0] Sum,
	output         	Cout
);
	wire [WIDTH:0] carry;
	assign carry[0] = Cin;
    
	genvar i;
	generate
    	for(i = 0; i < WIDTH; i = i + 1) begin : rc
        	assign Sum[i]   = A[i] ^ B[i] ^ carry[i];
        	assign carry[i+1] = (A[i] & B[i]) | (A[i] & carry[i]) | (B[i] & carry[i]);
    	end
	endgenerate
	assign Cout = carry[WIDTH];
endmodule
