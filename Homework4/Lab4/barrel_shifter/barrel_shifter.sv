// Barrel Shifter RTL Model
`include "mux_2x1_behavioral.sv"
module barrel_shifter (
  input logic select,  // select=0 shift operation, select=1 rotate operation
  input logic direction, // direction=0 right move, direction=1 left move
  input logic[1:0] shift_value, // number of bits to be shifted (0, 1, 2 or 3)
  input logic[3:0] din,
  output logic[3:0] dout
);

// Students to add code for barrel shifter
  logic [3:0] shift0_in1, shift0;
  logic [3:0] shift1_in1;

  always_comb begin
    for (int i = 0; i < 4; i++) begin
      if (select) begin
        shift0_in1[i] = direction ? din[(i + 3) % 4] : din[(i + 1) % 4];
      end else begin
        if (direction)
          shift0_in1[i] = (i == 0) ? 1'b0 : din[i - 1];
        else
          shift0_in1[i] = (i == 3) ? 1'b0 : din[i + 1];
      end
    end
  end

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : mux_shift0
      mux_2x1 mux1(.sel(shift_value[0]), .in0(din[i]), .in1(shift0_in1[i]), .out(shift0[i]));
    end
  endgenerate

  always_comb begin
    for (int i = 0; i < 4; i++) begin
      if (select) begin
        shift1_in1[i] = direction ? shift0[(i + 2) % 4] : shift0[(i + 2) % 4];
      end else begin
        if (direction)
          shift1_in1[i] = (i <= 1) ? 1'b0 : shift0[i - 2];
        else
          shift1_in1[i] = (i >= 2) ? 1'b0 : shift0[i + 2];
      end
    end
  end

  generate
    for (i = 0; i < 4; i++) begin : mux_shift1
       mux_2x1 mux2(.sel(shift_value[1]), .in0(shift0[i]), .in1(shift1_in1[i]), .out(dout[i]));
    end
  endgenerate

endmodule: barrel_shifter


