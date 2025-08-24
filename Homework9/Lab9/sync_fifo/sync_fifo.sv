`include "dual_port_ram.sv"
module sync_fifo#(
  parameter DATA_WIDTH = 32,
  parameter FIFO_DEPTH = 16)
(
  input  logic clk,
  input  logic reset,
  input  logic wr_en,
  input  logic rd_en,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic fifo_full,
  output logic fifo_empty
);

 // Local parameter to set address width based on FIFO DEPTH
 localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
  
 // internal register declaration
 logic [ADDR_WIDTH:0]  wr_ptr;
 logic [ADDR_WIDTH:0]  rd_ptr;

 // Increment write pointer each time wr_en is '1'
 always_ff@(posedge clk,posedge reset) begin
   if(reset) begin
     wr_ptr <= 0;
   end
   else begin
    if(wr_en && !fifo_full) begin
      wr_ptr <= wr_ptr + 1;
	 end
   end
 end
 
 
 // Increment read pointer each time rd_en is '1'
 always_ff@(posedge clk,posedge reset) begin
   if(reset) begin
     rd_ptr <= 0;
   end
   else begin
    if(rd_en && !fifo_empty) begin
     rd_ptr <= rd_ptr + 1;
	 end
   end
 end
 
  // The FIFO is empty when both read and write pointers point to the same location
  assign fifo_empty =  (wr_ptr == rd_ptr) ? 1 : 0;
 
  // Fifo is full when wr_ptr - rd_ptr = 2^address_width.  
  // In that case, the Lower address bits are identical, but the MSB address bit is different.
  assign fifo_full  =  ((wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH])
				&& (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0])) ? 1 : 0;
 
 // Instantiate FIFO Memory
 dual_port_ram #(
   .DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH)) 
 fifo_memory(
  .write_addr(wr_ptr),
  .read_addr(rd_ptr),
  .write_data(data_in),
  .read_data(data_out),
  .wr_en(wr_en && !fifo_full),
  .rd_en(rd_en && !fifo_empty),
  .wr_clk(clk),
  .reset(reset)
 );
endmodule:sync_fifo



