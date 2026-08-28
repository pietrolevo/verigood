`timescale 1ns / 1ps

module mux #(
  parameter int WIDTH = 8
)(
  input logic [WIDTH-1:0] in_A, in_B,
  input logic sel,
  output logic [WIDTH-1:0] out_Y
);

  assign out_Y = sel ? in_B : in_A;

endmodule
