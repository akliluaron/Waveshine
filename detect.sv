`timescale 1ns / 1ps
`default_nettype none

module detect (
    input wire clk_in,
    input wire rst_in,
    input wire [9:0][15:0] data_in,
    input wire [10:0] hcount_in,
    input wire [9:0] vcount_in,
    input wire data_valid_in,

    output logic data_valid_out,
    output logic [10:0] hcount_out, y_com,
    output logic [9:0] vcount_out, x_com,
    output logic [15:0] line_out, //00 for no symbol, 01 for red, 10 for green, 11 for blue
    output logic [1:0] recognized
    );


    logic [4:0] THRESH;
    assign THRESH = 5'b01000;

    logic [6:0] IN_THRESH, OUT_THRESH, GOUT_THRESH;
    assign IN_THRESH = 60;
    assign OUT_THRESH = 60; 
    assign GOUT_THRESH = 60;

    logic [9:0][9:0][15:0] pixels;
    logic [6:0] black_sum, white_sum, R_sum, G_sum, B_sum;
    logic [10:0] old_hcount, start_hcount;
    logic [9:0] old_vcount, start_vcount;

    logic [6:0] in_counter, out_counter, vert_counter;
    logic checking_letter, valid_R, valid_G, valid_B, displayed, detected;
    
    logic [99:0] RSHAPE, GSHAPE, BSHAPE;
    assign RSHAPE = 100'b1100000011_1110000111_0111001110_0011111100_0001111000_0001111000_0011111100_0111001110_1110000111_1100000011;
    assign GSHAPE = 100'b1111111111_1111111110_1111111100_1111111000_1111110000_1111100000_1111000000_1110000000_1100000000_1000000000;
    assign BSHAPE = 100'b1111111111_1111111111_1100000011_1100000011_1100000011_1100000011_1100000011_1100000011_1111111111_1111111111;
    //assign RSHAPE = 100'b1111111111_1111111111_1111111111_0001100011_0001100011_0011110011_0111111111_1111011111_1110001110_1100000000;
    //assign GSHAPE = 100'b1111111111_1111111111_1100000011_1100000011_1100000011_1100000011_1100110011_1100110011_1111110000_1111110000;
    //assign BSHAPE = 100'b1111111111_1111111111_1100011000_1100011000_1111111000_1111111000_0000000000_0000000000_0000000000_0000000000;

    always_comb begin

        white_sum = ((pixels[8][9][15:11]>THRESH && pixels[8][9][10:5]>THRESH && pixels[8][9][4:0]>THRESH) +
            (pixels[8][8][15:11]>THRESH && pixels[8][8][10:5]>THRESH && pixels[8][8][4:0]>THRESH) +
            (pixels[8][7][15:11]>THRESH && pixels[8][7][10:5]>THRESH && pixels[8][7][4:0]>THRESH) +
            (pixels[8][6][15:11]>THRESH && pixels[8][6][10:5]>THRESH && pixels[8][6][4:0]>THRESH) +
            (pixels[8][5][15:11]>THRESH && pixels[8][5][10:5]>THRESH && pixels[8][5][4:0]>THRESH) +
            (pixels[8][4][15:11]>THRESH && pixels[8][4][10:5]>THRESH && pixels[8][4][4:0]>THRESH) +
            (pixels[8][3][15:11]>THRESH && pixels[8][3][10:5]>THRESH && pixels[8][3][4:0]>THRESH) + 
            (pixels[8][2][15:11]>THRESH && pixels[8][2][10:5]>THRESH && pixels[8][2][4:0]>THRESH) +
            (pixels[8][1][15:11]>THRESH && pixels[8][1][10:5]>THRESH && pixels[8][1][4:0]>THRESH) +
            (pixels[8][0][15:11]>THRESH && pixels[8][0][10:5]>THRESH && pixels[8][0][4:0]>THRESH) +

            (pixels[7][9][15:11]>THRESH && pixels[7][9][10:5]>THRESH && pixels[7][9][4:0]>THRESH) +
            (pixels[7][8][15:11]>THRESH && pixels[7][8][10:5]>THRESH && pixels[7][8][4:0]>THRESH) +
            (pixels[7][7][15:11]>THRESH && pixels[7][7][10:5]>THRESH && pixels[7][7][4:0]>THRESH) +
            (pixels[7][6][15:11]>THRESH && pixels[7][6][10:5]>THRESH && pixels[7][6][4:0]>THRESH) +
            (pixels[7][5][15:11]>THRESH && pixels[7][5][10:5]>THRESH && pixels[7][5][4:0]>THRESH) +
            (pixels[7][4][15:11]>THRESH && pixels[7][4][10:5]>THRESH && pixels[7][4][4:0]>THRESH) +
            (pixels[7][3][15:11]>THRESH && pixels[7][3][10:5]>THRESH && pixels[7][3][4:0]>THRESH) + 
            (pixels[7][2][15:11]>THRESH && pixels[7][2][10:5]>THRESH && pixels[7][2][4:0]>THRESH) +
            (pixels[7][1][15:11]>THRESH && pixels[7][1][10:5]>THRESH && pixels[7][1][4:0]>THRESH) +
            (pixels[7][0][15:11]>THRESH && pixels[7][0][10:5]>THRESH && pixels[7][0][4:0]>THRESH) +

            (pixels[6][9][15:11]>THRESH && pixels[6][9][10:5]>THRESH && pixels[6][9][4:0]>THRESH) +
            (pixels[6][8][15:11]>THRESH && pixels[6][8][10:5]>THRESH && pixels[6][8][4:0]>THRESH) +
            (pixels[6][7][15:11]>THRESH && pixels[6][7][10:5]>THRESH && pixels[6][7][4:0]>THRESH) +
            (pixels[6][6][15:11]>THRESH && pixels[6][6][10:5]>THRESH && pixels[6][6][4:0]>THRESH) +
            (pixels[6][5][15:11]>THRESH && pixels[6][5][10:5]>THRESH && pixels[6][5][4:0]>THRESH) +
            (pixels[6][4][15:11]>THRESH && pixels[6][4][10:5]>THRESH && pixels[6][4][4:0]>THRESH) +
            (pixels[6][3][15:11]>THRESH && pixels[6][3][10:5]>THRESH && pixels[6][3][4:0]>THRESH) + 
            (pixels[6][2][15:11]>THRESH && pixels[6][2][10:5]>THRESH && pixels[6][2][4:0]>THRESH) +
            (pixels[6][1][15:11]>THRESH && pixels[6][1][10:5]>THRESH && pixels[6][1][4:0]>THRESH) +
            (pixels[6][0][15:11]>THRESH && pixels[6][0][10:5]>THRESH && pixels[6][0][4:0]>THRESH) +

            (pixels[5][9][15:11]>THRESH && pixels[5][9][10:5]>THRESH && pixels[5][9][4:0]>THRESH) +
            (pixels[5][8][15:11]>THRESH && pixels[5][8][10:5]>THRESH && pixels[5][8][4:0]>THRESH) +
            (pixels[5][7][15:11]>THRESH && pixels[5][7][10:5]>THRESH && pixels[5][7][4:0]>THRESH) +
            (pixels[5][6][15:11]>THRESH && pixels[5][6][10:5]>THRESH && pixels[5][6][4:0]>THRESH) +
            (pixels[5][5][15:11]>THRESH && pixels[5][5][10:5]>THRESH && pixels[5][5][4:0]>THRESH) +
            (pixels[5][4][15:11]>THRESH && pixels[5][4][10:5]>THRESH && pixels[5][4][4:0]>THRESH) +
            (pixels[5][3][15:11]>THRESH && pixels[5][3][10:5]>THRESH && pixels[5][3][4:0]>THRESH) + 
            (pixels[5][2][15:11]>THRESH && pixels[5][2][10:5]>THRESH && pixels[5][2][4:0]>THRESH) +
            (pixels[5][1][15:11]>THRESH && pixels[5][1][10:5]>THRESH && pixels[5][1][4:0]>THRESH) +
            (pixels[5][0][15:11]>THRESH && pixels[5][0][10:5]>THRESH && pixels[5][0][4:0]>THRESH) +

            (pixels[4][9][15:11]>THRESH && pixels[4][9][10:5]>THRESH && pixels[4][9][4:0]>THRESH) +
            (pixels[4][8][15:11]>THRESH && pixels[4][8][10:5]>THRESH && pixels[4][8][4:0]>THRESH) +
            (pixels[4][7][15:11]>THRESH && pixels[4][7][10:5]>THRESH && pixels[4][7][4:0]>THRESH) +
            (pixels[4][6][15:11]>THRESH && pixels[4][6][10:5]>THRESH && pixels[4][6][4:0]>THRESH) +
            (pixels[4][5][15:11]>THRESH && pixels[4][5][10:5]>THRESH && pixels[4][5][4:0]>THRESH) +
            (pixels[4][4][15:11]>THRESH && pixels[4][4][10:5]>THRESH && pixels[4][4][4:0]>THRESH) +
            (pixels[4][3][15:11]>THRESH && pixels[4][3][10:5]>THRESH && pixels[4][3][4:0]>THRESH) + 
            (pixels[4][2][15:11]>THRESH && pixels[4][2][10:5]>THRESH && pixels[4][2][4:0]>THRESH) +
            (pixels[4][1][15:11]>THRESH && pixels[4][1][10:5]>THRESH && pixels[4][1][4:0]>THRESH) +
            (pixels[4][0][15:11]>THRESH && pixels[4][0][10:5]>THRESH && pixels[4][0][4:0]>THRESH) +

            (pixels[3][9][15:11]>THRESH && pixels[3][9][10:5]>THRESH && pixels[3][9][4:0]>THRESH) +
            (pixels[3][8][15:11]>THRESH && pixels[3][8][10:5]>THRESH && pixels[3][8][4:0]>THRESH) +
            (pixels[3][7][15:11]>THRESH && pixels[3][7][10:5]>THRESH && pixels[3][7][4:0]>THRESH) +
            (pixels[3][6][15:11]>THRESH && pixels[3][6][10:5]>THRESH && pixels[3][6][4:0]>THRESH) +
            (pixels[3][5][15:11]>THRESH && pixels[3][5][10:5]>THRESH && pixels[3][5][4:0]>THRESH) +
            (pixels[3][4][15:11]>THRESH && pixels[3][4][10:5]>THRESH && pixels[3][4][4:0]>THRESH) +
            (pixels[3][3][15:11]>THRESH && pixels[3][3][10:5]>THRESH && pixels[3][3][4:0]>THRESH) + 
            (pixels[3][2][15:11]>THRESH && pixels[3][2][10:5]>THRESH && pixels[3][2][4:0]>THRESH) +
            (pixels[3][1][15:11]>THRESH && pixels[3][1][10:5]>THRESH && pixels[3][1][4:0]>THRESH) +
            (pixels[3][0][15:11]>THRESH && pixels[3][0][10:5]>THRESH && pixels[3][0][4:0]>THRESH) +

            (pixels[2][9][15:11]>THRESH && pixels[2][9][10:5]>THRESH && pixels[2][9][4:0]>THRESH) +
            (pixels[2][8][15:11]>THRESH && pixels[2][8][10:5]>THRESH && pixels[2][8][4:0]>THRESH) +
            (pixels[2][7][15:11]>THRESH && pixels[2][7][10:5]>THRESH && pixels[2][7][4:0]>THRESH) +
            (pixels[2][6][15:11]>THRESH && pixels[2][6][10:5]>THRESH && pixels[2][6][4:0]>THRESH) +
            (pixels[2][5][15:11]>THRESH && pixels[2][5][10:5]>THRESH && pixels[2][5][4:0]>THRESH) +
            (pixels[2][4][15:11]>THRESH && pixels[2][4][10:5]>THRESH && pixels[2][4][4:0]>THRESH) +
            (pixels[2][3][15:11]>THRESH && pixels[2][3][10:5]>THRESH && pixels[2][3][4:0]>THRESH) + 
            (pixels[2][2][15:11]>THRESH && pixels[2][2][10:5]>THRESH && pixels[2][2][4:0]>THRESH) +
            (pixels[2][1][15:11]>THRESH && pixels[2][1][10:5]>THRESH && pixels[2][1][4:0]>THRESH) +
            (pixels[2][0][15:11]>THRESH && pixels[2][0][10:5]>THRESH && pixels[2][0][4:0]>THRESH) +
            
            (pixels[1][9][15:11]>THRESH && pixels[1][9][10:5]>THRESH && pixels[1][9][4:0]>THRESH) +
            (pixels[1][8][15:11]>THRESH && pixels[1][8][10:5]>THRESH && pixels[1][8][4:0]>THRESH) +
            (pixels[1][7][15:11]>THRESH && pixels[1][7][10:5]>THRESH && pixels[1][7][4:0]>THRESH) +
            (pixels[1][6][15:11]>THRESH && pixels[1][6][10:5]>THRESH && pixels[1][6][4:0]>THRESH) +
            (pixels[1][5][15:11]>THRESH && pixels[1][5][10:5]>THRESH && pixels[1][5][4:0]>THRESH) +
            (pixels[1][4][15:11]>THRESH && pixels[1][4][10:5]>THRESH && pixels[1][4][4:0]>THRESH) +
            (pixels[1][3][15:11]>THRESH && pixels[1][3][10:5]>THRESH && pixels[1][3][4:0]>THRESH) + 
            (pixels[1][2][15:11]>THRESH && pixels[1][2][10:5]>THRESH && pixels[1][2][4:0]>THRESH) +
            (pixels[1][1][15:11]>THRESH && pixels[1][1][10:5]>THRESH && pixels[1][1][4:0]>THRESH) +
            (pixels[1][0][15:11]>THRESH && pixels[1][0][10:5]>THRESH && pixels[1][0][4:0]>THRESH) +

            (pixels[0][9][15:11]>THRESH && pixels[0][9][10:5]>THRESH && pixels[0][9][4:0]>THRESH) +
            (pixels[0][8][15:11]>THRESH && pixels[0][8][10:5]>THRESH && pixels[0][8][4:0]>THRESH) +
            (pixels[0][7][15:11]>THRESH && pixels[0][7][10:5]>THRESH && pixels[0][7][4:0]>THRESH) +
            (pixels[0][6][15:11]>THRESH && pixels[0][6][10:5]>THRESH && pixels[0][6][4:0]>THRESH) +
            (pixels[0][5][15:11]>THRESH && pixels[0][5][10:5]>THRESH && pixels[0][5][4:0]>THRESH) +
            (pixels[0][4][15:11]>THRESH && pixels[0][4][10:5]>THRESH && pixels[0][4][4:0]>THRESH) +
            (pixels[0][3][15:11]>THRESH && pixels[0][3][10:5]>THRESH && pixels[0][3][4:0]>THRESH) + 
            (pixels[0][2][15:11]>THRESH && pixels[0][2][10:5]>THRESH && pixels[0][2][4:0]>THRESH) +
            (pixels[0][1][15:11]>THRESH && pixels[0][1][10:5]>THRESH && pixels[0][1][4:0]>THRESH) +
            (pixels[0][0][15:11]>THRESH && pixels[0][0][10:5]>THRESH && pixels[0][0][4:0]>THRESH) +

            (data_in[9][15:11]>THRESH && data_in[9][10:5]>THRESH && data_in[9][4:0]>THRESH) +
            (data_in[8][15:11]>THRESH && data_in[8][10:5]>THRESH && data_in[8][4:0]>THRESH) +
            (data_in[7][15:11]>THRESH && data_in[7][10:5]>THRESH && data_in[7][4:0]>THRESH) +
            (data_in[6][15:11]>THRESH && data_in[6][10:5]>THRESH && data_in[6][4:0]>THRESH) +
            (data_in[5][15:11]>THRESH && data_in[5][10:5]>THRESH && data_in[5][4:0]>THRESH) +
            (data_in[4][15:11]>THRESH && data_in[4][10:5]>THRESH && data_in[4][4:0]>THRESH) + 
            (data_in[3][15:11]>THRESH && data_in[3][10:5]>THRESH && data_in[3][4:0]>THRESH) + 
            (data_in[2][15:11]>THRESH && data_in[2][10:5]>THRESH && data_in[2][4:0]>THRESH) +
            (data_in[1][15:11]>THRESH && data_in[1][10:5]>THRESH && data_in[1][4:0]>THRESH) +
            (data_in[0][15:11]>THRESH && data_in[0][10:5]>THRESH && data_in[0][4:0]>THRESH)); 


        black_sum = ((pixels[8][9][15:11]<THRESH && pixels[8][9][10:5]<THRESH && pixels[8][9][4:0]<THRESH) +
            (pixels[8][8][15:11]<THRESH && pixels[8][8][10:5]<THRESH && pixels[8][8][4:0]<THRESH) +
            (pixels[8][7][15:11]<THRESH && pixels[8][7][10:5]<THRESH && pixels[8][7][4:0]<THRESH) +
            (pixels[8][6][15:11]<THRESH && pixels[8][6][10:5]<THRESH && pixels[8][6][4:0]<THRESH) +
            (pixels[8][5][15:11]<THRESH && pixels[8][5][10:5]<THRESH && pixels[8][5][4:0]<THRESH) +
            (pixels[8][4][15:11]<THRESH && pixels[8][4][10:5]<THRESH && pixels[8][4][4:0]<THRESH) +
            (pixels[8][3][15:11]<THRESH && pixels[8][3][10:5]<THRESH && pixels[8][3][4:0]<THRESH) + 
            (pixels[8][2][15:11]<THRESH && pixels[8][2][10:5]<THRESH && pixels[8][2][4:0]<THRESH) +
            (pixels[8][1][15:11]<THRESH && pixels[8][1][10:5]<THRESH && pixels[8][1][4:0]<THRESH) +
            (pixels[8][0][15:11]<THRESH && pixels[8][0][10:5]<THRESH && pixels[8][0][4:0]<THRESH) +

            (pixels[7][9][15:11]<THRESH && pixels[7][9][10:5]<THRESH && pixels[7][9][4:0]<THRESH) +
            (pixels[7][8][15:11]<THRESH && pixels[7][8][10:5]<THRESH && pixels[7][8][4:0]<THRESH) +
            (pixels[7][7][15:11]<THRESH && pixels[7][7][10:5]<THRESH && pixels[7][7][4:0]<THRESH) +
            (pixels[7][6][15:11]<THRESH && pixels[7][6][10:5]<THRESH && pixels[7][6][4:0]<THRESH) +
            (pixels[7][5][15:11]<THRESH && pixels[7][5][10:5]<THRESH && pixels[7][5][4:0]<THRESH) +
            (pixels[7][4][15:11]<THRESH && pixels[7][4][10:5]<THRESH && pixels[7][4][4:0]<THRESH) +
            (pixels[7][3][15:11]<THRESH && pixels[7][3][10:5]<THRESH && pixels[7][3][4:0]<THRESH) + 
            (pixels[7][2][15:11]<THRESH && pixels[7][2][10:5]<THRESH && pixels[7][2][4:0]<THRESH) +
            (pixels[7][1][15:11]<THRESH && pixels[7][1][10:5]<THRESH && pixels[7][1][4:0]<THRESH) +
            (pixels[7][0][15:11]<THRESH && pixels[7][0][10:5]<THRESH && pixels[7][0][4:0]<THRESH) +

            (pixels[6][9][15:11]<THRESH && pixels[6][9][10:5]<THRESH && pixels[6][9][4:0]<THRESH) +
            (pixels[6][8][15:11]<THRESH && pixels[6][8][10:5]<THRESH && pixels[6][8][4:0]<THRESH) +
            (pixels[6][7][15:11]<THRESH && pixels[6][7][10:5]<THRESH && pixels[6][7][4:0]<THRESH) +
            (pixels[6][6][15:11]<THRESH && pixels[6][6][10:5]<THRESH && pixels[6][6][4:0]<THRESH) +
            (pixels[6][5][15:11]<THRESH && pixels[6][5][10:5]<THRESH && pixels[6][5][4:0]<THRESH) +
            (pixels[6][4][15:11]<THRESH && pixels[6][4][10:5]<THRESH && pixels[6][4][4:0]<THRESH) +
            (pixels[6][3][15:11]<THRESH && pixels[6][3][10:5]<THRESH && pixels[6][3][4:0]<THRESH) + 
            (pixels[6][2][15:11]<THRESH && pixels[6][2][10:5]<THRESH && pixels[6][2][4:0]<THRESH) +
            (pixels[6][1][15:11]<THRESH && pixels[6][1][10:5]<THRESH && pixels[6][1][4:0]<THRESH) +
            (pixels[6][0][15:11]<THRESH && pixels[6][0][10:5]<THRESH && pixels[6][0][4:0]<THRESH) +

            (pixels[5][9][15:11]<THRESH && pixels[5][9][10:5]<THRESH && pixels[5][9][4:0]<THRESH) +
            (pixels[5][8][15:11]<THRESH && pixels[5][8][10:5]<THRESH && pixels[5][8][4:0]<THRESH) +
            (pixels[5][7][15:11]<THRESH && pixels[5][7][10:5]<THRESH && pixels[5][7][4:0]<THRESH) +
            (pixels[5][6][15:11]<THRESH && pixels[5][6][10:5]<THRESH && pixels[5][6][4:0]<THRESH) +
            (pixels[5][5][15:11]<THRESH && pixels[5][5][10:5]<THRESH && pixels[5][5][4:0]<THRESH) +
            (pixels[5][4][15:11]<THRESH && pixels[5][4][10:5]<THRESH && pixels[5][4][4:0]<THRESH) +
            (pixels[5][3][15:11]<THRESH && pixels[5][3][10:5]<THRESH && pixels[5][3][4:0]<THRESH) + 
            (pixels[5][2][15:11]<THRESH && pixels[5][2][10:5]<THRESH && pixels[5][2][4:0]<THRESH) +
            (pixels[5][1][15:11]<THRESH && pixels[5][1][10:5]<THRESH && pixels[5][1][4:0]<THRESH) +
            (pixels[5][0][15:11]<THRESH && pixels[5][0][10:5]<THRESH && pixels[5][0][4:0]<THRESH) +

            (pixels[4][9][15:11]<THRESH && pixels[4][9][10:5]<THRESH && pixels[4][9][4:0]<THRESH) +
            (pixels[4][8][15:11]<THRESH && pixels[4][8][10:5]<THRESH && pixels[4][8][4:0]<THRESH) +
            (pixels[4][7][15:11]<THRESH && pixels[4][7][10:5]<THRESH && pixels[4][7][4:0]<THRESH) +
            (pixels[4][6][15:11]<THRESH && pixels[4][6][10:5]<THRESH && pixels[4][6][4:0]<THRESH) +
            (pixels[4][5][15:11]<THRESH && pixels[4][5][10:5]<THRESH && pixels[4][5][4:0]<THRESH) +
            (pixels[4][4][15:11]<THRESH && pixels[4][4][10:5]<THRESH && pixels[4][4][4:0]<THRESH) +
            (pixels[4][3][15:11]<THRESH && pixels[4][3][10:5]<THRESH && pixels[4][3][4:0]<THRESH) + 
            (pixels[4][2][15:11]<THRESH && pixels[4][2][10:5]<THRESH && pixels[4][2][4:0]<THRESH) +
            (pixels[4][1][15:11]<THRESH && pixels[4][1][10:5]<THRESH && pixels[4][1][4:0]<THRESH) +
            (pixels[4][0][15:11]<THRESH && pixels[4][0][10:5]<THRESH && pixels[4][0][4:0]<THRESH) +

            (pixels[3][9][15:11]<THRESH && pixels[3][9][10:5]<THRESH && pixels[3][9][4:0]<THRESH) +
            (pixels[3][8][15:11]<THRESH && pixels[3][8][10:5]<THRESH && pixels[3][8][4:0]<THRESH) +
            (pixels[3][7][15:11]<THRESH && pixels[3][7][10:5]<THRESH && pixels[3][7][4:0]<THRESH) +
            (pixels[3][6][15:11]<THRESH && pixels[3][6][10:5]<THRESH && pixels[3][6][4:0]<THRESH) +
            (pixels[3][5][15:11]<THRESH && pixels[3][5][10:5]<THRESH && pixels[3][5][4:0]<THRESH) +
            (pixels[3][4][15:11]<THRESH && pixels[3][4][10:5]<THRESH && pixels[3][4][4:0]<THRESH) +
            (pixels[3][3][15:11]<THRESH && pixels[3][3][10:5]<THRESH && pixels[3][3][4:0]<THRESH) + 
            (pixels[3][2][15:11]<THRESH && pixels[3][2][10:5]<THRESH && pixels[3][2][4:0]<THRESH) +
            (pixels[3][1][15:11]<THRESH && pixels[3][1][10:5]<THRESH && pixels[3][1][4:0]<THRESH) +
            (pixels[3][0][15:11]<THRESH && pixels[3][0][10:5]<THRESH && pixels[3][0][4:0]<THRESH) +

            (pixels[2][9][15:11]<THRESH && pixels[2][9][10:5]<THRESH && pixels[2][9][4:0]<THRESH) +
            (pixels[2][8][15:11]<THRESH && pixels[2][8][10:5]<THRESH && pixels[2][8][4:0]<THRESH) +
            (pixels[2][7][15:11]<THRESH && pixels[2][7][10:5]<THRESH && pixels[2][7][4:0]<THRESH) +
            (pixels[2][6][15:11]<THRESH && pixels[2][6][10:5]<THRESH && pixels[2][6][4:0]<THRESH) +
            (pixels[2][5][15:11]<THRESH && pixels[2][5][10:5]<THRESH && pixels[2][5][4:0]<THRESH) +
            (pixels[2][4][15:11]<THRESH && pixels[2][4][10:5]<THRESH && pixels[2][4][4:0]<THRESH) +
            (pixels[2][3][15:11]<THRESH && pixels[2][3][10:5]<THRESH && pixels[2][3][4:0]<THRESH) + 
            (pixels[2][2][15:11]<THRESH && pixels[2][2][10:5]<THRESH && pixels[2][2][4:0]<THRESH) +
            (pixels[2][1][15:11]<THRESH && pixels[2][1][10:5]<THRESH && pixels[2][1][4:0]<THRESH) +
            (pixels[2][0][15:11]<THRESH && pixels[2][0][10:5]<THRESH && pixels[2][0][4:0]<THRESH) +
            
            (pixels[1][9][15:11]<THRESH && pixels[1][9][10:5]<THRESH && pixels[1][9][4:0]<THRESH) +
            (pixels[1][8][15:11]<THRESH && pixels[1][8][10:5]<THRESH && pixels[1][8][4:0]<THRESH) +
            (pixels[1][7][15:11]<THRESH && pixels[1][7][10:5]<THRESH && pixels[1][7][4:0]<THRESH) +
            (pixels[1][6][15:11]<THRESH && pixels[1][6][10:5]<THRESH && pixels[1][6][4:0]<THRESH) +
            (pixels[1][5][15:11]<THRESH && pixels[1][5][10:5]<THRESH && pixels[1][5][4:0]<THRESH) +
            (pixels[1][4][15:11]<THRESH && pixels[1][4][10:5]<THRESH && pixels[1][4][4:0]<THRESH) +
            (pixels[1][3][15:11]<THRESH && pixels[1][3][10:5]<THRESH && pixels[1][3][4:0]<THRESH) + 
            (pixels[1][2][15:11]<THRESH && pixels[1][2][10:5]<THRESH && pixels[1][2][4:0]<THRESH) +
            (pixels[1][1][15:11]<THRESH && pixels[1][1][10:5]<THRESH && pixels[1][1][4:0]<THRESH) +
            (pixels[1][0][15:11]<THRESH && pixels[1][0][10:5]<THRESH && pixels[1][0][4:0]<THRESH) +

            (pixels[0][9][15:11]<THRESH && pixels[0][9][10:5]<THRESH && pixels[0][9][4:0]<THRESH) +
            (pixels[0][8][15:11]<THRESH && pixels[0][8][10:5]<THRESH && pixels[0][8][4:0]<THRESH) +
            (pixels[0][7][15:11]<THRESH && pixels[0][7][10:5]<THRESH && pixels[0][7][4:0]<THRESH) +
            (pixels[0][6][15:11]<THRESH && pixels[0][6][10:5]<THRESH && pixels[0][6][4:0]<THRESH) +
            (pixels[0][5][15:11]<THRESH && pixels[0][5][10:5]<THRESH && pixels[0][5][4:0]<THRESH) +
            (pixels[0][4][15:11]<THRESH && pixels[0][4][10:5]<THRESH && pixels[0][4][4:0]<THRESH) +
            (pixels[0][3][15:11]<THRESH && pixels[0][3][10:5]<THRESH && pixels[0][3][4:0]<THRESH) + 
            (pixels[0][2][15:11]<THRESH && pixels[0][2][10:5]<THRESH && pixels[0][2][4:0]<THRESH) +
            (pixels[0][1][15:11]<THRESH && pixels[0][1][10:5]<THRESH && pixels[0][1][4:0]<THRESH) +
            (pixels[0][0][15:11]<THRESH && pixels[0][0][10:5]<THRESH && pixels[0][0][4:0]<THRESH) +

            (data_in[9][15:11]<THRESH && data_in[9][10:5]<THRESH && data_in[9][4:0]<THRESH) +
            (data_in[8][15:11]<THRESH && data_in[8][10:5]<THRESH && data_in[8][4:0]<THRESH) +
            (data_in[7][15:11]<THRESH && data_in[7][10:5]<THRESH && data_in[7][4:0]<THRESH) +
            (data_in[6][15:11]<THRESH && data_in[6][10:5]<THRESH && data_in[6][4:0]<THRESH) +
            (data_in[5][15:11]<THRESH && data_in[5][10:5]<THRESH && data_in[5][4:0]<THRESH) +
            (data_in[4][15:11]<THRESH && data_in[4][10:5]<THRESH && data_in[4][4:0]<THRESH) + 
            (data_in[3][15:11]<THRESH && data_in[3][10:5]<THRESH && data_in[3][4:0]<THRESH) + 
            (data_in[2][15:11]<THRESH && data_in[2][10:5]<THRESH && data_in[2][4:0]<THRESH) +
            (data_in[1][15:11]<THRESH && data_in[1][10:5]<THRESH && data_in[1][4:0]<THRESH) +
            (data_in[0][15:11]<THRESH && data_in[0][10:5]<THRESH && data_in[0][4:0]<THRESH)); 
    end

    always_ff @(posedge clk_in) begin

        if (rst_in) begin
            data_valid_out <= 0;
            line_out <= 0;
            old_hcount <= 0;
            old_vcount <= 0;
            x_com <= 0;
            y_com <= 0;

            valid_R <= 0;
            valid_G <= 0;
            valid_B <= 0;
            displayed <= 0;
            detected <= 0;
            checking_letter <= 0;
            recognized <= 0;
            in_counter <= 0;
            out_counter <= 0;
            vert_counter <= 0;
            start_hcount <= 0;
            start_vcount <= 0;
            R_sum <= 0;
            G_sum <= 0;
            B_sum <= 0;

        end else begin

            if (data_valid_in) begin
                pixels[9] <= pixels[8];
                pixels[8] <= pixels[7];
                pixels[7] <= pixels[6];
                pixels[6] <= pixels[5];
                pixels[5] <= pixels[4];
                pixels[4] <= pixels[3];
                pixels[3] <= pixels[2];
                pixels[2] <= pixels[1];
                pixels[1] <= pixels[0];
                pixels[0] <= data_in;

                old_hcount <= hcount_in;
                // old_vcount <= vcount_in;

                if (checking_letter) begin

                    if (old_vcount != vcount_in) vert_counter <= (vert_counter==9) ? 0 : vert_counter+1;
                    old_vcount <= vcount_in;

                    if (hcount_in>=start_hcount && hcount_in<(start_hcount+91)) begin
                        if (in_counter==9) begin
                            in_counter <= 0;

                            if (vert_counter==0) begin
                                out_counter <= out_counter + 1;
                            end


                            if (R_sum > OUT_THRESH) begin
                                valid_R <= 1;
                                checking_letter <= 0;
                                detected <= 1;
                                R_sum <= 0;
                                G_sum <= 0;
                                B_sum <= 0;
                            end else if (G_sum > GOUT_THRESH) begin
                                valid_G <= 1;
                                checking_letter <= 0;
                                detected <= 1;
                                R_sum <= 0;
                                G_sum <= 0;
                                B_sum <= 0;
                            end else if (B_sum > OUT_THRESH) begin
                                valid_B <= 1;
                                checking_letter <= 0;
                                detected <= 1;
                                R_sum <= 0;
                                G_sum <= 0;
                                B_sum <= 0;
                            end else if (out_counter == 99) begin
                                //valid_R <= 0;
                                //valid_G <= 0;
                                //valid_B <= 0;
                                checking_letter <= 0;
                                R_sum <= 0;
                                G_sum <= 0;
                                B_sum <= 0;
                            end


                            // if (out_counter == 99) begin
                            //     valid_R <= (out_sum > OUT_THRESH);
                            //     checking_R <= 0;
                            //     R_sum <= 0;
                            // end
                        end else in_counter <= in_counter + 1;

                        if (hcount_in==318 && vcount_in==238) begin
                            if (detected) detected <= 0;
                            else begin
                                valid_R <= 0;
                                valid_G <= 0;
                                valid_B <= 0;
                            end
                        end

                        if (in_counter==0 && vert_counter==0 && out_counter != 99) begin
                            if (RSHAPE[99-out_counter]) R_sum <= R_sum + (white_sum > IN_THRESH);
                            else R_sum <= R_sum + (black_sum > IN_THRESH);

                            if (GSHAPE[99-out_counter]) G_sum <= G_sum + (white_sum > IN_THRESH);
                            else G_sum <= G_sum + (black_sum > IN_THRESH);

                            if (BSHAPE[99-out_counter]) B_sum <= B_sum + (white_sum > IN_THRESH);
                            else B_sum <= B_sum + (black_sum > IN_THRESH);
                        end

                    end

                end else begin
                    if (white_sum > IN_THRESH) begin
                        start_hcount <= hcount_in;
                        start_vcount <= vcount_in;
                        old_vcount <= vcount_in;
                        checking_letter <= 1;
                        in_counter <= 1;
                        out_counter <= 0;
                        displayed <= 0;

                    end  
                end

                if (hcount_in==10 && vcount_in==10) line_out <= 16'b11111_111111_00000;
                else if (hcount_in==300 && vcount_in==10) line_out <= 16'b00000_111111_11111;
                else if (valid_R || valid_G || valid_B) begin
                    y_com <= 320 - (start_hcount);
                    x_com <= 240 - (start_vcount);
                    if (displayed) line_out <= data_in[0];
                    else begin
                        displayed <= 1;
                        if (valid_R) begin 
                            line_out <= 16'hF800;
                            recognized <= 2'b01;
                        end else if (valid_G) begin
                            line_out <= 16'h07E0;
                            recognized <= 2'b10;
                        end else if (valid_B) begin
                            line_out <= 16'h001F;
                            recognized <= 2'b11;
                        end
                    end
                end else begin
                    if (in_counter==0 && vert_counter==0 && out_counter != 99 && (GSHAPE[99-out_counter]&&white_sum>IN_THRESH || ~GSHAPE[99-out_counter]&&black_sum>IN_THRESH) && (hcount_in>=start_hcount && hcount_in<(start_hcount+91)) && (vcount_in>=start_vcount && vcount_in<(start_vcount+99))) begin 
                        line_out <= (out_counter==1)? 16'b11111_000000_00000 : 16'h07E0;
                    end else line_out <= data_in[0];
                    x_com <= 0;
                    y_com <= 0;
                    recognized <= 0;
                end

                data_valid_out <= 1;
                hcount_out <= hcount_in;
                vcount_out <= vcount_in;

            end else data_valid_out <= 0;

        end

    end



