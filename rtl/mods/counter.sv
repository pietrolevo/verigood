`timescale 1ns / 1ps

module counter #(
  parameter int WIDTH = 8
)(
  input logic clk,
  input logic rst_n,
  input logic en,
  output logic [WIDTH-1:0] data_out
);

  logic [WIDTH-1:0] cnt;

  always_ff @(posedge clk) begin
    if (!rst_n)
      cnt <= '0;
    else if (en)
      cnt <= cnt + 1;
  end

  assign data_out = cnt;

endmodule
