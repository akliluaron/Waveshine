`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

  //your design here!

  // assign x_out = 11'b0; //REMOVE ME
  // assign y_out = 10'b0; //REMOVE ME
  // assign valid_out = 1'b0; //REMOVE ME

  logic [31:0] x_sum;
  logic [31:0] y_sum;
  integer n;
  logic good_x, good_y;
  logic new_frame, rst_frame;

  logic x_divide_rst, y_divide_rst;
  logic x_data_valid_in, x_data_valid_out, x_error_out, x_busy_out;
  logic [31:0] x_dividend, x_divisor, x_quotient, x_remainder;

  logic y_data_valid_in, y_data_valid_out, y_error_out, y_busy_out;
  logic [31:0] y_dividend, y_divisor, y_quotient, y_remainder;


  divider #(.WIDTH(32)) divide_x (
          .clk_in(clk_in), .rst_in(x_divide_rst), .dividend_in(x_dividend), .divisor_in(x_divisor), .data_valid_in(x_data_valid_in), 
          .quotient_out(x_quotient), .remainder_out(x_remainder), .data_valid_out(x_data_valid_out), .error_out(x_error_out), .busy_out(x_busy_out));
  
  divider #(.WIDTH(32)) divide_y (
          .clk_in(clk_in), .rst_in(y_divide_rst), .dividend_in(y_dividend), .divisor_in(y_divisor), .data_valid_in(y_data_valid_in), 
          .quotient_out(y_quotient), .remainder_out(y_remainder), .data_valid_out(y_data_valid_out), .error_out(y_error_out), .busy_out(y_busy_out));

  always_ff @(posedge clk_in) begin
    if (rst_in || rst_frame) begin
      n <= 0;
      x_sum <= 0;
      y_sum <= 0;
      // x_out <= 0;
      // y_out <= 0;
      valid_out <= 0;
      good_x <= 0;
      good_y <= 0;

      x_divide_rst <= 1;
      y_divide_rst <= 1;
      x_data_valid_in <= 0;
      y_data_valid_in <= 0;

      new_frame <= 0;
      rst_frame <= 0;
    end else begin

      x_divide_rst <= 0;
      y_divide_rst <= 0;   

      if (~x_busy_out && ~y_busy_out) begin

        if (valid_in) begin
          x_sum <= x_sum + x_in;
          y_sum <= y_sum + y_in;
          n <= n+1;
        end
        
      
        
      end

      if (tabulate_in) begin
        if (n != 0) begin
          x_dividend <= x_sum;
          x_divisor <= n;
          x_data_valid_in <= 1;

          y_dividend <= y_sum;
          y_divisor <= n;
          y_data_valid_in <= 1;
        end
      end

      if (x_data_valid_out) begin
        x_out <= x_quotient;
        x_data_valid_in <= 0;
        good_x <= 1;
      end
      if (y_data_valid_out) begin
        y_out <= y_quotient;
        y_data_valid_in <= 0;
        good_y <= 1;
      end

      if (good_x && good_y) begin
        valid_out <= 1;
        good_x <= 0;
        good_y <= 0;
      end else begin
        valid_out <= 0;
        if (valid_out) new_frame <= 1;
      end

      if (new_frame) rst_frame <= 1;

      end

  end

endmodule

`default_nettype wire
