`timescale 1ns / 1ps

module pwm_gen #(
  parameter int WIDTH = 8
)(
  input logic clk,
  input logic rst_n,
  input logic en,
  input logic [WIDTH-1:0] duty_in,
  output logic pwm_out
);

  logic [WIDTH-1:0] cnt_val;
  logic [WIDTH-1:0] duty_val;

  register #(
    .WIDTH(WIDTH)
  ) u_duty_register (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .data_in(duty_in),
    .data_out(duty_val)
  );

  counter #(
    .WIDTH(WIDTH)
  ) u_counter (
    .clk(clk),
    .rst_n(rst_n),
    .en(en),
    .data_out(cnt_val)
  );

  /* comparison */
  always_comb begin
    if (cnt_val < duty_val) begin
      pwm_out = 1'b1;
    end else begin
      pwm_out = 1'b0;
    end
  end

endmodule
