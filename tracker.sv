`timescale 1ns / 1ps
`default_nettype none

module tracker(
  input wire clk_in,		//Assuming 65MHz, 1 cycle = 15.38ns
  input wire rst_in,
  input wire [10:0] hcount_in,
  input wire [9:0] vcount_in,
  input wire [1:0] detected,
  input wire [10:0] xtrack,
  input wire [9:0] ytrack,
  output logic [23:0] rgb_out,
  output logic data_valid_out);
  
  logic [6:0] framecount;
  
  logic [10:0] xtrack_old;
  logic [9:0] ytrack_old;
  
  logic [1:0] state;
  localparam WATCH_R = 1;
  localparam WATCH_G = 2;
  localparam WATCH_B = 3;
  localparam REST = 0;
  
  localparam WAITTIME = 60;

  always_ff @(posedge clk_in) begin
  
    if(rst_in) begin
	  state <= REST;
	  framecount <= 0;
	  rgb_out <= 24'b0000_0100_0000_0000_0000_0000;
	  data_valid_out <= 1'b1;
	end
	
	if(data_valid_out) begin
	  data_valid_out <= 1'b0;
	end
	
	case(state)
	  
	  REST: begin
	    framecount <= 0;
		if(detected==2'b01) begin
	      state <= WATCH_R;
		  xtrack_old <= xtrack;
		  ytrack_old <= ytrack;
	    end else if(detected==2'b10) begin
	      state <= WATCH_G;
		  xtrack_old <= xtrack;
		  ytrack_old <= ytrack;
	    end else if(detected==2'b11) begin
	      state <= WATCH_B;
		  xtrack_old <= xtrack;
		  ytrack_old <= ytrack;
	    end
	  end
	  
	  WATCH_R: begin
	    if((hcount_in==10) && (vcount_in==10)) begin
	      framecount <= framecount + 1;
		end
		if((detected==2'b01) && (framecount>0) && (framecount < WAITTIME)) begin
		  framecount <= 0;
		  ytrack_old <= ytrack;
		  xtrack_old <= xtrack;
		  data_valid_out <= 1'b1;
		  if(ytrack>=ytrack_old && ((8'd255-rgb_out[23:16])>(ytrack-ytrack_old))) begin
		    rgb_out <= rgb_out + {(ytrack[7:0]-ytrack_old[7:0]), 16'b0};
	      end else if(ytrack<ytrack_old && (rgb_out[23:16]>(ytrack_old-ytrack))) begin
		    rgb_out <= rgb_out - {(ytrack_old[7:0]-ytrack[7:0]), 16'b0};
		  end
		end
		if(framecount >= WAITTIME) begin
		  state <= REST;
		  framecount <= 0;
		end
	  end
	  
	  WATCH_G: begin
	    if((hcount_in==10) && (vcount_in==10)) begin
	      framecount <= framecount + 1;
		end
		if((detected==2'b10) && (framecount>0) && (framecount < WAITTIME)) begin
		  framecount <= 0;
		  ytrack_old <= ytrack;
		  xtrack_old <= xtrack;
		  data_valid_out <= 1'b1;
		  if(ytrack>=ytrack_old && ((8'd255-rgb_out[15:8])>(ytrack-ytrack_old))) begin
		    rgb_out <= rgb_out + {8'b0, (ytrack[7:0]-ytrack_old[7:0]), 8'b0};
	      end else if(ytrack<ytrack_old && (rgb_out[15:8]>(ytrack_old-ytrack))) begin
		    rgb_out <= rgb_out - {8'b0, (ytrack_old[7:0]-ytrack[7:0]), 8'b0};
		  end
		end
		if(framecount >= WAITTIME) begin
		  state <= REST;
		  framecount <= 0;
		end
	  end
	  
	  WATCH_B: begin
	    if((hcount_in==10) && (vcount_in==10)) begin
	      framecount <= framecount + 1;
		end
		if((detected==2'b11) && (framecount>0) && (framecount < WAITTIME)) begin
		  framecount <= 0;
		  ytrack_old <= ytrack;
		  xtrack_old <= xtrack;
		  data_valid_out <= 1'b1;
		  if(ytrack>=ytrack_old && ((8'd255-rgb_out[7:0])>(ytrack-ytrack_old))) begin
		    rgb_out <= rgb_out + {16'b0, (ytrack[7:0]-ytrack_old[7:0])};
	      end else if(ytrack<ytrack_old && (rgb_out[7:0]>(ytrack_old-ytrack))) begin
		    rgb_out <= rgb_out - {16'b0, (ytrack_old[7:0]-ytrack[7:0])};
		  end
		end
		if(framecount >= WAITTIME) begin
		  state <= REST;
		  framecount <= 0;
		end
	  end
	
	
	endcase
	
	
  end

endmodule

`default_nettype none
