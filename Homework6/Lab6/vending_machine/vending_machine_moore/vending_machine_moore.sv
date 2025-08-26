// Vending Machine RTL Code
module vending_machine_moore( 
  input logic clk, rstn,  
  input logic N, D,
  output logic open);

  // state variables and state encoding parameters
  parameter[3:0] CENTS_0=4'b0001, CENTS_5=4'b0010, CENTS_10=4'b0100, CENTS_15=4'b1000;
  logic[3:0] present_state, next_state; 

  // Sequential Logic for present state
  always_ff@(posedge clk) begin
    // Student to Add Code
    if(!rstn) begin
      present_state <= CENTS_0;
    end else begin
      present_state <= next_state;
    end
  end

  // Combination Logic for Next State and Output
  always_comb begin 
    // Student to Add Code
    next_state = present_state; 
    open = 0;

    case (present_state)
      CENTS_0: begin
        if (N) next_state = CENTS_5;
        else if (D) next_state = CENTS_10;
      end
      CENTS_5: begin
        if (N) next_state = CENTS_10;
        else if (D) next_state = CENTS_15;
      end
      CENTS_10: begin
        if (N || D) next_state = CENTS_15;
      end
      CENTS_15: begin
        open = 1;
        if (rstn == 0) begin
          next_state = CENTS_0;
        end else begin
          next_state = CENTS_15;
        end
      end
      default: begin
        next_state = CENTS_0;
      end
    endcase
  end
endmodule: vending_machine_moore

