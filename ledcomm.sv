`timescale 1ns / 1ps
`default_nettype none

module ledcomm(
  input wire clk_in,		//Assuming 65MHz, 1 cycle = 15.38ns
  input wire rst_in,
  input wire [23:0] rgb_in,  //rgb input from module that converts 16' to 24'
  input wire data_valid_in,
  output logic comm);
  
  logic data_valid_in_old;
  
  logic [23:0] rgb;
  
  logic [4:0] datacount, datacount_old;
  logic [6:0] count;
  
  logic [1:0] state;
  
  logic [8:0] LEDcount;
  
  localparam LONG = 64;
  localparam SHORT = 20;
  localparam LONGSHORT = 84;
  
  localparam T_ZERO = 0;
  localparam T_ONE = 1;
  localparam NEXTBIT = 2;
  localparam REST = 3;
  
  localparam NUM_LEDS = 255;

  always_ff @(posedge clk_in) begin
  
    if(rst_in) begin
	  comm <= 1'b0;
	  rgb <= 1'b0;
	  state <= REST;
	  count <= 0;
	  datacount <= 0;
	  LEDcount <= 0;
	end
  
    data_valid_in_old <= data_valid_in;
	
	/*
	if(data_valid_in && ~data_valid_in_old) begin
	  rgb <= {rgb_in[15:8], rgb_in[23:16], rgb_in[7:0]};
	  datacount <= 0;
	  LEDcount <= 0;
	  state <= NEXTBIT;
    end
	*/
	
	if(state==REST && data_valid_in) begin
	  rgb <= {rgb_in[15:8], rgb_in[23:16], rgb_in[7:0]};
	  datacount <= 0;
	  LEDcount <= 0;
	  state <= NEXTBIT;
	end
	
	//if(datacount>=0 && ~data_valid_in) begin
	  //datacount <= (datacount>=23) ? 0 : (datacount + 1);
	//end
	
	
	
	case(state)
	
	  T_ZERO: begin
	    count <= count+1;
	    if(count<=SHORT) begin
		  comm <= 1;
		end else if(count<(LONGSHORT)) begin
		  comm <= 0;
		end else begin
		  state <= NEXTBIT;
		end
	  end 
	  
	  T_ONE: begin
	    count <= count+1;
	    if(count<=LONG) begin
		  comm <= 1;
		end else if(count<=(LONGSHORT)) begin
		  comm <= 0;
		end else begin
		  state <= NEXTBIT;
		end
	  end
	  
	  NEXTBIT: begin
	    count <= 0;
		
		if(LEDcount>=255 && datacount==0) begin
		  state <= REST;
		end else begin
	      datacount <= (datacount>=23) ? 0 : (datacount + 1);
		  datacount_old <= datacount;
	      if(rgb[23-datacount]==1'b0) begin
	        state <= T_ZERO;
	      end else if(rgb[23-datacount]==1'b1) begin
	        state <= T_ONE;
	      end
		  if(datacount_old==23 && datacount==0) begin
		    LEDcount <= LEDcount+1;
		  end
		end
	  end
	  
	  REST: begin
	    LEDcount <= 0;
		datacount <= 0;
		comm <= 0;
	  end
	  
	endcase
	
	
  end

endmodule

`default_nettype none
