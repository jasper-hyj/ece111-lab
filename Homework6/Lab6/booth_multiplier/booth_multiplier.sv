`timescale 1ns/1ps
//`include "carry_lookahead_adder.sv"

module booth_multiplier // Module start declaration
#(parameter N=4) // Parameter declaration
(
  input clock, reset, start,
  input logic signed [N-1:0] multiplicand, multiplier,
  output logic signed [(2*N)-1:0] product,
  output logic done
);

//Variable to store 2's complement of Multiplicand
logic [N-1:0] multiplicand_neg;

// Count variable for ADD/SHIFT stages
logic [$clog2(N)-1:0] count;

// Register to store Adder sum and multipiler
logic signed [(2*N):0] shift_reg;

// Register to load multiplicand value
logic signed [N-1:0] load_reg_pos;
logic signed [N-1:0] load_reg_neg;

// wires to connect with carry lookahead adder
logic[N-1:0] add_operand1, add_operand2;
logic[N-1:0] sum;
logic cla_carry = 0;

// next_state encoding and next_state variable
enum logic[2:0]{
        IDLE             = 3'b000,
        INITIALIZE       = 3'b001,
        TEST             = 3'b010,
        ADD              = 3'b011,
        SHIFT_AND_COUNT  = 3'b100,
        DONE             = 3'b101
} next_state;

// Instantiate (N)-bit carry lookahead adder 
carry_lookahead_adder #(.N(N)) adder_inst(
	// Student to add code
	.A(add_operand1),
  .B(add_operand2),
  .CIN(cla_carry),
  .result(sum)
);

// Create negative multiplicand value in 2's complement form
assign multiplicand_neg = -multiplicand;

always_ff@(posedge clock, posedge reset) begin
  if(reset) begin
    count <= 0;
    next_state <= IDLE;
    load_reg_pos <= 0;
    load_reg_neg <= 0;
    shift_reg <= 0;
  end
  else begin
    case(next_state)
    // Wait for start signal
    IDLE: begin
      // Student to add code
      if (start) begin
        next_state <= INITIALIZE;
      end else begin
        next_state <= IDLE;
      end
      shift_reg <= 0;
    end

    // Load Multiplicand and Multiplier in a load register and a shift register
    INITIALIZE: begin
      // load multiplicand to load_reg_pos
      // Student to Add Code Here
      load_reg_pos <= multiplicand;

      // load multiplicand_neg[N:0] to load_reg_neg
      // Student to Add Code Here
      load_reg_neg <= multiplicand_neg[N-1:0];

      shift_reg 	<= {{N{1'b0}}, multiplier, 1'b0};
      next_state 	<= TEST;
      count <= 0;	
    end

    // Check shift register LSB and based on that perform ADD/Shift operation
    // if last 2 LSB='01' then perform ADD with positive multiplicand followed by Airthmetic Right Shift by 1
    // if last 2 LSB='10' then perform ADD with negative multiplicand followed by Airthmetic Right Shift by 1
    // if last 2 LSB='00' then perform Right Shift by 1
    // if last 2 LSB='11' then perform Right Shift by 1
	  TEST: begin
      if(shift_reg[1:0] == 2'b01) begin
        // Pass positive Multiplicand to carry lookadahead adder input
        // Pass previous adder output value after shift to add with Multiplicand
        // move to add state
        // Student to add code here
        add_operand1 <= multiplicand;
        add_operand2 <= shift_reg[(2*N):(N+1)];
        next_state <= ADD;
		  end
      else if(shift_reg[1:0] == 2'b10) begin
        // Pass negative Multiplicand to carry lookadahead adder input
        // Pass previous adder output value after shift to add with Multiplicand
        // move to add state

        // Student to Add code here
        add_operand1 <= multiplicand_neg;
        add_operand2 <= shift_reg[(2*N):(N+1)];
        next_state <= ADD;

      end
      else begin
        // assign add_operand1 to 0, Since no add operation to be perform pass 0 to carry lookadder input
        // Pass previous adder output value after shift to add with Multiplicand	
        // move to shift and increment count state

        // Student to Add code
        add_operand1 <= 0;
        add_operand2 <= shift_reg[(2*N):(N+1)];
        next_state <= SHIFT_AND_COUNT;
      end
    end

    ADD: begin
      shift_reg <= {sum, shift_reg[N:0]}; // Load shift register : Output sum from Adder which includes carry and retain previous lower bit of shift register
      // Move to shift and increment count state
      // Studen to add code here
      next_state <= SHIFT_AND_COUNT;
    end

    SHIFT_AND_COUNT: begin
      shift_reg <= (shift_reg >>> 1); // Right Arithmetic shift entire shift register by 1 position
              
      // Increment count
      // Student to Add code here
      count <= count + 1;

      if (count == N-1) begin // If 'N' times SHIFT operation performed then move to Done state else go back to Test state
        // Student to Add code here
        next_state <= DONE;
      end
      else begin
        // Student to Add code here
        next_state <= TEST;
      end
    end

    DONE: begin
      next_state <= IDLE; // Wait for right shift value to be available. THis is the final product value.
    end
    endcase
  end
end

// Generate done=1 when FSM reaches DONE state
assign done = (next_state == DONE) ? 1 : 0;

// Generate Product in DONE state by loading shift_reg value to it
always_comb begin
 if(next_state == DONE) begin
    // In cases when multiplicand and multiplier both having their MSB bit's as 1, the final product value after all steps of booth multiplier algorithm are completed, 
    // and if the MSB bit of shift register is '1 which indicates negative result then 2's complement should be performed before generating final product value. 
    // Not doing so, will result in final product value generated with incorrect sign.
    // Example : in 4-bit binary system, -8 x -7 = 8'b1100_1000 which is -56. After performing 2's complement it will result in 8'b0011_1000 which is +56. 
    // And positive 56 is the correct product value for -8 x -7
    if((shift_reg[(2*N)] == 1) && (multiplier[N-1] == 1) && (multiplicand[N-1] == 1)) begin
      // perform 2's complement of shift register before assigning to output product
	  product = -shift_reg[(2*N):1];
    end
	// In cases when multiplicand has boundary condition negative value such as -8 in 4-bit binary system and multiplier has positive value, 
	// final product value will be generated with incorrect sign. To address this 2's complement should be performed before generating final product value.
    // Example : -8 x 6 = 8'b0011_0000 which is +48. After performing 2's complement it will result in 8'b1101_0000 which is -48. 
	// And negative 48 is the correct product value for -8 x 6.
    else if((shift_reg[(2*N)] == 0) && (multiplier[N-1] == 0) && (multiplicand[N-1] == 1)) begin
      // perform 2's complement of shift register before assigning to product
	  product = -shift_reg[(2*N):1];
    end
	// For all other cases simply assign upper N bits of shift register to product output
    else begin
      product = shift_reg[(2*N):1];
    end
 end
 else begin
    product = 0;
 end
end

endmodule: booth_multiplier

