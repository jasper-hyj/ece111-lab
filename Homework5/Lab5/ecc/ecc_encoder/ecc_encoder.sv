module ecc_encoder 
#(parameter M = 8, // Input message data width
  parameter R = 4, // Number of parity bits
  parameter N = M + R // Total number of bits for ecc code// Local Variables
)(
  input  logic [M-1:0] data_in, 
  output logic [N:0] data_out // output data includes ecc_code and overall parity in LSB
);

  logic [R:1] binary_value[N+1]; // To get binary value pattern required for each parity bit generation
  logic [N:1] ecc_code; // to store data with computed parity in hamming code format
  logic [R-1:0] parity; // to store parity computed from input data 
  logic overall_parity; // Overall parity generated for ecc_code
 
  // Compute ecc code and overall parity for each input data
  assign data_out = generate_data_with_ecc(data_in);
 
  // Function to create parity, ecc code, overall parity and final data out 
  function logic[N:0] generate_data_with_ecc(logic[M-1:0] din);
    begin
      //  Declare and initialize variables
      integer d_idx;
      d_idx = 0;
      parity = 0;
      ecc_code = 0;
      overall_parity = 0;

      // Note : Students can have their own implementation
      // without using below mentioned code template
      // Code template below is for guidance purpose.
      
      // Create binary value from 0 until N (i.e. binary_value[i] = N)
      // This binary_value array is later required in the code to iterate to generate parity[0], 
      // parity[1],parity[2],parity[3]
      for(int i=0; i<=N; i++) begin
        // Student to add code here to fill binary_value array each index with "i"
        for (int b = 1; b <= R; b++) begin
          binary_value[i][b] = (i >> (b-1)) & 1;
        end
      end 

      // Store input data in ecc code word
      // Note : use for loop to insert din data bits in ecc_code
      // Iterate using for loop ecc_code packed array and skip power of 2 positions
      // in ecc_code packed array using if(e_idx != 2**$clog2(e_idx)) 
      // Student to update and fill in the code below
      for(int e_idx=1; e_idx <= N; e_idx++) begin // for loop line needs to be completed by student
        if ((e_idx & (e_idx - 1)) != 0) begin
          ecc_code[e_idx] = din[d_idx];
          d_idx++;
        end else begin
          ecc_code[e_idx] = 0;
        end
      end   
  
      // Generate parity values
      // Hint : Nested for loop required to iterate over binary_value table
      // Remember : Below mentioned are hard coded formulas for each parity bit for M=8, N=4
      // But instead of having these hard coded formula's use for loop to iterate over 
      // binary_value two dimensional array and generate parity value.
      //parity[0] = din[0] ^ din[1] ^ din[3] ^ din[4] ^ din[6];
      //parity[1] = din[0] ^ din[2] ^ din[3] ^ din[5] ^ din[6];
      //parity[2] = din[1] ^ din[2] ^ din[3] ^ din[7];
      //parity[3] = din[4] ^ din[5] ^ din[6] ^ din[7];
      for(int i=1; i<=R; i++) begin
        parity[i-1] = 0;
        for(int j=1; j<=N; j++) begin
          if (binary_value[j][i] == 1) begin
            parity[i-1] ^= ecc_code[j];
          end
        end
      end
    
      // Store parity in ecc code word
      // Using for loop iterate ecc_code and store parity value generated
      // from above mentioned for loop in power of 2 positions.
      // For power of two indexing, 2**i can be used
      for (int i=0; i<R; i++) begin // student to complete this line
        // Student to add code here  
        ecc_code[1<<i] = parity[i];
      end
    
      
      // Compute overall parity of code word
      // when computing overall parity use ecc_code variable which has
      // original message bits along with computed parity bits
      // Student to add code to compute overall parity
      // <your code here using assign statement or any other approach>
      // sutudent to complete this code
      overall_parity = 0;
      for (int j=1; j<=N; j++) begin
        overall_parity ^= ecc_code[j];
      end
    
      // Generate data with ecc code and overall parity and return this value
      // Overall parity is added in LSB of final data out
      // Note : ecc_code should be upper bits and overall_parity should be LSB bit
      generate_data_with_ecc = {ecc_code[N:1], overall_parity}; //student to add code here
    end

  endfunction

endmodule: ecc_encoder