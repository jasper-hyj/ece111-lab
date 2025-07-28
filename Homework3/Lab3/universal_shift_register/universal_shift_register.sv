// RTL model of Universal Shift Register
module universal_shift_register (
  input logic clk, reset, load, sin, 
  input logic [2:0] shift_mode,
  input logic [3:0] din,
  output logic [3:0] dout,
  output logic sout
);

 // local variable for 4-bit shift register
 logic[3:0] shift_reg; 
 
 // Sequential Logic to generate Universal Shift Register to support all shift modes
 always@(posedge clk, posedge reset) 
 begin
   if(reset == 1) begin
      sout <= 1'b0;
   end
   else if(load == 1) begin
      shift_reg <= din;  // Load parallel 4-bit input din value to 4-bit shift_reg when load is '1'
   end
   else begin
     case(shift_mode)
       // PIPO Mode of Shift Register
       3'b000 : begin 
                  shift_reg <= din;  
		  sout <= 1'b0;
                end

       // student to fill code for SIPO-L, SIPO-R, PISO-L, PISO-R, SISO-L, SISO-R operation mode of shift register
       // Note : Use non-blocking assignment statements within case item expressions


       default : begin 
                   shift_reg <= 4'b0000;
                   sout <= 1'b0;
                 end
     endcase
   end
 end
 
 // Combinational Logic to generate output dout
 // Note : In this combinational always block only blocking assignment statements used
 always@(shift_mode, load, reset, shift_reg) 
 begin
    if((load == 1) || (reset == 1)) begin
      dout = 4'b000;
    end
    else begin
      case(shift_mode)
	3'b000  : dout = shift_reg;  // PIPO mode parallel out is generated on dout output port
	3'b001  : dout = shift_reg;  // SIPO-L mode parallel out is generated on dout output port
	3'b010  : dout = shift_reg;  // SIPO-R mode parallel out is generated on dout output port
        default : dout = 4'b0000;  // In all other mode such as PISO-L, PISO-R, SISO-L, SISO-R output is generated on serial output port sout, hence dout parallel out is set to 0 in these modes.
      endcase
    end
 end
  
endmodule


