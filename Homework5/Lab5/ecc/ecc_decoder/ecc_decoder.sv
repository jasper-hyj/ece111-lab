module ecc_decoder 
#(parameter M = 8, // Input message data width
  parameter R = 4, // Number of parity bits
  parameter N = M + R // Total number of bits for ecc code// Local Variables
)(
  input  logic clk, reset, // Clock and Reset Ports
  input  logic [N:0] data_in,    // Input data which includes ecc_code and overall parity in LSB
  output logic [M-1:0] data_out, // output data after removing ecc code, overall parity and after data correction
  output logic [1:0] error_code  // Indicates single bit error, double bit error or overall parity error
);

  logic [R:1] binary_value[N+1]; // To get binary value pattern required for each parity bit generation
  logic [N:1] ecc_code;   // to store data with computed parity in hamming code format
  logic [R-1:0] syndrome; 
  logic overall_parity;   // Overall parity generated from input data
  logic [N:1] corrected_ecc_code; // data after correction in case of single bit error
  logic [M-1:0] message_data;  // data without correction and extracted from input data
  logic [1:0] error_type;

  // Generate overall parity and syndrome value from incoming data
  // Based on overall parity and syndrome value generate error code
  // In case of single bit or double bit error correct the message code.
  always_comb begin
    // Re-compute overall parity of incoming data_in
	// Remember to discard LSB bit in incoming data_in[0] to re-compute overall parity
    assign // student to complete this code
    
  
    // Remove LSB bit from incoming data to generate ecc code word
    // LSB bit in incoming data represents overall_parity sent by the ecc_encoder
    ecc_code = // studnet to complete this code
  
    // Generate Syndrome
    syndrome = generate_syndrome(ecc_code); 
    
    // Generate error type and final data out based on syndrome and overall parity check
	// use if else-if statements to generate error_type (i.e. error code)
	// This error_type value indicates if its single bit error, double bit error, overall parity bit error
	// See below definition of error_type (i.e. error_code) which needs to be implemented
	// single bit error : if syndrome!=0 and overall_parity re-computed != incoming overall parity data_in[0] then error_type = 2'b01
	// No error : if syndrome==0 and overall_parity re-computed == incoming overall parity data_in[0] then error_type = 2'b00
	// overall parity bit error : if syndrome==0 and overall_parity re-computed != incoming overall parity data_in[0] then error_type = 2'b11
	// double bit error : if syndrome!=0 and overall_parity re-computed == incoming overall parity data_in[0] then error_type = 2'b10
    if(<student to add code here>) begin
      //student to add code here  // single bit error
    end
    else if(<student to add code here>) begin
     //student to add code here  // single bit error// double bit error
    end
    else if(<student to add code here>) begin
     //student to add code here  // single bit error // overall parity bit error
    end
    else begin
      error_type = 2'b00; // no error
    end
  
    // Generate corrected ecc code if single bit error and double bit errr
    // In case of double bit output data is still not the actual input message
    // Only in the case of single bit error, output data correction will results in correct
    // original message data
    corrected_ecc_code = generate_corrected_ecc_code(ecc_code, syndrome, error_type);
    
    // Extract data from corrected ecc code to get message data
    message_data = extract_message_data_from_ecc_code(corrected_ecc_code);
  end
  
  // Register message data and error type
  // i.e. Added flipflop at the output ports data_out and error_code
  always_ff@(posedge clk, posedge reset) begin
    // Student to add code here
  end
  
  // Function to create parity, ecc code, overall parity and final data out 
  function logic[R-1:0] generate_syndrome(logic[N:1] ecc_code_word);
   begin
    // initialize return variable to 0
    generate_syndrome = 0;
    
    // Create binary value from 0 until N
    for(int i=0; i<=N; i++) begin
      // Student to add code here
    end  
   
    // Generate syndrome values using ecc_code_word
    for(int i=1; i<=R; i++) begin
     for(int j=1; j<=N; j++) begin
      if((binary_value[j][i] == 1)) begin
         // Student to add code here   
      end
     end
    end  
   end
  endfunction
    
  // Function to extract message data from ecc code 
  function logic[M-1:0] extract_message_data_from_ecc_code(logic[N:1] ecc_code_word);
   begin
    //  Declare and initialize variables
    integer d_idx;
    d_idx=0;
    
    // Extract message data from ecc code word and store it in extract_message_data_from_ecc_code[d_idx++]
	// Remember extract_message_data_from_ecc_code is the return variable which is the function name itself
	// data bit positions are non-power of two so ensure index of ecc_code_word is ! != 2**$clog2(e_idx)
    for (int e_idx=1; e_idx<=N; e_idx++) begin
      if (e_idx != <student to add code here>) begin
       // Student to add code here
      end
    end 
   end
  endfunction
 
  // Function to generate corrected ecc code word
  function logic[N:1] generate_corrected_ecc_code(logic[N:1] ecc_code_word, logic[M-1:0] syn, logic[1:0] err_type);
   begin
    //  Declare and initialize variables
    generate_corrected_ecc_code = ecc_code_word;
    
    // Generate corrected ecc code word in case of single bit error (i.e. for error code 2'b01)
    // In case of no error, double bit error, overall parity bit error do not correct the data as data does not need correction
    if(<student to add code here>) begin // check here value of "err_type" coming into this function if its value is 2'b01 which is single bit error
      // Flip bit in ecc code based on syndrome value
      // Student to add code here
    end
    else begin
      // Do not flip bit
      // Student to add code here
    end
   end
  endfunction
 
endmodule: ecc_decoder









