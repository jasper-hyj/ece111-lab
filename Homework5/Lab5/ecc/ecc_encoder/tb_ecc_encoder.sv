`timescale 1ns/1ns
module tb_ecc_encoder();
localparam M = 8;  // Input message data width
localparam R = 4;  // Number of parity bits
localparam N = M + R; // Total number of bits for ecc code
logic [M-1:0] data_in;
logic [N:0] data_out;
logic [R-1:0] parity;
logic overall_parity;
logic [N:0] exp_data_out;
logic [N-1:0] ecc_code;

// Instantiate ecc econc0der design module
ecc_encoder #(.M(M), .R(R), .N(N)) DUT(
 .data_in(data_in), 
 .data_out(data_out)
);

// Stimulate Input of ECC Encoder and 
// check for correctness of ecc_out generated from ecc_encoder design module
// Note : Below mentioned stimulus generation only supports 8-bit ECC Encoder
// If Paramenter M and R are changed to any other values then 8 and R, then below
// mentioned stimulus generation code in initial block and function compute_and_compare_ecc_data_out
// would need changes to support different M (data width) and P (Parity width) 
initial begin
 #10;
 data_in = 8'b0000_0000;
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;
 data_in = 8'b1001_1001; 
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;
 data_in = 8'b0001_1101; 
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;
 data_in = 8'b1101_0010; 
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;
 data_in = 8'b0110_0111; 
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;
 data_in = 8'b1100_1000; 
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;
 data_in = 8'b101_1010; 
 #5; 
 compute_and_compare_ecc_data_out(data_in);
 #10;

 // Terminate Simulation
 //$finish();
end


// Self Checker to ensure ecc_code generated from ecc encoder for each incoming input data is correct
// Function to compute expected parity, overall parity and final data with ecc
// Compare expeced output ecc_code with what is generated from ecc_encoder design
function compute_and_compare_ecc_data_out(logic [M-1:0] din);
 begin
  // Compute all 4 parity bits
  parity[0] = din[0] ^ din[1] ^ din[3] ^ din[4] ^ din[6];
  parity[1] = din[0] ^ din[2] ^ din[3] ^ din[5] ^ din[6];
  parity[2] = din[1] ^ din[2] ^ din[3] ^ din[7];
  parity[3] = din[4] ^ din[5] ^ din[6] ^ din[7];
 
  // create data with ecc based on hamming code algorith (7,4)
  ecc_code = {din[7:4], parity[3], din[3], din[2], din[1], parity[2], din[0], parity[1], parity[0]};
 
  // Compute overall parity
  overall_parity = ^ecc_code;
 
  // Compute final data out which includes overall parity in LSB and followed by ecc code
  exp_data_out = {ecc_code, overall_parity};

  // Check and Compare actual data out from design with expected data_out from testbench
  if(data_out !== exp_data_out) begin
    $display("*Test Failed* : data_out generated from design does not match data_out generated from tesbench!");
  end
  else begin
    $display("*Test Passed* : data_out generated from design matches data_out generated from tesbench!");
  end

  // Print debug messges after comparison of actual and expected data out
  $display("  - At time=%0t For Input data_in : %b, Expected data_out from testbench = %b, Actual data_out from design = %b", $time, data_in, exp_data_out, data_out);
  $display("  - At time=%0t Computed From Testbench : data_in = %b, expected parity = %b, expected overall_parity = %b, expected ecc_out = %b", $time, din, parity, overall_parity, exp_data_out);
  $display("\n");
 end
endfunction

endmodule: tb_ecc_encoder

