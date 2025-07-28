// Johnson Counter RTL Model
module johnson_counter (
  input logic clk, clear, preset,
  input logic[3:0] load_cnt,
  output logic[3:0] count
);
  always @(posedge clk or negedge clear) begin
    // Student to add code for Johnson Counter
    if (!clear) begin
      count = 4'b0000;
    end else if (!preset) begin
        count = load_cnt;
    end else begin
      count = {~count[0], count[3:1]};
    end
  end
endmodule: johnson_counter
