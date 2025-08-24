module shift_register#(
 parameter integer WIDTH=32, 
 parameter integer NUM_OF_STAGES=2,
 parameter logic[WIDTH-1:0] RESET_VALUE=0) 
(
  input logic clk, reset, 
  input logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);

 logic[WIDTH-1:0] r[NUM_OF_STAGES-1:0];
 always_ff@(posedge clk, posedge reset) begin
  if(reset == 1) begin
    for(int i=0; i<NUM_OF_STAGES; i++) begin
        r[i] <= RESET_VALUE;
    end 
  end
  else begin
    r[0] <= d;
    for(int i=0; i<(NUM_OF_STAGES-1); i++) begin
      r[i+1] <= r[i];
    end
  end
 end
 assign q = (reset==1) ? RESET_VALUE : r[NUM_OF_STAGES-1];
endmodule: shift_register


/*
module two_ff_synchronizer#(parameter WIDTH=2) 
(
  input logic clk, reset, 
  input logic [WIDTH-1:0] d,
  output logic [WIDTH-1:0] q
);

 logic[WIDTH-1:0] temp;
 always_ff@(posedge clk, posedge reset) begin
   if(reset == 1) begin
      temp <= 0;
      q <= 0;
   end
   else begin
     temp <= d;
     q <= temp; 
   end 
 end 
endmodule
*/

