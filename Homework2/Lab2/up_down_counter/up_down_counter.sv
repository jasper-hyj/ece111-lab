// 4-bit up and down counter RTL code
module up_down_counter    // Module start declaration
 // Parameter declaration, count signal width set to '4'  
 #(parameter WIDTH=4)  
 ( 
    input logic clk,
    input logic clear, 
    input logic select,
    output logic[WIDTH-1:0] count_value
 );

 // Local variable declaration
 logic[WIDTH-1:0] up_count_value, down_count_value; 
  
 // Student to add code to instantiate up counter

 


 // Student to add code to instantiate down counter




 // Student to add acode to instantiate 2-to-1 multiplexer




endmodule: up_down_counter  // Module end declaration