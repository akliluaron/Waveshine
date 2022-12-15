`timescale 1ns / 1ps
`default_nettype none

`include "iverilog_hack.svh"

module image_sprite #(
  parameter WIDTH=256, HEIGHT=256) (
  input wire pixel_clk_in,
  input wire rst_in,
  input wire [10:0] x_in, hcount_in,
  input wire [9:0]  y_in, vcount_in,
  output logic [11:0] pixel_out);


  logic [10:0] hcount_pipe [4:0];
  logic [9:0] vcount_pipe [4:0];

  always_ff @(posedge pixel_clk_in) begin
    hcount_pipe[0] <= hcount_in;
    vcount_pipe[0] <= vcount_in;
    for (int i=1; i<5; i=i+1) begin
      hcount_pipe[i] <= hcount_pipe[i-1];
      vcount_pipe[i] <= vcount_pipe[i-1];
    end
  end

  // calculate rom address
  logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
  assign image_addr = (hcount_in - x_in) + ((vcount_in - y_in) * WIDTH);

  logic in_sprite;
  assign in_sprite = ((hcount_pipe[4] >= x_in && hcount_pipe[4] < (x_in + WIDTH)) &&
                      (vcount_pipe[4] >= y_in && vcount_pipe[4] < (y_in + HEIGHT)));

  logic [7:0] color_index;
  logic [11:0] color;

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(8),
    .RAM_DEPTH(256*256),
    .INIT_FILE(`FPATH(image.mem)))
    image (
    //Write Side
    .addra(0),
    .clka(0),
    .wea(0),
    .dina(0),
    .ena(0),
    .regcea(0),
    .rsta(rst_in),
    .douta(),
    //Read Side (65 MHz)
    .addrb(image_addr),
    .dinb(0),
    .clkb(pixel_clk_in),
    .web(0),
    .enb(1),
    .rstb(rst_in),
    .regceb(1),
    .doutb(color_index)
  );

  xilinx_true_dual_port_read_first_2_clock_ram #(
    .RAM_WIDTH(12),
    .RAM_DEPTH(256),
    .INIT_FILE(`FPATH(palette.mem)))
    palette (
    //Write Side
    .addra(0),
    .clka(0),
    .wea(0),
    .dina(0),
    .ena(0),
    .regcea(0),
    .rsta(rst_in),
    .douta(),
    //Read Side (65 MHz)
    .addrb(color_index),
    .dinb(0),
    .clkb(pixel_clk_in),
    .web(0),
    .enb(1),
    .rstb(rst_in),
    .regceb(1),
    .doutb(color)
  );

  // Modify the line below to use your BRAMs!
  assign pixel_out = in_sprite ? color : 0;
endmodule

`default_nettype none
