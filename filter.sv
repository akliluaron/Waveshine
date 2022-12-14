
module filter #(parameter K_SELECT=0)(
  input wire clk_in,
  input wire rst_in,

  input wire data_valid_in,
  input wire [15:0] pixel_data_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,

  output logic data_valid_out,
  output logic [15:0] pixel_data_out,
  output logic [10:0] hcount_out, x_com,
  output logic [9:0] vcount_out, y_com,
  output logic [1:0] recognized
  );

  logic [9:0][15:0] buffs; //make this packed in two dimensions for iVerilog
  logic b_to_c_valid;
  logic [10:0] hcount_buff;
  logic [9:0] vcount_buff;

  buffer mbuff (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_valid_in(data_valid_in),
    .pixel_data_in(pixel_data_in),
    .hcount_in(hcount_in),
    .vcount_in(vcount_in),
    .data_valid_out(b_to_c_valid),
    .line_buffer_out(buffs),
    .hcount_out(hcount_buff),
    .vcount_out(vcount_buff)
    );


  // always_comb begin
  //   data_valid_out = b_to_c_valid;
  //   pixel_data_out = buffs[1];
  //   hcount_out = hcount_buff;
  //   vcount_out = vcount_buff;
  // end


  detect detect (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .data_in(buffs),
    .data_valid_in(b_to_c_valid),
    .hcount_in(hcount_buff),
    .vcount_in(vcount_buff),
    .line_out(pixel_data_out),
    .data_valid_out(data_valid_out),
    .hcount_out(hcount_out),
    .vcount_out(vcount_out),
    .x_com(x_com),
    .y_com(y_com),
    .recognized(recognized)
  );

  // convolution #(
  //   .K_SELECT(K_SELECT) )
  //   mconv (
  //   .clk_in(clk_in),
  //   .rst_in(rst_in),
  //   .data_in(buffs),
  //   .data_valid_in(b_to_c_valid),
  //   .hcount_in(hcount_buff),
  //   .vcount_in(vcount_buff),
  //   .line_out(pixel_data_out),
  //   .data_valid_out(data_valid_out),
  //   .hcount_out(hcount_out),
  //   .vcount_out(vcount_out)
  // );

endmodule
