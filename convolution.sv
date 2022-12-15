`timescale 1ns / 1ps
`default_nettype none

module convolution #(
    parameter K_SELECT=0)(
    input wire clk_in,
    input wire rst_in,
    input wire [2:0][15:0] data_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    input wire data_valid_in,

    output logic data_valid_out,
    output logic [10:0] hcount_out,
    output logic [9:0] vcount_out,
    output logic [15:0] line_out
    );

    
    // Your code here!

    /* Note that the coeffs output of the kernels module
     * is packed in all dimensions, so coeffs should be 
     * defined as `logic signed [2:0][2:0][7:0] coeffs`
     *
     * This is because iVerilog seems to be weird about passing 
     * signals between modules that are unpacked in more
     * than one dimension - even though this is perfectly
     * fine Verilog.
     */
    

    logic signed [2:0][2:0][7:0] coeffs;
    logic signed [7:0] shift, offset;

    logic [2:0][2:0][15:0] pixels;
    logic signed [2:0][2:0][16:0] red;
    logic signed [2:0][2:0][17:0] green;
    logic signed [2:0][2:0][16:0] blue;

    logic signed [5:0] pixel_red;
    logic signed [6:0] pixel_green;
    logic signed [5:0] pixel_blue;

    logic [1:0] state;


    kernels #(.K_SELECT(K_SELECT)) k_coeffs (.rst_in(rst_in), 
                    .coeffs(coeffs), .shift(shift), .offset(offset));

    // generate
    //     genvar i,j;
    //     for (i=0; i<3; i=i+1) begin
    //         for (j=0; j<3; j=j+1) begin
    //             assign red[i][j] = (rst_in) ? 0 : ($signed({1'b0, pixels[i][j][15:11]})*$signed(coeffs[i][j])) >>> shift;
    //             assign green[i][j] = (rst_in) ? 0 : ($signed({1'b0, pixels[i][j][10:5]})*$signed(coeffs[i][j])) >>> shift;
    //             assign blue[i][j] = (rst_in) ? 0 : ($signed({1'b0, pixels[i][j][4:0]})*$signed(coeffs[i][j]))) >>> shift;
    //         end
    //     end
    // endgenerate


    // always_comb begin
    //     pixel_red = $signed({1'b0, red[0][0]}) + $signed({1'b0, red[0][1]}) + $signed({1'b0, red[0][2]}) + $signed({1'b0, red[1][0]}) + $signed({1'b0, red[1][1]}) + $signed({1'b0, red[1][2]}) + $signed({1'b0, red[2][0]}) + $signed({1'b0, red[2][1]}) + $signed({1'b0, red[2][2]});
    //     pixel_green = $signed({1'b0, green[0][0]}) + $signed({1'b0, green[0][1]}) + $signed({1'b0, green[0][2]}) + $signed({1'b0, green[1][0]}) + $signed({1'b0, green[1][1]}) + $signed({1'b0, green[1][2]}) + $signed({1'b0, green[2][0]}) + $signed({1'b0, green[2][1]}) + $signed({1'b0, green[2][2]});
    //     pixel_blue = $signed({1'b0, blue[0][0]}) + $signed({1'b0, blue[0][1]}) + $signed({1'b0, blue[0][2]}) + $signed({1'b0, blue[1][0]}) + $signed({1'b0, blue[1][1]}) + $signed({1'b0, blue[1][2]}) + $signed({1'b0, blue[2][0]}) + $signed({1'b0, blue[2][1]}) + $signed({1'b0, blue[2][2]});
    // end
    
    

    always_ff @(posedge clk_in) begin
      // Make sure to have your output be set with registered logic!
      // Otherwise you'll have timing violations.

        if (rst_in) begin
            state <= 0;
            pixels <= 0;
            line_out <= 0;
            data_valid_out <= 0;
        end else begin

            if (state==0) begin
                if (data_valid_in) begin
                    pixels[2] <= $signed(pixels[1]);
                    pixels[1] <= $signed(pixels[0]);
                    pixels[0] <= $signed(data_in);
                    state <= 1;
                    hcount_out <= hcount_in;
                    vcount_out <= vcount_in;
                    data_valid_out <= 0;


                    red[0][0] <= (rst_in) ? 0 : (($signed({1'b0, data_in[0][15:11]})*$signed(coeffs[0][0])) >>> shift);
                    red[0][1] <= (rst_in) ? 0 : (($signed({1'b0, data_in[1][15:11]})*$signed(coeffs[0][1])) >>> shift);
                    red[0][2] <= (rst_in) ? 0 : (($signed({1'b0, data_in[2][15:11]})*$signed(coeffs[0][2])) >>> shift);
                    red[1][0] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][0][15:11]})*$signed(coeffs[1][0])) >>> shift);
                    red[1][1] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][1][15:11]})*$signed(coeffs[1][1])) >>> shift);
                    red[1][2] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][2][15:11]})*$signed(coeffs[1][2])) >>> shift);
                    red[2][0] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][0][15:11]})*$signed(coeffs[2][0])) >>> shift);
                    red[2][1] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][1][15:11]})*$signed(coeffs[2][1])) >>> shift);
                    red[2][2] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][2][15:11]})*$signed(coeffs[2][2])) >>> shift);

                    green[0][0] <= (rst_in) ? 0 : (($signed({1'b0, data_in[0][10:5]})*$signed(coeffs[0][0])) >>> shift);
                    green[0][1] <= (rst_in) ? 0 : (($signed({1'b0, data_in[1][10:5]})*$signed(coeffs[0][1])) >>> shift);
                    green[0][2] <= (rst_in) ? 0 : (($signed({1'b0, data_in[2][10:5]})*$signed(coeffs[0][2])) >>> shift);
                    green[1][0] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][0][10:5]})*$signed(coeffs[1][0])) >>> shift);
                    green[1][1] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][1][10:5]})*$signed(coeffs[1][1])) >>> shift);
                    green[1][2] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][2][10:5]})*$signed(coeffs[1][2])) >>> shift);
                    green[2][0] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][0][10:5]})*$signed(coeffs[2][0])) >>> shift);
                    green[2][1] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][1][10:5]})*$signed(coeffs[2][1])) >>> shift);
                    green[2][2] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][2][10:5]})*$signed(coeffs[2][2])) >>> shift);

                    blue[0][0] <= (rst_in) ? 0 : (($signed({1'b0, data_in[0][4:0]})*$signed(coeffs[0][0])) >>> shift);
                    blue[0][1] <= (rst_in) ? 0 : (($signed({1'b0, data_in[1][4:0]})*$signed(coeffs[0][1])) >>> shift);
                    blue[0][2] <= (rst_in) ? 0 : (($signed({1'b0, data_in[2][4:0]})*$signed(coeffs[0][2])) >>> shift);
                    blue[1][0] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][0][4:0]})*$signed(coeffs[1][0])) >>> shift);
                    blue[1][1] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][1][4:0]})*$signed(coeffs[1][1])) >>> shift);
                    blue[1][2] <= (rst_in) ? 0 : (($signed({1'b0, pixels[0][2][4:0]})*$signed(coeffs[1][2])) >>> shift);
                    blue[2][0] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][0][4:0]})*$signed(coeffs[2][0])) >>> shift);
                    blue[2][1] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][1][4:0]})*$signed(coeffs[2][1])) >>> shift);
                    blue[2][2] <= (rst_in) ? 0 : (($signed({1'b0, pixels[1][2][4:0]})*$signed(coeffs[2][2])) >>> shift);
                end
            end else if (state == 2'b01) begin
                pixel_red <= $signed({1'b0, red[0][0]}) + $signed({1'b0, red[0][1]}) + $signed({1'b0, red[0][2]}) + $signed({1'b0, red[1][0]}) + $signed({1'b0, red[1][1]}) + $signed({1'b0, red[1][2]}) + $signed({1'b0, red[2][0]}) + $signed({1'b0, red[2][1]}) + $signed({1'b0, red[2][2]});
                pixel_green <= $signed({1'b0, green[0][0]}) + $signed({1'b0, green[0][1]}) + $signed({1'b0, green[0][2]}) + $signed({1'b0, green[1][0]}) + $signed({1'b0, green[1][1]}) + $signed({1'b0, green[1][2]}) + $signed({1'b0, green[2][0]}) + $signed({1'b0, green[2][1]}) + $signed({1'b0, green[2][2]});
                pixel_blue <= $signed({1'b0, blue[0][0]}) + $signed({1'b0, blue[0][1]}) + $signed({1'b0, blue[0][2]}) + $signed({1'b0, blue[1][0]}) + $signed({1'b0, blue[1][1]}) + $signed({1'b0, blue[1][2]}) + $signed({1'b0, blue[2][0]}) + $signed({1'b0, blue[2][1]}) + $signed({1'b0, blue[2][2]});
                state <= state+1;

            end else if (state == 2'b11) begin
                line_out <= {(pixel_red<0) ? 4'b0:pixel_red[4:0], (pixel_green<0) ? 5'b0:pixel_green[5:0], (pixel_blue<0) ? 4'b0:pixel_blue[4:0]};
                data_valid_out <= 1;
                state <= 0;
            end else state <= state+1;

        end
    end



endmodule

















module kernels #(
  parameter K_SELECT=0)(
  input wire rst_in,
  output logic signed [2:0][2:0][7:0] coeffs,
  output logic signed [7:0] shift,
  output logic signed [7:0] offset);

  assign coeffs = { coeffs_i[2][2],
                    coeffs_i[2][1],
                    coeffs_i[2][0],
                    coeffs_i[1][2],
                    coeffs_i[1][1],
                    coeffs_i[1][0],
                    coeffs_i[0][2],
                    coeffs_i[0][1],
                    coeffs_i[0][0]};

  logic signed [7:0]coeffs_i[2:0][2:0];
  always_comb begin
    case (K_SELECT)
      0: begin // Identity
        coeffs_i[0][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[0][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[0][2] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][1] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[1][2] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][2] = rst_in ? 8'sd0 : 8'sd0;
        shift = rst_in ? 8'sd0 : 8'sd0;
        offset = rst_in ? 8'sd0 : 8'sd0;
      end

      1: begin // Gaussian Blur
        coeffs_i[0][0] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[0][1] = rst_in ? 8'sd0 : 8'sd2;
        coeffs_i[0][2] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[1][0] = rst_in ? 8'sd0 : 8'sd2;
        coeffs_i[1][1] = rst_in ? 8'sd0 : 8'sd4;
        coeffs_i[1][2] = rst_in ? 8'sd0 : 8'sd2;
        coeffs_i[2][0] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[2][1] = rst_in ? 8'sd0 : 8'sd2;
        coeffs_i[2][2] = rst_in ? 8'sd0 : 8'sd1;
        shift = rst_in ? 8'sd0 : 8'sd4;
        offset = rst_in ? 8'sd0 : 8'sd0;
      end

      2: begin // Sharpen
        coeffs_i[0][0] = rst_in ? 8'sd0 :  8'sd0;
        coeffs_i[0][1] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[0][2] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][0] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[1][1] = rst_in ? 8'sd0 :  8'sd5;
        coeffs_i[1][2] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[2][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][1] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[2][2] = rst_in ? 8'sd0 : 8'sd0;
        shift = rst_in ? 8'sd0 : 8'sd0;
        offset = rst_in ? 8'sd0 : 8'sd16;
      end

      3: begin // Ridge Detection
        coeffs_i[0][0] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[0][1] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[0][2] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[1][0] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[1][1] = rst_in ? 8'sd0 :  8'sd8;
        coeffs_i[1][2] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[2][0] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[2][1] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[2][2] = rst_in ? 8'sd0 : -8'sd1;
        shift = rst_in ? 8'sd0 : 8'sd0;
        offset = rst_in ? 8'sd0 : 8'sd16;
      end

      4: begin // Sobel X Edge Detection
        coeffs_i[0][0] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[0][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[0][2] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[1][0] = rst_in ? 8'sd0 : 8'sd2;
        coeffs_i[1][1] = rst_in ? 8'sd0 :  8'sd0;
        coeffs_i[1][2] = rst_in ? 8'sd0 : -8'sd2;
        coeffs_i[2][0] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[2][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][2] = rst_in ? 8'sd0 : -8'sd1;
        shift = rst_in ? 8'sd0 : 8'sd0;
        offset = rst_in ? 8'sd0 : 8'sd0;
      end

      5: begin // Sobel Y Edge Detection
        coeffs_i[0][0] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[0][1] = rst_in ? 8'sd0 : -8'sd2;
        coeffs_i[0][2] = rst_in ? 8'sd0 : -8'sd1;
        coeffs_i[1][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][2] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][0] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[2][1] = rst_in ? 8'sd0 : 8'sd2;
        coeffs_i[2][2] = rst_in ? 8'sd0 : 8'sd1;
        shift = rst_in ? 8'sd0 : 8'sd0;
        offset = rst_in ? 8'sd0 : 8'sd0;
      end
      default: begin //Identity kernel
        coeffs_i[0][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[0][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[0][2] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[1][1] = rst_in ? 8'sd0 : 8'sd1;
        coeffs_i[1][2] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][0] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][1] = rst_in ? 8'sd0 : 8'sd0;
        coeffs_i[2][2] = rst_in ? 8'sd0 : 8'sd0;
        shift = rst_in ? 8'sd0 : 8'sd0;
        offset = rst_in ? 8'sd0 : 8'sd0;
      end
    endcase
  end
endmodule

`default_nettype wire
