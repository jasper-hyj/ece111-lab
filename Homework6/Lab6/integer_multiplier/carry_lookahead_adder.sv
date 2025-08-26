//`include "fulladder.sv"
module carry_lookahead_adder#(parameter N=4)(
  input logic[N-1:0] A, B,
  input logic CIN,
  output logic[N:0] result
);

  // Add code for carry lookahead adder
  wire [N-1:0] p = A ^ B;
  wire [N-1:0] g = A & B;

  wire [N:0] c;
  assign c[0] = CIN;
  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : carry_gen
      assign c[i+1] = g[i] | (p[i] & c[i]);
    end
  endgenerate

  wire [N-1:0] fa_cout;
  generate
    for (i = 0; i < N; i = i + 1) begin : fa_loop
      fulladder fa_inst (
        .a   (A[i]),
        .b   (B[i]),
        .cin (c[i]),
        .sum (result[i]),
        .cout(fa_cout[i])
      );
    end
  endgenerate

  assign result[N] = c[N];

endmodule: carry_lookahead_adder

