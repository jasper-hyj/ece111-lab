// Simple Dual-port Single Clock Block RAM with Synchronous Read 
module dual_port_ram #(
   parameter DATA_WIDTH=32, parameter ADDR_WIDTH=32)
(
   input logic wr_clk, reset,
   input logic wr_en,
   input logic[DATA_WIDTH-1:0] write_data, 
   input logic[ADDR_WIDTH-1:0] write_addr,
 
   input logic rd_en, 
   input logic[ADDR_WIDTH-1:0] read_addr,
   output logic[DATA_WIDTH-1:0] read_data);
 
   // Two dimensional memory array 
   logic[DATA_WIDTH-1:0] mem[2**ADDR_WIDTH-1:0];

   // Synchronous write
   always_ff@(posedge wr_clk, posedge reset) begin 
    if(reset) begin
      for(int i=0; i<(2**ADDR_WIDTH); i++) begin
        mem[i] <= 0;
      end 
    end 
    else begin
      if(wr_en) mem[write_addr]  <= write_data; 
    end
   end  

   // Asynchronous read
   assign read_data = (rd_en == 1) ? mem[read_addr] : 0;
endmodule:dual_port_ram
