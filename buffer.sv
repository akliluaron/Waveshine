`timescale 1ns / 1ps
`default_nettype none


module buffer (
    input wire clk_in, //system clock
    input wire rst_in, //system reset

    input wire [10:0] hcount_in, //current hcount being read
    input wire [9:0] vcount_in, //current vcount being read
    input wire [15:0] pixel_data_in, //incoming pixel
    input wire data_valid_in, //incoming  valid data signal

    output logic [9:0][15:0] line_buffer_out, //output pixels of data (blah make this packed)
    output logic [10:0] hcount_out, //current hcount being read
    output logic [9:0] vcount_out, //current vcount being read
    output logic data_valid_out, //valid data out signal,
    output logic one_good, good_out
  );

  // Your code here!

  logic [15:0] lb1_in, lb2_in, lb3_in, lb4_in, lb5_in, lb6_in, lb7_in, lb8_in, lb9_in, lb10_in, lb11_in;
  logic [15:0] lb1_out, lb2_out, lb3_out, lb4_out, lb5_out, lb6_out, lb7_out, lb8_out, lb9_out, lb10_out, lb11_out;
  logic lb1_wr, lb2_wr, lb3_wr, lb4_wr, lb5_wr, lb6_wr, lb7_wr, lb8_wr, lb9_wr, lb10_wr, lb11_wr;
  logic [3:0] state;
  logic [9:0] old_vcount;

  // logic one_good;

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b11 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb11_wr),
    .dina(lb11_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb11_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b1 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb1_wr),
    .dina(lb1_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb1_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b2 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb2_wr),
    .dina(lb2_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb2_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b3 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb3_wr),
    .dina(lb3_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb3_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b4 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb4_wr),
    .dina(lb4_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb4_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b5 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb5_wr),
    .dina(lb5_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb5_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b6 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb6_wr),
    .dina(lb6_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb6_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b7 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb7_wr),
    .dina(lb7_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb7_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b8 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb8_wr),
    .dina(lb8_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb8_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b9 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb9_wr),
    .dina(lb9_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb9_out)
  );

  xilinx_true_dual_port_read_first_1_clock_ram #(
    .RAM_WIDTH(16),
    .RAM_DEPTH(320))
    line_b10 (
    //Write 
    .addra(hcount_in),
    .clka(clk_in),
    .wea(lb10_wr),
    .dina(lb10_in),
    .ena(1'b1),
    .regcea(1'b0),
    .rsta(rst_in),
    .douta(),
    //Read 
    .addrb(hcount_in),
    .dinb(0),
    .web(1'b0),
    .enb(1'b1),
    .rstb(rst_in),
    .regceb(1'b1),
    .doutb(lb10_out)
  );


  assign hcount_out = hcount_in;
  //assign vcount_out = vcount_in;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      line_buffer_out <= 0;
      data_valid_out <= 0;
      one_good <= 0;
      good_out <= 0;
      state <= 0;
    end else begin
      old_vcount <= vcount_in;

      if (data_valid_in) begin
        one_good <= 1;

        if (state == 4'b0000) begin
            line_buffer_out[0] <= lb1_out;
            line_buffer_out[1] <= lb2_out;
            line_buffer_out[2] <= lb3_out;
            line_buffer_out[3] <= lb4_out;
            line_buffer_out[4] <= lb5_out;
            line_buffer_out[5] <= lb6_out;
            line_buffer_out[6] <= lb7_out;
            line_buffer_out[7] <= lb8_out;
            line_buffer_out[8] <= lb9_out;
            line_buffer_out[9] <= lb10_out;
            lb11_wr <= 1;
            lb11_in <= pixel_data_in;
        end else if (state == 4'b0001) begin
            line_buffer_out[0] <= lb11_out;
            line_buffer_out[1] <= lb1_out;
            line_buffer_out[2] <= lb2_out;
            line_buffer_out[3] <= lb3_out;
            line_buffer_out[4] <= lb4_out;
            line_buffer_out[5] <= lb5_out;
            line_buffer_out[6] <= lb6_out;
            line_buffer_out[7] <= lb7_out;
            line_buffer_out[8] <= lb8_out;
            line_buffer_out[9] <= lb9_out;
            lb10_wr <= 1;
            lb10_in <= pixel_data_in;
        end else if (state == 4'b0010) begin
            line_buffer_out[0] <= lb10_out;
            line_buffer_out[1] <= lb11_out;
            line_buffer_out[2] <= lb1_out;
            line_buffer_out[3] <= lb2_out;
            line_buffer_out[4] <= lb3_out;
            line_buffer_out[5] <= lb4_out;
            line_buffer_out[6] <= lb5_out;
            line_buffer_out[7] <= lb6_out;
            line_buffer_out[8] <= lb7_out;
            line_buffer_out[9] <= lb8_out;
            lb9_wr <= 1;
            lb9_in <= pixel_data_in;
        end else if (state == 4'b0011) begin
            line_buffer_out[0] <= lb9_out;
            line_buffer_out[1] <= lb10_out;
            line_buffer_out[2] <= lb11_out;
            line_buffer_out[3] <= lb1_out;
            line_buffer_out[4] <= lb2_out;
            line_buffer_out[5] <= lb3_out;
            line_buffer_out[6] <= lb4_out;
            line_buffer_out[7] <= lb5_out;
            line_buffer_out[8] <= lb6_out;
            line_buffer_out[9] <= lb7_out;
            lb8_wr <= 1;
            lb8_in <= pixel_data_in;
        end else if (state == 4'b0100) begin
            line_buffer_out[0] <= lb8_out;
            line_buffer_out[1] <= lb9_out;
            line_buffer_out[2] <= lb10_out;
            line_buffer_out[3] <= lb11_out;
            line_buffer_out[4] <= lb1_out;
            line_buffer_out[5] <= lb2_out;
            line_buffer_out[6] <= lb3_out;
            line_buffer_out[7] <= lb4_out;
            line_buffer_out[8] <= lb5_out;
            line_buffer_out[9] <= lb6_out;
            lb7_wr <= 1;
            lb7_in <= pixel_data_in;
        end else if (state == 4'b0101) begin
            line_buffer_out[0] <= lb7_out;
            line_buffer_out[1] <= lb8_out;
            line_buffer_out[2] <= lb9_out;
            line_buffer_out[3] <= lb10_out;
            line_buffer_out[4] <= lb11_out;
            line_buffer_out[5] <= lb1_out;
            line_buffer_out[6] <= lb2_out;
            line_buffer_out[7] <= lb3_out;
            line_buffer_out[8] <= lb4_out;
            line_buffer_out[9] <= lb5_out;
            lb6_wr <= 1;
            lb6_in <= pixel_data_in;
        end else if (state == 4'b0110) begin
            line_buffer_out[0] <= lb6_out;
            line_buffer_out[1] <= lb7_out;
            line_buffer_out[2] <= lb8_out;
            line_buffer_out[3] <= lb9_out;
            line_buffer_out[4] <= lb10_out;
            line_buffer_out[5] <= lb11_out;
            line_buffer_out[6] <= lb1_out;
            line_buffer_out[7] <= lb2_out;
            line_buffer_out[8] <= lb3_out;
            line_buffer_out[9] <= lb4_out;
            lb5_wr <= 1;
            lb5_in <= pixel_data_in;
        end else if (state == 4'b0111) begin
            line_buffer_out[0] <= lb5_out;
            line_buffer_out[1] <= lb6_out;
            line_buffer_out[2] <= lb7_out;
            line_buffer_out[3] <= lb8_out;
            line_buffer_out[4] <= lb9_out;
            line_buffer_out[5] <= lb10_out;
            line_buffer_out[6] <= lb11_out;
            line_buffer_out[7] <= lb2_out;
            line_buffer_out[8] <= lb3_out;
            line_buffer_out[9] <= lb4_out;
            lb4_wr <= 1;
            lb4_in <= pixel_data_in;
        end else if (state == 4'b1000) begin
            line_buffer_out[0] <= lb4_out;
            line_buffer_out[1] <= lb5_out;
            line_buffer_out[2] <= lb6_out;
            line_buffer_out[3] <= lb7_out;
            line_buffer_out[4] <= lb8_out;
            line_buffer_out[5] <= lb9_out;
            line_buffer_out[6] <= lb10_out;
            line_buffer_out[7] <= lb11_out;
            line_buffer_out[8] <= lb1_out;
            line_buffer_out[9] <= lb2_out;
            lb3_wr <= 1;
            lb3_in <= pixel_data_in;
        end else if (state == 4'b1001) begin
            line_buffer_out[0] <= lb3_out;
            line_buffer_out[1] <= lb4_out;
            line_buffer_out[2] <= lb5_out;
            line_buffer_out[3] <= lb6_out;
            line_buffer_out[4] <= lb7_out;
            line_buffer_out[5] <= lb8_out;
            line_buffer_out[6] <= lb9_out;
            line_buffer_out[7] <= lb10_out;
            line_buffer_out[8] <= lb11_out;
            line_buffer_out[9] <= lb1_out;
            lb2_wr <= 1;
            lb2_in <= pixel_data_in;
        end else if (state == 4'b1010) begin
            line_buffer_out[0] <= lb2_out;
            line_buffer_out[1] <= lb3_out;
            line_buffer_out[2] <= lb4_out;
            line_buffer_out[3] <= lb5_out;
            line_buffer_out[4] <= lb6_out;
            line_buffer_out[5] <= lb7_out;
            line_buffer_out[6] <= lb8_out;
            line_buffer_out[7] <= lb9_out;
            line_buffer_out[8] <= lb10_out;
            line_buffer_out[9] <= lb11_out;
            lb1_wr <= 1;
            lb1_in <= pixel_data_in;
        end

      end else begin
        lb1_wr <= 0;
        lb2_wr <= 0;
        lb3_wr <= 0;
        lb4_wr <= 0;
        lb5_wr <= 0;
        lb6_wr <= 0;
        lb7_wr <= 0;
        lb8_wr <= 0;
        lb9_wr <= 0;
        lb10_wr <= 0;
        lb11_wr <= 0;
      end

      if (old_vcount != vcount_in) begin 
        state <= (state==4'b1010) ? 0 : state+1;
      end

      if (one_good) begin
        one_good <= 0;
        good_out <= 1;
      end if (good_out) begin
        good_out <= 0;
        data_valid_out <= 1;
        //if (vcount_in<5) vcount_out <= 240-vcount_in;
        //else vcount_out <= vcount_in - 5;
        vcount_out <= vcount_in;
      end else data_valid_out <= 0;
    end
  end

endmodule


`default_nettype wire
