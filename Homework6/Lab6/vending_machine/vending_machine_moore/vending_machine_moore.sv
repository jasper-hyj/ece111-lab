// Vending Machine RTL Code
module vending_machine_moore( 
 input logic clk, rstn,  
 input logic N, D,
 output logic open);
 
 // state variables and state encoding parameters
 parameter[1:0] CENTS_0=2'b00, CENTS_5=2'b01, CENTS_10=2'b10, CENTS_15=2'b11;
 logic[1:0] present_state, next_state; 

 // Sequential Logic for present state
 always_ff@(posedge clk) begin
   // Student to Add Code
   
 end

 // Combination Logic for Next State and Output
 always_comb begin 

  // Student to Add Code

 end
endmodule: vending_machine_moore

