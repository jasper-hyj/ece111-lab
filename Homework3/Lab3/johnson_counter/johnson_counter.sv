// Johnson Counter RTL Model
module johnson_counter (
  input logic clk, clear, preset,
  input logic[3:0] load_cnt,
  output logic[3:0] count
);
 always@(posedge clk or negedge clear) begin

  // Student to add code for Johnson Counter  

 end 
endmodule: johnson_counter
