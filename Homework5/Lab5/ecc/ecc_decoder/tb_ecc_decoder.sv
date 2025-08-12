`timescale 1ns/1ns
module tb_ecc_decoder();
localparam M = 8;  // Input message data width
localparam R = 4;  // Number of parity bits
localparam N = M + R; // Total number of bits for ecc code
logic [N:0] data_in;
logic [M-1:0] data_out;
logic [R-1:0] syndrome;
logic overall_parity;
logic [M-1:0] exp_data_out;
logic [N:1] ecc_code, corrected_ecc_code;
logic clk, reset;
logic [1:0] error_code, error_type;

// Instantiate ecc decoder design module
ecc_decoder #(.M(M), .R(R), .N(N)) DUT(
 .clk(clk),
 .reset(reset),
 .data_in(data_in), 
 .data_out(data_out),
 .error_code(error_code)
);

// Stimulate Input of ECC decoder module and check for correctness of message data_out and error_code generated from ecc_decoder design module
// Note : Below mentioned stimulus generation only supports 8-bit ECC decoder
// If Paramenter M and R are changed to any other values then 8 and R, then below
// mentioned stimulus generation code in initial block and function compute_and_compare_message_data_and_error_code
// would need changes to support different M (data width) and P (Parity width) 
// Additionally, data_in bits values driven below within initial block cannot be any random value. It has to be correct
// hamming code (7,4) value.
initial begin
 clk = 1;
 reset = 1;
 data_in = 0;
 @(posedge clk);
 reset = 0;

 // No error scenario
 data_in = 13'b1001010001011; //No bit flip
 // wait for 1 clock cycle to check data_out and error_code since data_out and error_code will be available after 1 cycle from design as they are registered
 @(posedge clk); 
 compute_and_compare_message_data_and_error_code(data_in);

 // Single bit error scenario
 @(posedge clk);
 data_in = 13'b0001111000111; //single bit flip : data_in[3] bit is flipped from 1 to 0
 //data_in = 13'b0001111001111; //data_in without flipping bit
 // wait for 1 clock cycle to check data_out and error_code since data_out and error_code will be available after 1 cycle from design as they are registered
 @(posedge clk);
 compute_and_compare_message_data_and_error_code(data_in);

 // No error scenario
 @(posedge clk);
 data_in = 13'b1101100100111; //No bit flip
 // wait for 1 clock cycle to check data_out and error_code since data_out and error_code will be available after 1 cycle from design as they are registered
 @(posedge clk);
 compute_and_compare_message_data_and_error_code(data_in);

 // Double bit error scenario
 @(posedge clk);
 data_in = 13'b0000001101010; //double bit flip : data_in[11] and data_in[10] bits are flipped from 1 to 0
 //data_in = 13'b0110001101010; //data_in without flipping bits
 // wait for 1 clock cycle to check data_out and error_code since data_out and error_code will be available after 1 cycle from design as they are registered
 @(posedge clk);
 compute_and_compare_message_data_and_error_code(data_in);

 // Overall parity bit error scenario
 @(posedge clk);
 data_in = 13'b1100010000000; //overall parity bit flip : data_in[0] overall parity bit is flipped
 //data_in = 13'b1100010000001; //data_in without flipping overall parity bit
 // wait for 1 clock cycle to check data_out and error_code since data_out and error_code will be available after 1 cycle from design as they are registered
 @(posedge clk);
 compute_and_compare_message_data_and_error_code(data_in);

 // No error scenario
 @(posedge clk);
 data_in = 13'b0101010100000; //No bit flip
 // wait for 1 clock cycle to check data_out and error_code since data_out and error_code will be available after 1 cycle from design as they are registered
 @(posedge clk);
 compute_and_compare_message_data_and_error_code(data_in);

 // Wait for 5 clk cyles
 repeat(5) @(posedge clk);

 // Terminate Simulation
 //$finish();
end

// clk generator logic
always@(clk) begin
 #5ns clk <= !clk;
end


// Self Checker to ensure message data and error code generated from ecc decoder for each incoming input data is correct
// Task to compute overall parity, ecc code, corrected ecc code, error code, message data out
// Compare expeced output data_out and error_code with what is generated from ecc_decoder design
task compute_and_compare_message_data_and_error_code(logic [N:0] din);
 begin
  // Add delay to read signals after 1 ns of rising edge of clock
  #1ns; 

  // Initialized variables
  syndrome = 0;
  error_type = 0;
  ecc_code = 0;
  corrected_ecc_code = 0;
  exp_data_out = 0;

  // Compute overall parity
  overall_parity = ^din;

  // Compute all 4 parity bits
  syndrome[0] = din[1] ^ din[3] ^ din[5] ^ din[7] ^ din[9] ^ din[11];
  syndrome[1] = din[2] ^ din[3] ^ din[6] ^ din[7] ^ din[10] ^ din[11];
  syndrome[2] = din[4] ^ din[5] ^ din[6] ^ din[7] ^ din[12];
  syndrome[3] = din[8] ^ din[9] ^ din[10] ^ din[11] ^ din[12];
 
  // Extract ECC code by ignoring LSB bit in input data. LSB in input data corresponds to overall parity bit
  ecc_code = din[N:1];
  
  // Based on Syndrome value and overall parity generate error code  
  if((syndrome != 0) && (overall_parity == 1)) begin
    error_type = 2'b01; // single bit error
  end
  else if((syndrome != 0) && (overall_parity == 0)) begin
    error_type = 2'b10; // double bit error
  end
  else if((syndrome == 0) && (overall_parity == 1)) begin
    error_type = 2'b11; // overall parity bit error
  end
  else begin
    error_type = 2'b00; // no error
  end

  // Generate corrected ecc code
  corrected_ecc_code = generate_corrected_ecc_code(ecc_code, syndrome, error_type);
  
  // Extract data from corrected ecc code to get message data
  exp_data_out = {corrected_ecc_code[12:9], corrected_ecc_code[7], corrected_ecc_code[6], corrected_ecc_code[5], corrected_ecc_code[3]};
  
  // Check and Compare actual data out and error code from design with expected data_out and expected error type from testbench
  if((data_out !== exp_data_out) || (error_code !== error_type)) begin
    $display("*Test Failed* : Either data_out or error_code generated from design does not match with data_out and error_code andgenerated from tesbench!");
  end
  else begin
    $display("*Test Passed* : Both data_out and error_code generated from design matches data_out and error_code generated from tesbench!");
  end

  // Print debug messges after comparison of actual and expected data out and error code
  $display("  - At time=%0t Computed From design for input data_in : %b, Expected data_out from testbench = %b, Actual data_out from design = %b", $time, data_in, exp_data_out, data_out);
  $display("  - At time=%0t Computed From design for input data_in : %b, Expected error_code from testbench = %b, Actual error_code from design = %b, syndrome = %b, overall_parity = %b", $time, data_in, error_type, error_code, syndrome, overall_parity);
  $display("\n");
 end
endtask


// Function to generate corrected ecc code word
function logic[N:1] generate_corrected_ecc_code(logic[N:1] ecc_code_word, logic[M-1:0] syn, logic[1:0] err_type);
 begin
    //  Declare and initialize variables
    generate_corrected_ecc_code = ecc_code_word;
    
    // Generate corrected ecc code word in case of single bit bit error
    // In case of no error, double bit error and overall parity bit error do not correct the data as data does not need correction
    if(err_type == 2'b01) begin 
      // Flip bit in ecc code based on syndrome value
      generate_corrected_ecc_code[syn] = ~generate_corrected_ecc_code[syn];
    end
    else begin
      // Do not flip bit
      generate_corrected_ecc_code = ecc_code_word;
    end
 end
endfunction

endmodule: tb_ecc_decoder

