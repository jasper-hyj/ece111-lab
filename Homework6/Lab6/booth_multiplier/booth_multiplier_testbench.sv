`timescale 1ns/1ns
//Integer Multiplier Testbench Code
module booth_multiplier_testbench;
	
parameter N = 4;
// Variable declarations
logic signed [N-1:0] multiplicand, multiplier;
logic signed [(2*N)-1:0] product, l_product;
logic done, clock, reset, start;
logic signed [N-1:0] multiplicand_list[16], multiplier_list[16];
logic signed [N-1:0] value_list[16];
integer error_count;

// Instantiate design under test
booth_multiplier #(
	.N(N)) design_instance (
	.clock(clock),
  	.reset(reset),
  	.start(start),
  	.multiplicand(multiplicand),
  	.multiplier(multiplier),
  	.product(product),
  	.done(done)
);

initial begin
    // Initialize value list to test	
	// Full list of values for 4-bit binary system
	value_list = '{-8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7}; 
	// Partial list of values
    //value_list = '{-8, -7, -3, -1, 0, 1, 6, 7}; 
	 
	
    // Initialize multiplicand list with value_list
	foreach(multiplicand_list[j]) begin
	  multiplicand_list[j] = value_list[j];
	end
	
	// Initialize multiplier list with value_list
	foreach(multiplier_list[k]) begin
	  multiplier_list[k] = value_list[k];
	end
	
	// Initialize Inputs and generate reset
	error_count = 0;
	reset = 1;
	clock = 1;
	multiplicand = 0;
	multiplier = 0;
	start = 0;

	// De-assert Reset
	#20;
	reset = 0;
	#20;

    // Test all multiplicand and multiplier values
	// Since in 4-bit binary system there will be 16 possible values for multiplicand 
	// and 16 possible values for multiplier, then 16 x 16 = 256 possible combination
	// values of multiplicand x multiplier should all be tested.
    foreach(multiplicand_list[i]) begin
	  foreach(multiplier_list[j]) begin
	    // initialize multiplicand, multiplier and generate start pulse
	    multiplicand = multiplicand_list[i];
	    multiplier = multiplier_list[j];
	    start = 1;
	    #20;
	    start = 0;
	
	    // Wait for product to be available from design
	    wait (done == 1);
        @(negedge clock);
        	
	    // Check if booth multiplier design generates correct product value for given multiplicand and multiplier 
	    l_product = multiplicand * multiplier;
	    if (product == l_product) begin
	      $display(" time=%0t   Multiplicand=%d   Multiplier=%d   Product=%d   Done=%d : Correct Result\n", $time, multiplicand, multiplier, product, done);
		end
	    else begin
		  error_count = error_count + 1;
	      $error(" time=%0t   Multiplicand=%d   Multiplier=%d   Product=%d   Done=%d : Incorrect Result. Expected product value = %d\n", $time, multiplicand, multiplier, product, done, l_product);
		end
		
	    // Wait for de-assertion of done from desgin before loading new values of multiplicand and multiplier
        wait(done == 0);
		#20;
	  end
    end

    // Print Test Pass/Fail based on error count value
    if(error_count !== 0) begin
	  $display("Error Count = %0d, Test Failed !\n", error_count);
	end
	else begin
	  $display("Error Count = %0d, Test Passed !\n", error_count);
	end

	// Wait for 10ns
	#200ns;

	// Terminate simulation
	$finish();
end
	
// Clock generator logic
always@(clock) begin
	#10ns clock <= !clock;
end
	
endmodule
	
	
	
	
	
	
	
	
	
	
	
