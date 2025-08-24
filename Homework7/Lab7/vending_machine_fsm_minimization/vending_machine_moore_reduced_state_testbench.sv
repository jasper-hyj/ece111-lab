//vending machine reduced state testbench code
`timescale 1ns/1ns
module vending_machine_moore_reduced_state_testbench;
logic clock, rstn;
logic N, D, open;

// Instantiate design under test
vending_machine_moore_reduced_state DUT(
.clk(clock),
.rstn(rstn),
.N(N),
.D(D),
.open(open)
);

initial begin
// Initialize Inputs
rstn = 0;
clock = 0;
N = 0;
D = 0;

// Wait 20 ns for global reset to finish and start counter
#20;
rstn = 1;

// Drive N, D
@(posedge clock);
N = 1; 
D = 0;
@(posedge clock);
N = 0;
D = 1;

@(posedge clock);
N = 0;
D = 0; 

@(posedge clock);
N = 1; 
D = 0;
@(posedge clock);
N = 1;
D = 0; 
@(posedge clock);
N = 1;
D = 0; 

@(posedge clock);
N = 0;
D = 0;

@(posedge clock);
N = 1;
D = 0; 
@(posedge clock);
N = 1;
D = 0; 
@(posedge clock);
N = 0;
D = 1; 
@(posedge clock);
@(posedge clock);
N = 0;
D = 1; 

@(posedge clock);
N = 0;
D = 0;

@(posedge clock);
N = 0;
D = 1; 
@(posedge clock);
N = 1;
D = 0; 

@(posedge clock);
N = 0;
D = 0;

@(posedge clock);
N = 0;
D = 1; 
@(posedge clock);
N = 0;
D = 1; 
@(posedge clock);
N = 0;
D = 0; 
@(posedge clock);
N = 1;
D = 0;
@(posedge clock);
N = 1;
D = 0;

@(posedge clock);
N = 0;
D = 0;

repeat(4) @(posedge clock);

// terminate simulation
$finish();
end

// Clock generator logic
always@(clock) begin
  #10ns clock <= !clock;
end
endmodule