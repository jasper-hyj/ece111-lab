`include "dual_port_ram.sv"
`include "shift_register.sv"
module async_fifo#(
  parameter DATA_WIDTH = 32,   // width of each data element in FIFO Memory
  parameter FIFO_DEPTH = 16)   // Number of locations in FIFO Memory
(
  input  logic wr_clk, rd_clk, // Write and Read Clocks
  input  logic reset, // Common reset             
  input  logic wr_en, // write enable, if wr_en == 1, data gets written to FIFO Memory
  input  logic rd_en, // read_enable, if rd_en == 1, data gets read out from FIFO Memory
  input  logic [DATA_WIDTH-1:0] data_in,  // Input data to be written to FIFO Memory
  output logic [DATA_WIDTH-1:0] data_out, // Data read out from FIFO Memory
  output logic fifo_full, // Indicates FIFO is full and there are no locations inside FIFO memory for further writes
  output logic fifo_empty, // Indicates FIFO is empty and there are no data available inside FIFO memory for reading
  output logic fifo_almost_full, // One cycle early indication of FIFO_FULL (fifo is not full yet, it will be next cycle)
  output logic fifo_almost_empty // One cycle early indication of FIFO_EMPTY (fifo is not empty yet, it will be next cycle)
);

 // Local parameter to set address width based on FIFO DEPTH
 localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
  
 // Internal register declaration
 // Note: 
 // wr_ptr is binary counting write address pointer
 // wr_ptr_gray is a gray counting write address pointer convrted from wr_ptr binary counting write address pointer
 // wr_ptr_gray2 is output of 2-FF synchronizer (which is output of 2 stage shift register). Input to this synchronizer is wr_ptr_gray
 // wr_ptr_binary2 is binary countng write address pointer generated after converting from wr_ptr_gray2 gray counting write address pointer
 // rd_ptr is binary counting read address pointer
 // rd_ptr_gray is a gray counting read address pointer convrted from wr_ptr binary counting read address pointer
 // rd_ptr_gray2 is output of 2-FF synchronizer (which is output of 2 stage shift register). Input to this synchronizer is rd_ptr_gray
 // rd_ptr_binary2 is binary countng read address pointer generated after converting from rd_ptr_gray2 gray counting read address pointer
 logic [ADDR_WIDTH:0] wr_ptr, wr_ptr_gray, wr_ptr_gray2, wr_ptr_binary2;
 logic [ADDR_WIDTH:0] rd_ptr, rd_ptr_gray, rd_ptr_gray2, rd_ptr_binary2;
 logic t_fifo_empty, t_fifo_full;
 

 // Step-1 : Increment write pointer each time wr_en is '1' (binary counter)
 // If reset == 1 then assign 0 to wr_ptr
 always_ff@(posedge wr_clk,posedge reset) begin
   // Student to add code

 end
 

 // Step-2 : Convert write pointer to gray value from binary write pointer value before 
 // sending write pointer to rd_clk domain through 2-FlipFlip synchronizer
 // use binary_to_gray function
 assign wr_ptr_gray =  // Student to add code
 
  
 // Step-3 : Increment read pointer each time rd_en is '1' (binary counter)
 // If reset == 1then assign 0 to rd_ptr
 always_ff@(posedge rd_clk,posedge reset) begin
     // Student to add code


 end
 

 // Step-4 : Convert read pointer to gray value from binary read pointer value before
 // sending read pointer to wr_clk domain through 2-FlipFlip synchronizer
 // use binary_to_gray function
 assign rd_ptr_gray =  // Student to add code
 

 // Step-5 : Geneate fifo empty flag
 // The FIFO is empty when both read and write pointers point to the same location
 assign t_fifo_empty =  // Student to add code


 // Step-6 : Assert output signal fifo_almost_empty
 // FIFO Almost empty is generated simulataneously when the very last data available in fifo is read
 // hence it is named as fifo almost empty. In another words, one cycle before fifo is actually empty
 assign fifo_almost_empty =  // Student to add code
 
 
 // Step-7 : Generate fifo full flag 
 // FIFO is full when wr_ptr - rd_ptr = 2^address_width.  
 // In that case, the Lower address bits are identical, but the MSB address bit is different.
 assign t_fifo_full  =   // Student to add code
   

 // Step-8 : Assert almost full flag 
 // FIFO Almost full is generated simulataneously when the very last location in fifo is written with data
 // hence it is named as fifo almost full. In another words, one cycle before the fifo is actually full
 assign fifo_almost_full =  // Student to add code
	

 // Step-9 : Instantiate FIFO Memory (Upon synthesis this will result in dual port distributed RAM since read from memory is asynchronous)
 // Note : when connecting below wr_en and rd_end remember to do logical-and with !fifo_full and !fifo_empty respectively
 // if !fifo_full anding with wr_en is added, to prevent writing of datain to dual_port_ram (fifo memory) when fifo is full.
 // if !fifo_empty anding with rd_en is added, to prevent reading of data from dual_port_ram (fifo memory) when fifo is empty.
 //.wr_en(wr_en && !fifo_full),
 //.rd_en(rd_en && !fifo_empty),
 // dual port ram is synchronous write and asynchronous read. It can perform simultaneous write and read operations.
 // Simulatneous write and read memory is required, since data can be pushed (write) into FIFO and POPPED (read) out of FIFO at same time
 dual_port_ram #(
   .DATA_WIDTH(DATA_WIDTH),
   .ADDR_WIDTH(ADDR_WIDTH)) 
 fifo_memory_inst(
     // Student to add code


 );
 
 
 // Step-10 : Synchronize wr_ptr to rd_clk domain
 // This is done to synchronize wr_ptr to rd_clk domain, and in rd_clk domain, output of this synchronizer will be used to 
 // compute fifo empty flag. 
 shift_register #(
  .WIDTH(ADDR_WIDTH), 
  .NUM_OF_STAGES(2)) 
 wr_ptr_synchronizer_inst(
  .clk(rd_clk),
  .reset(reset),
  .d(wr_ptr_gray),
  .q(wr_ptr_gray2)
 );
 
 
 // Step-11 : Convert synchronized write pointer gray value available from Step-10, back to binary value
 // Prior to generation for fifo empty flag, synchronized gray write pointer value is converted first to binary write pointer value
 // use gray_to_binary function
 assign wr_ptr_binary2 =  // Student to add code
 

 // Step-12 : Synchronize rd_ptr to wr_clk domain
 // Instantiate shift register to perform 2 stage FlipFlop synchronization (also known as 2-FF synchronizer)
 // This is done to synchronize rd_ptr to wr_clk domain, and in wr_clk domain, output of this synchronizer will be used to 
 // compute fifo full flag. 
 shift_register #(
  
  // Student to add code here similar to wr_ptr to rd_clk domain synchronizatio add code here for rd_ptr to wr_clk synchronization
  // Note : This is a 2 Flip flip stage synchronization. So NUM_OF_STAGES parameter for shift register should be 2
  // Remember to connect clk of shift register to "wr_clk", since rd_ptr_gray is sent to wr_clk domain through this synchronizer

 );
 

 // Step-13 : Convert synchronized read pointer gray value available from Step-12, back to binary value
 // Prior to generation for fifo full flag, synchronized gray read pointer value is converted first to binary read pointer value
 //  use gray to binary function
 assign rd_ptr_binary2 =  // Student to add code
 

 // Step-14 : Delay fifo almost empty (t_fifo_empty) by 1 clock cycle to generate fifo_empty output signal
 // This is done to generate fifo_empty output signal after the last available data in FIFO is read out
 shift_register #(
  .WIDTH(1), 
  .NUM_OF_STAGES(1),   // Note : Here 2-FF synchronizer is not the intent. Only 1 cycle delayed version of t_fifo_empty is created. Hence NUM_OF_STAGES is '1' 
  .RESET_VALUE(1))  // Note : RESET_VALUE is set to '1', since by default out of reset, FIFO is in empty state.
 fifo_empty_inst(
  .clk(rd_clk),
  .reset(reset),
  .d(t_fifo_empty),
  .q(fifo_empty)
 );
 
 // Step-15 : Delay fifo almost full (t_fifo_full) by 1 clock cycle to generate fifo_full output signal
 // This is done to generate fifo_full output signal after the last available location in FIFO is written with a data
 // Note : Here 2-FF synchronizer is not the intent. Only 1 cycle delayed version of t_fifo_full is created. Hence NUM_OF_STAGES should be set to '1'
 // RESET_VALUE should be set to '0', since by default out of reset, FIFO is not in full state.
 shift_register #(
    // Student to add code here. Similar to fifo_empty code above, add code for fifo_full 

 );
 
 // finction to convert binary to gray function
 function automatic [ADDR_WIDTH:0] binary_to_gray(logic [ADDR_WIDTH:0] value);
   begin 
     binary_to_gray[ADDR_WIDTH] = value[ADDR_WIDTH];
     for(int i=ADDR_WIDTH; i>0; i = i - 1)
       binary_to_gray[i-1] = value[i] ^ value[i - 1];
    end
 endfunction

 // function to convert gray to binary  
 function logic[ADDR_WIDTH:0] gray_to_binary(logic[ADDR_WIDTH:0] value);
  begin 
     logic[ADDR_WIDTH:0] l_binary_value;
     l_binary_value[ADDR_WIDTH] = value[ADDR_WIDTH];
     for(int i=ADDR_WIDTH; i>0; i = i - 1) begin
      l_binary_value[i-1] = value[i-1] ^ l_binary_value[i];
     end
     gray_to_binary = l_binary_value;
  end
 endfunction
 
endmodule:async_fifo



