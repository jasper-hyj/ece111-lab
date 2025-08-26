// Vending Machine RTL Code
module vending_machine_mealy( 
 input logic clk, rstn,  
 input logic N, D,
 output logic open);
 
 // State encoding and state variables
 parameter[1:0] CENTS_0=2'b00, CENTS_5=2'b01, CENTS_10=2'b10, CENTS_15=2'b11;
 logic[1:0] present_state, next_state; 

 // Local Variables for registering inputs N and D
 logic r_N, r_D;

 // Note : output open is not registered (i.e. no flipflop at output port open) in this example for students to compare moore and mealy machine waveform and see what is the different between mealy and moore
 // remember we learnt in class that mealy reacts immediately to change in input !!
 // Add flipflop for each input 'N' and 'D'
 // Sequential Logic for present state
 always_ff@(posedge clk) begin
  if(!rstn) begin
    // Student to Add Code 
    present_state <= CENTS_0;
    r_N <= 0;
    r_D <= 0;
  end 
  else begin
    // Student to Add Code 
    present_state <= next_state;
    r_N <= N;
    r_D <= D;
  end
 end


  // Combination Logic for Next State and Output
  always_comb begin 
  // Student to Add Code
    next_state = present_state;
    open = 0;
    case (present_state)
      CENTS_0: begin
        if (r_N) next_state = CENTS_5;
        else if (r_D) next_state = CENTS_10;
      end

      CENTS_5: begin
        if (r_N) next_state = CENTS_10;
        else if (r_D) begin
          next_state = CENTS_0;
          open = 1;
        end
      end

      CENTS_10: begin
        if (r_N || r_D) begin
          next_state = CENTS_0;
          open = 1;
        end
      end
      
      default: begin
        next_state = present_state;
        open = 0;
      end
    endcase
  end
endmodule: vending_machine_mealy
