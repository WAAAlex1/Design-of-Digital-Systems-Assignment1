import comp.sv;

module datapath(
    input logic         clk,
    input  logic        reset,
    input  logic [15:0] AB,
    output logic [15:0] C
);

  // Standard signals
  shortint unsigned reg_a, next_reg_a;
  shortint unsigned reg_b, next_reg_b;



  // Registers
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      reg_a <= 16'd0;
      reg_b <= 16'd0;
    end else begin
      reg_a <= next_reg_a;
      reg_b <= next_reg_b;
    end
  end

endmodule