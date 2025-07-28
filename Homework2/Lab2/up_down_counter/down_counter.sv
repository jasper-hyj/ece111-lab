// 4-bit counter RTL code
module down_counter    // Module start declaration
 // Parameter declaration, count signal width set to '4'  
 #(parameter WIDTH=4)  
 ( 
    input logic clk,
    input logic clear, 
    output logic[WIDTH-1:0] count
 );

 // Student to add code for down counter logic
 logic[WIDTH-1:0] cnt_value; 

 always @(posedge clk or posedge clear) 
   begin
     if (clear == 1)
       cnt_value = 'b1111;
     else 
       cnt_value = cnt_value - 1;
   end

 // Counter value assigned to output port count  
 assign count = cnt_value;
 
endmodule: down_counter  // Module end declaration