`timescale 1ns/1ps
module sync_fifo_testbench();
parameter DATA_WIDTH=32;
parameter FIFO_DEPTH=8; 
parameter NUM_OF_ITR=4;
parameter NUM_OF_PACKETS=8;
logic wr_clock, rd_clock, wr_en, rd_en, reset;
logic [DATA_WIDTH-1:0] data_in;  //data to be written
logic [DATA_WIDTH-1:0] data_out; //read data from memory
logic fifo_full, fifo_empty;
logic fifo_almost_full, fifo_almost_empty;
logic [DATA_WIDTH-1:0] write_data[$];
logic [DATA_WIDTH-1:0] read_data[$];
logic [DATA_WIDTH-1:0] datain;
logic [DATA_WIDTH-1:0] dataout;
integer wdata_size, rdata_size;

// Instantiate async fifo design module
sync_fifo#(.DATA_WIDTH(DATA_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) design_instance(
 .clk(wr_clock),
 .reset(reset),
 .wr_en(wr_en),
 .rd_en(rd_en),
 .data_in(data_in),
 .data_out(data_out),
 .fifo_full(fifo_full),
 .fifo_empty(fifo_empty)
);
 
// wr_clock generator
always #10 wr_clock = ~wr_clock;

// rd_clock generator
always #10 rd_clock = ~rd_clock;

//Stimulus
initial begin
 // Initiliase Input Stimulus
 data_in = 0;
 wr_clock = 0;
 wr_en = 0;
 rd_clock = 0;
 rd_en = 0;

 // apply reset sequence
 reset = 1;
 #50;
 reset = 0;
 #50;

 for(int itr=0; itr<NUM_OF_ITR; itr++) begin
  // push data into fifo 
  @(posedge wr_clock);
  for(int i=0; i<NUM_OF_PACKETS; i++) begin
   if(fifo_full != 1) begin
    wr_en = 1;
    rd_en = 0;
    data_in = $urandom_range(1, 64); 
   end
   @(posedge wr_clock);
  end 

  // No write and No read to to FIFO
  wr_en = 0;
  rd_en = 0;
  //@(posedge wr_clock);

  // pop data from fifo
  @(posedge rd_clock);
  for(int i=0; i<NUM_OF_PACKETS; i++) begin
   if(fifo_empty != 1) begin
    wr_en = 0;
    rd_en = 1;
   end   
   @(posedge rd_clock);
  end 

  // No write and No read to to FIFO
  //@(posedge rd_clock);
  wr_en = 0;
  rd_en = 0;
  //@(posedge rd_clock);
 end
 
 // wait for 1 clock cycle
 @(posedge rd_clock);

 // Finally perform one push data followed by pop
 wait (fifo_full == 0);
 @(posedge wr_clock);
 wr_en = 1;
 rd_en = 0;
 data_in = $urandom_range(1, 64); 
 @(posedge wr_clock); 
 wr_en = 0;
 rd_en = 0;
 wait (fifo_empty == 0); 
 @(posedge rd_clock); 
 wr_en = 0;
 rd_en = 1;
 @(posedge rd_clock);
 wr_en = 0;
 rd_en = 0;
 @(posedge rd_clock);

 // Get and print number of entries in write and data queues
 wdata_size = write_data.size();
 rdata_size = read_data.size();
 $display("wdata_size= %0d,  rdata_size=%0d\n", wdata_size, rdata_size);
 #100ns;
 
 // Since read data available is 1 cycle after rd_en=1, remove first entry in read data queue
 //dataout = read_data.pop_front();

 // Compare data entered into fifo with data exiting the fifo one by one at a time
 for(integer i=0; i<(rdata_size); i++) begin
 //for(integer i=0; i<(NUM_OF_PACKETS * NUM_OF_ITR); i++) begin
  datain =  write_data.pop_front();
  dataout = read_data.pop_front();
  $display("index i=%0d\n", i);
  if(dataout === datain) begin
    $display("datain= %0d,  dataout=%0d data checking passed\n", datain, dataout);
  end else begin
   $display("datain= %0d,  dataout=%0d data checking failed\n", datain, dataout);
  end
 end

 // Wait for sometime before exiting the test
 #100ns;

 // print final exit statement
 $display("FIFO test completed!\n");
end

// Caputre data pushed into fifo in a write data queue for later comparison
always@(posedge wr_clock) begin
 if(!reset) begin
  if(wr_en == 1) begin
    write_data.push_back(data_in);
  end
 end
end

// Capture data poped from fifo in a read data queue for later comparison
always@(posedge rd_clock) begin
 if(!reset) begin
  if(rd_en == 1) begin
    read_data.push_back(data_out);
  end
 end
end
endmodule
