//RTL Model for Linear Feedback Shift Register
module lfsr
#(parameter N = 4) // Number of bits for LFSR
(
  input logic clk, reset, load_seed,
  input logic[N-1:0] seed_data,
  output logic lfsr_done,
  output logic[N-1:0] lfsr_data
);

//student to add implementation for LFSR code 
// Internal shift register
  logic [N-1:0] lfsr_reg, lfsr_next, taps;
  logic [$clog2((1 << N)) - 1:0] count;
  logic xor_out, cycle_done;

  always_comb begin
    case (N)
      2: taps = 2'b11;
      3: taps = 3'b110;
      4: taps = 4'b1100;
      5: taps = 5'b10100;
      6: taps = 6'b110000;
      7: taps = 7'b1100000;
      8: taps = 8'b10111000;
      default: taps = '0;
    endcase
  end

  always_comb begin
    xor_out = ^(lfsr_reg & taps);
    lfsr_next = {lfsr_reg[N-2:0], xor_out};
  end

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      lfsr_reg <= 0;
      count <= 0;
    end else if (load_seed) begin
      lfsr_reg <= seed_data;
      count <= 1;
    end else begin
      lfsr_reg <= lfsr_next;
      if (count != 0)
        count <= count + 1;
    end
  end
  assign cycle_done = (count == (2**N - 1));
  assign lfsr_done = cycle_done;

  assign lfsr_data = lfsr_reg;

endmodule: lfsr