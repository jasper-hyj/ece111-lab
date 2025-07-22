// 2to4 Decoder dataflow level code
module decoder_2to4_dataflow(
 input  logic[1:0] sel,
 output logic[3:0] out
);
 assign out[0] = (!sel[0]) && (!sel[1]);
 // Student to add remainder of the assign statements
  assign out[1] = (!sel[1]) & sel[0];
  assign out[2] =  sel[1] & (!sel[0]);
  assign out[3] =  sel[1] &  sel[0];
endmodule