endmodule


`default_nettype wire






                // line_out <= (

                //    (    (pixels[8][9][15:11]>THRESH && pixels[8][9][10:5]>THRESH && pixels[8][9][4:0]>THRESH) +
                //         (pixels[8][8][15:11]>THRESH && pixels[8][8][10:5]>THRESH && pixels[8][8][4:0]>THRESH) +
                //         (pixels[8][7][15:11]>THRESH && pixels[8][7][10:5]>THRESH && pixels[8][7][4:0]>THRESH) +
                //         (pixels[8][6][15:11]>THRESH && pixels[8][6][10:5]>THRESH && pixels[8][6][4:0]>THRESH) +
                //         (pixels[8][5][15:11]>THRESH && pixels[8][5][10:5]>THRESH && pixels[8][5][4:0]>THRESH) +
                //         (pixels[8][4][15:11]>THRESH && pixels[8][4][10:5]>THRESH && pixels[8][4][4:0]>THRESH) +
                //         (pixels[8][3][15:11]>THRESH && pixels[8][3][10:5]>THRESH && pixels[8][3][4:0]>THRESH) + 
                //         (pixels[8][2][15:11]>THRESH && pixels[8][2][10:5]>THRESH && pixels[8][2][4:0]>THRESH) +
                //         (pixels[8][1][15:11]>THRESH && pixels[8][1][10:5]>THRESH && pixels[8][1][4:0]>THRESH) +
                //         (pixels[8][0][15:11]>THRESH && pixels[8][0][10:5]>THRESH && pixels[8][0][4:0]>THRESH) +

                //         (pixels[7][9][15:11]>THRESH && pixels[7][9][10:5]>THRESH && pixels[7][9][4:0]>THRESH) +
                //         (pixels[7][8][15:11]>THRESH && pixels[7][8][10:5]>THRESH && pixels[7][8][4:0]>THRESH) +
                //         (pixels[7][7][15:11]>THRESH && pixels[7][7][10:5]>THRESH && pixels[7][7][4:0]>THRESH) +
                //         (pixels[7][6][15:11]>THRESH && pixels[7][6][10:5]>THRESH && pixels[7][6][4:0]>THRESH) +
                //         (pixels[7][5][15:11]>THRESH && pixels[7][5][10:5]>THRESH && pixels[7][5][4:0]>THRESH) +
                //         (pixels[7][4][15:11]>THRESH && pixels[7][4][10:5]>THRESH && pixels[7][4][4:0]>THRESH) +
                //         (pixels[7][3][15:11]>THRESH && pixels[7][3][10:5]>THRESH && pixels[7][3][4:0]>THRESH) + 
                //         (pixels[7][2][15:11]>THRESH && pixels[7][2][10:5]>THRESH && pixels[7][2][4:0]>THRESH) +
                //         (pixels[7][1][15:11]>THRESH && pixels[7][1][10:5]>THRESH && pixels[7][1][4:0]>THRESH) +
                //         (pixels[7][0][15:11]>THRESH && pixels[7][0][10:5]>THRESH && pixels[7][0][4:0]>THRESH) +

                //         (pixels[6][9][15:11]>THRESH && pixels[6][9][10:5]>THRESH && pixels[6][9][4:0]>THRESH) +
                //         (pixels[6][8][15:11]>THRESH && pixels[6][8][10:5]>THRESH && pixels[6][8][4:0]>THRESH) +
                //         (pixels[6][7][15:11]>THRESH && pixels[6][7][10:5]>THRESH && pixels[6][7][4:0]>THRESH) +
                //         (pixels[6][6][15:11]>THRESH && pixels[6][6][10:5]>THRESH && pixels[6][6][4:0]>THRESH) +
                //         (pixels[6][5][15:11]>THRESH && pixels[6][5][10:5]>THRESH && pixels[6][5][4:0]>THRESH) +
                //         (pixels[6][4][15:11]>THRESH && pixels[6][4][10:5]>THRESH && pixels[6][4][4:0]>THRESH) +
                //         (pixels[6][3][15:11]>THRESH && pixels[6][3][10:5]>THRESH && pixels[6][3][4:0]>THRESH) + 
                //         (pixels[6][2][15:11]>THRESH && pixels[6][2][10:5]>THRESH && pixels[6][2][4:0]>THRESH) +
                //         (pixels[6][1][15:11]>THRESH && pixels[6][1][10:5]>THRESH && pixels[6][1][4:0]>THRESH) +
                //         (pixels[6][0][15:11]>THRESH && pixels[6][0][10:5]>THRESH && pixels[6][0][4:0]>THRESH) +

                //         (pixels[5][9][15:11]>THRESH && pixels[5][9][10:5]>THRESH && pixels[5][9][4:0]>THRESH) +
                //         (pixels[5][8][15:11]>THRESH && pixels[5][8][10:5]>THRESH && pixels[5][8][4:0]>THRESH) +
                //         (pixels[5][7][15:11]>THRESH && pixels[5][7][10:5]>THRESH && pixels[5][7][4:0]>THRESH) +
                //         (pixels[5][6][15:11]>THRESH && pixels[5][6][10:5]>THRESH && pixels[5][6][4:0]>THRESH) +
                //         (pixels[5][5][15:11]>THRESH && pixels[5][5][10:5]>THRESH && pixels[5][5][4:0]>THRESH) +
                //         (pixels[5][4][15:11]>THRESH && pixels[5][4][10:5]>THRESH && pixels[5][4][4:0]>THRESH) +
                //         (pixels[5][3][15:11]>THRESH && pixels[5][3][10:5]>THRESH && pixels[5][3][4:0]>THRESH) + 
                //         (pixels[5][2][15:11]>THRESH && pixels[5][2][10:5]>THRESH && pixels[5][2][4:0]>THRESH) +
                //         (pixels[5][1][15:11]>THRESH && pixels[5][1][10:5]>THRESH && pixels[5][1][4:0]>THRESH) +
                //         (pixels[5][0][15:11]>THRESH && pixels[5][0][10:5]>THRESH && pixels[5][0][4:0]>THRESH) +

                //         (pixels[4][9][15:11]>THRESH && pixels[4][9][10:5]>THRESH && pixels[4][9][4:0]>THRESH) +
                //         (pixels[4][8][15:11]>THRESH && pixels[4][8][10:5]>THRESH && pixels[4][8][4:0]>THRESH) +
                //         (pixels[4][7][15:11]>THRESH && pixels[4][7][10:5]>THRESH && pixels[4][7][4:0]>THRESH) +
                //         (pixels[4][6][15:11]>THRESH && pixels[4][6][10:5]>THRESH && pixels[4][6][4:0]>THRESH) +
                //         (pixels[4][5][15:11]>THRESH && pixels[4][5][10:5]>THRESH && pixels[4][5][4:0]>THRESH) +
                //         (pixels[4][4][15:11]>THRESH && pixels[4][4][10:5]>THRESH && pixels[4][4][4:0]>THRESH) +
                //         (pixels[4][3][15:11]>THRESH && pixels[4][3][10:5]>THRESH && pixels[4][3][4:0]>THRESH) + 
                //         (pixels[4][2][15:11]>THRESH && pixels[4][2][10:5]>THRESH && pixels[4][2][4:0]>THRESH) +
                //         (pixels[4][1][15:11]>THRESH && pixels[4][1][10:5]>THRESH && pixels[4][1][4:0]>THRESH) +
                //         (pixels[4][0][15:11]>THRESH && pixels[4][0][10:5]>THRESH && pixels[4][0][4:0]>THRESH) +

                //         (pixels[3][9][15:11]>THRESH && pixels[3][9][10:5]>THRESH && pixels[3][9][4:0]>THRESH) +
                //         (pixels[3][8][15:11]>THRESH && pixels[3][8][10:5]>THRESH && pixels[3][8][4:0]>THRESH) +
                //         (pixels[3][7][15:11]>THRESH && pixels[3][7][10:5]>THRESH && pixels[3][7][4:0]>THRESH) +
                //         (pixels[3][6][15:11]>THRESH && pixels[3][6][10:5]>THRESH && pixels[3][6][4:0]>THRESH) +
                //         (pixels[3][5][15:11]>THRESH && pixels[3][5][10:5]>THRESH && pixels[3][5][4:0]>THRESH) +
                //         (pixels[3][4][15:11]>THRESH && pixels[3][4][10:5]>THRESH && pixels[3][4][4:0]>THRESH) +
                //         (pixels[3][3][15:11]>THRESH && pixels[3][3][10:5]>THRESH && pixels[3][3][4:0]>THRESH) + 
                //         (pixels[3][2][15:11]>THRESH && pixels[3][2][10:5]>THRESH && pixels[3][2][4:0]>THRESH) +
                //         (pixels[3][1][15:11]>THRESH && pixels[3][1][10:5]>THRESH && pixels[3][1][4:0]>THRESH) +
                //         (pixels[3][0][15:11]>THRESH && pixels[3][0][10:5]>THRESH && pixels[3][0][4:0]>THRESH) +

                //         (pixels[2][9][15:11]>THRESH && pixels[2][9][10:5]>THRESH && pixels[2][9][4:0]>THRESH) +
                //         (pixels[2][8][15:11]>THRESH && pixels[2][8][10:5]>THRESH && pixels[2][8][4:0]>THRESH) +
                //         (pixels[2][7][15:11]>THRESH && pixels[2][7][10:5]>THRESH && pixels[2][7][4:0]>THRESH) +
                //         (pixels[2][6][15:11]>THRESH && pixels[2][6][10:5]>THRESH && pixels[2][6][4:0]>THRESH) +
                //         (pixels[2][5][15:11]>THRESH && pixels[2][5][10:5]>THRESH && pixels[2][5][4:0]>THRESH) +
                //         (pixels[2][4][15:11]>THRESH && pixels[2][4][10:5]>THRESH && pixels[2][4][4:0]>THRESH) +
                //         (pixels[2][3][15:11]>THRESH && pixels[2][3][10:5]>THRESH && pixels[2][3][4:0]>THRESH) + 
                //         (pixels[2][2][15:11]>THRESH && pixels[2][2][10:5]>THRESH && pixels[2][2][4:0]>THRESH) +
                //         (pixels[2][1][15:11]>THRESH && pixels[2][1][10:5]>THRESH && pixels[2][1][4:0]>THRESH) +
                //         (pixels[2][0][15:11]>THRESH && pixels[2][0][10:5]>THRESH && pixels[2][0][4:0]>THRESH) +
                        
                //         (pixels[1][9][15:11]>THRESH && pixels[1][9][10:5]>THRESH && pixels[1][9][4:0]>THRESH) +
                //         (pixels[1][8][15:11]>THRESH && pixels[1][8][10:5]>THRESH && pixels[1][8][4:0]>THRESH) +
                //         (pixels[1][7][15:11]>THRESH && pixels[1][7][10:5]>THRESH && pixels[1][7][4:0]>THRESH) +
                //         (pixels[1][6][15:11]>THRESH && pixels[1][6][10:5]>THRESH && pixels[1][6][4:0]>THRESH) +
                //         (pixels[1][5][15:11]>THRESH && pixels[1][5][10:5]>THRESH && pixels[1][5][4:0]>THRESH) +
                //         (pixels[1][4][15:11]>THRESH && pixels[1][4][10:5]>THRESH && pixels[1][4][4:0]>THRESH) +
                //         (pixels[1][3][15:11]>THRESH && pixels[1][3][10:5]>THRESH && pixels[1][3][4:0]>THRESH) + 
                //         (pixels[1][2][15:11]>THRESH && pixels[1][2][10:5]>THRESH && pixels[1][2][4:0]>THRESH) +
                //         (pixels[1][1][15:11]>THRESH && pixels[1][1][10:5]>THRESH && pixels[1][1][4:0]>THRESH) +
                //         (pixels[1][0][15:11]>THRESH && pixels[1][0][10:5]>THRESH && pixels[1][0][4:0]>THRESH) +

                //         (pixels[0][9][15:11]>THRESH && pixels[0][9][10:5]>THRESH && pixels[0][9][4:0]>THRESH) +
                //         (pixels[0][8][15:11]>THRESH && pixels[0][8][10:5]>THRESH && pixels[0][8][4:0]>THRESH) +
                //         (pixels[0][7][15:11]>THRESH && pixels[0][7][10:5]>THRESH && pixels[0][7][4:0]>THRESH) +
                //         (pixels[0][6][15:11]>THRESH && pixels[0][6][10:5]>THRESH && pixels[0][6][4:0]>THRESH) +
                //         (pixels[0][5][15:11]>THRESH && pixels[0][5][10:5]>THRESH && pixels[0][5][4:0]>THRESH) +
                //         (pixels[0][4][15:11]>THRESH && pixels[0][4][10:5]>THRESH && pixels[0][4][4:0]>THRESH) +
                //         (pixels[0][3][15:11]>THRESH && pixels[0][3][10:5]>THRESH && pixels[0][3][4:0]>THRESH) + 
                //         (pixels[0][2][15:11]>THRESH && pixels[0][2][10:5]>THRESH && pixels[0][2][4:0]>THRESH) +
                //         (pixels[0][1][15:11]>THRESH && pixels[0][1][10:5]>THRESH && pixels[0][1][4:0]>THRESH) +
                //         (pixels[0][0][15:11]>THRESH && pixels[0][0][10:5]>THRESH && pixels[0][0][4:0]>THRESH) +

                //         (data_in[9][15:11]>THRESH && data_in[9][10:5]>THRESH && data_in[9][4:0]>THRESH) +
                //         (data_in[8][15:11]>THRESH && data_in[8][10:5]>THRESH && data_in[8][4:0]>THRESH) +
                //         (data_in[7][15:11]>THRESH && data_in[7][10:5]>THRESH && data_in[7][4:0]>THRESH) +
                //         (data_in[6][15:11]>THRESH && data_in[6][10:5]>THRESH && data_in[6][4:0]>THRESH) +
                //         (data_in[5][15:11]>THRESH && data_in[5][10:5]>THRESH && data_in[5][4:0]>THRESH) +
                //         (data_in[4][15:11]>THRESH && data_in[4][10:5]>THRESH && data_in[4][4:0]>THRESH) + 
                //         (data_in[3][15:11]>THRESH && data_in[3][10:5]>THRESH && data_in[3][4:0]>THRESH) + 
                //         (data_in[2][15:11]>THRESH && data_in[2][10:5]>THRESH && data_in[2][4:0]>THRESH) +
                //         (data_in[1][15:11]>THRESH && data_in[1][10:5]>THRESH && data_in[1][4:0]>THRESH) +
                //         (data_in[0][15:11]>THRESH && data_in[0][10:5]>THRESH && data_in[0][4:0]>THRESH) 

                //    ) >= 17) ? 16'hFFFF : data_in[0];