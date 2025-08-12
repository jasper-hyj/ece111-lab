module gray_code_to_binary_convertor #(parameter N = 4)( 
  input logic clk, rstn, 
  input logic[N-1:0] gray_value,
  output logic[N-1:0] binary_value);
 
  // Add code for gray code to binary conversion
  function automatic logic [N-1:0] gray_to_binary(input logic [N-1:0] value);
    gray_to_binary[N-1] = value[N-1];
    for (int i = N-2; i >= 0; i = i - 1)
      gray_to_binary[i] = gray_to_binary[i+1] ^ value[i];
  endfunction

  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) binary_value <= '0;
    else       binary_value <= gray_to_binary(gray_value);
  end

endmodule: gray_code_to_binary_convertor
