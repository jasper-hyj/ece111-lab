// Reduced State Vending Machine FSM RTL Code
module vending_machine_moore_reduced_state( 
 input logic clk, rstn,  
 input logic N, D,
 output logic open);
 
  parameter[2:0] S1=3'b000, S2=3'b001, S3=3'b010, S4=3'b011, S5=3'b100;
  logic[2:0] present_state, next_state; 

  always_ff@(posedge clk) begin
    if(!rstn) begin
      present_state <= S1;
    end else begin
      present_state <= next_state;
    end
  end

  always_comb begin
    next_state = present_state; 
    open = 0;

    case (present_state)
      S1: begin
        if (N) next_state = S3;
        else if (D) next_state = S2;
        else next_state = S1;
      end
      S2: begin
        if (N) next_state = S4;
        else if (D) next_state = S5;
        else next_state = S2;
      end
      S3: begin
        if (N) next_state = S2;
        else if (D) next_state = S4;
        else next_state = S3;
      end
      S4: begin
        next_state = S1;
        open = 1;
      end
      S5: begin
        next_state = S3;
        open = 1;
      end
      default: begin
        next_state = S1;
      end
    endcase
  end
endmodule: vending_machine_moore_reduced_state

