`timescale 1ns / 1ps

module register #(
  parameter int WIDTH = 8
)(
  input logic clk,
  input logic rst_n,
  input logic en,
  input logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out
);

  always_ff @(posedge clk) begin
    if (!rst_n)
      data_out <= '0;
    else if (en)
      data_out <= data_in;
  end

endmodule
