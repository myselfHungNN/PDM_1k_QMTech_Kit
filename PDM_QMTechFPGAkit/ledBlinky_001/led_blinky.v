`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: myselfHUNGNN
// 
// Create Date:    11:03:02 01/05/2022 
// Design Name: 
// Module Name:    led_blinky 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define DEBUG

module led_blinky(
    // system clock 
    input  i_sys_clk_50M,   
    // Debug purposes
	 output o_led_drive_D1,
	 output o_led_drive_D3,
	 output o_led_ext_drive,
	 `ifdef DEBUG
	 output o_CLK_100K,	
	 output o_CLK_200K,
    `endif	
	 // SUN module interface
	 output  o_CLK_REF,
	 input i_CLK_1,
	 input i_CLK_2,
	 output o_PDM_1,	 
	 output o_PDM_2	  
    );

  parameter NBITS = 16;
  
  parameter c_CNT_1HZ   = 25_000_000;  
  parameter c_CNT_1625K = 15;
  parameter c_CNT_100K = 250;
  parameter c_CNT_200K = 125;
  
  parameter c_IDX_100 = 100;
  // parameter MAX = 2**NBITS - 1;
  parameter MAX_x1 = 3270;
  parameter MAX_x2 = 6540; // 3270*2;
  parameter MAX_x3 = 9810; // 3270*3;
  parameter MAX_x4 = 13080; // 3270*4;
  parameter MAX_x5 = 16350; // 3270*5;
  parameter MAX_x6 = 19620; // 3270*6;
  parameter MAX_x7 = 22890; // 3270*7;
  parameter MAX_x8 = 26160; // 3270*8;
  parameter MAX_x9 = 2943; // 3270*9;
  
  `define MAX_CURR MAX_x4
  
  // These signals will be the counters:
   reg [61:0] r_CNT_1HZ;
  reg [7:0]  r_CNT_1625K;
  reg [7:0]  r_CNT_100K;
  reg [7:0]  r_CNT_200K;
  reg[7:0]   r_Index_100;
  
 // for PDM 1
  reg[NBITS-1:0] r_error1_PDM1;
  reg[NBITS-1:0] r_error0_PDM1; 
  reg[NBITS-1:0] r_error_PDM1; 
  reg[NBITS-1:0] r_din_reg_PDM1;
  reg            r_dout_PDM1;
  
// for PDM 2
  reg[NBITS-1:0] r_error1_PDM2;
  reg[NBITS-1:0] r_error0_PDM2; 
  reg[NBITS-1:0] r_error_PDM2;
  reg[NBITS-1:0] r_din_reg_PDM2;
  reg            r_dout_PDM2;  
 
  reg        r_TOGGLE_1HZ;  // LED blinky   
  reg        r_TOGGLE_1625K; // CLK REF
  reg        r_TOGGLE_100K; // FOR LUT
  // reverted
  reg        r_TOGGLE_200K;   
   
  //reg        r_CLK_REF;
  wire       w_CLK_REF;
  wire       w_CLK_100K; 
  wire       w_CLK_200K; 
 
  wire[7:0]  w_Index_100;
  
  reg[NBITS-1:0] r_sin_val;
  wire [NBITS-1:0] w_sin_val;
   
  
  begin 
  // All always blocks toggle a specific signal at a different frequency.
  // They all run continuously even if the switches are
  // not selecting their particular output.
  
/*
*   // Hung Code - Generator CLK REF (1.625Mhz)  
*/ 
  always @(posedge i_sys_clk_50M)
    begin: GEN_1625K
		if(r_CNT_1625K >= c_CNT_1625K -1)
		  begin
			r_TOGGLE_1625K <= !r_TOGGLE_1625K;
			r_CNT_1625K    <= 0;
		  end
		else	
			r_CNT_1625K <= r_CNT_1625K+1;
    end: GEN_1625K
/*
 *  Generation of REF 1Hz (50/50)
 */
  always @ (posedge i_sys_clk_50M)
    begin: GEN1Hz
      if (r_CNT_1HZ == c_CNT_1HZ-1) // -1, since counter starts at 0
        begin        
          r_TOGGLE_1HZ <= !r_TOGGLE_1HZ;
          r_CNT_1HZ    <= 0;
        end
      else
        r_CNT_1HZ <= r_CNT_1HZ + 1;
    end: GEN1Hz
/*
 * Generation CLK-100KHZ for LUT (50/50)
*/ 
always @(posedge i_sys_clk_50M)
    begin: GEN100K
		if(r_CNT_100K == c_CNT_100K -1)
		  begin
			r_TOGGLE_100K <= !r_TOGGLE_100K;
			r_CNT_100K    <= 0;
		  end
		else	
			r_CNT_100K <= r_CNT_100K+1;
    end: GEN100K
/*
 * Generation CLK-200KHZ for LUT (50/50)
*/ 
always @(posedge i_sys_clk_50M)
    begin: GEN200K
		if(r_CNT_200K == c_CNT_200K -1)
		  begin
			r_TOGGLE_200K <= !r_TOGGLE_200K;
			r_CNT_200K    <= 0;
		  end
		else	
			r_CNT_200K <= r_CNT_200K+1;
    end: GEN200K
/*
* Counter 100 - Address for Lookup - table
*/	 
 always @(posedge w_CLK_100K)
	begin: COUNTER100
	if (r_Index_100 >= c_IDX_100 - 1)
		begin
			r_Index_100 <= 0;
		end
	else
		r_Index_100 <= r_Index_100+1;		
	end: COUNTER100
/* 
*  Lookup Table (100 elements)
*/	
 always @(w_Index_100)
	begin: LUT100
		case (w_Index_100)
			0:  r_sin_val = 0;
			1:  r_sin_val = 205;
			2:  r_sin_val = 410;
			3:  r_sin_val = 613;
			4:  r_sin_val = 813;
			5:  r_sin_val = 1010;
			6:  r_sin_val = 1204;
			7:  r_sin_val = 1392;
			8:  r_sin_val = 1575;
			9:  r_sin_val = 1752;
			10:  r_sin_val = 1922;
			11:  r_sin_val = 2084;
			12:  r_sin_val = 2238;
			13:  r_sin_val = 2384;
			14:  r_sin_val = 2520;
			15:  r_sin_val = 2645;
			16:  r_sin_val = 2761;
			17:  r_sin_val = 2866;
			18:  r_sin_val = 2959;
			19:  r_sin_val = 3040;
			20:  r_sin_val = 3110;
			21:  r_sin_val = 3167;
			22:  r_sin_val = 3212;
			23:  r_sin_val = 3244;
			24:  r_sin_val = 3264;
			25:  r_sin_val = 3270;
			26:  r_sin_val = 3264;
			27:  r_sin_val = 3244;
			28:  r_sin_val = 3212;
			29:  r_sin_val = 3167;
			30:  r_sin_val = 3110;
			31:  r_sin_val = 3040;
			32:  r_sin_val = 2959;
			33:  r_sin_val = 2866;
			34:  r_sin_val = 2761;
			35:  r_sin_val = 2645;
			36:  r_sin_val = 2520;
			37:  r_sin_val = 2384;
			38:  r_sin_val = 2238;
			39:  r_sin_val = 2048;
			40:  r_sin_val = 1922;
			41:  r_sin_val = 1752;
			42:  r_sin_val = 1575;
			43:  r_sin_val = 1392;
			44:  r_sin_val = 1204;
			45:  r_sin_val = 1010;
			46:  r_sin_val = 813;
			47:  r_sin_val = 613;
			48:  r_sin_val = 410;
			49:  r_sin_val = 205;
			50:  r_sin_val = 0;
			51:  r_sin_val = -205;
			52:  r_sin_val = -410;
			53:  r_sin_val = -613;
			54:  r_sin_val = -813;
			55:  r_sin_val = -1010;
			56:  r_sin_val = -1204;
			57:  r_sin_val = -1392;
			58:  r_sin_val = -1575;
			59:  r_sin_val = -1752;
			60:  r_sin_val = -1922;
			61:  r_sin_val = -2084;
			62:  r_sin_val = -2238;
			63:  r_sin_val = -2520;
			64:  r_sin_val = -2645;
			65:  r_sin_val = -2645;
			66:  r_sin_val = -2761;
			67:  r_sin_val = -2866;
			68:  r_sin_val = -2959;
			69:  r_sin_val = -3040;
			70:  r_sin_val = -3110;
			71:  r_sin_val = -3167;
			72:  r_sin_val = -3212;
			73:  r_sin_val = -3244;
			74:  r_sin_val = -3264;
			75:  r_sin_val = -3270;
			76:  r_sin_val = -3264;
			77:  r_sin_val = -3244;
			78:  r_sin_val = -3212;
			79:  r_sin_val = -3167;
			80:  r_sin_val = -3110;
			81:  r_sin_val = -3040;
			82:  r_sin_val = -2959;
			83:  r_sin_val = -2866;
			84:  r_sin_val = -2761;
			85:  r_sin_val = -2645;
			86:  r_sin_val = -2520;
			87:  r_sin_val = -2384;
			88:  r_sin_val = -2238;
			89:  r_sin_val = -2084;
			90:  r_sin_val = -1922;
			91:  r_sin_val = -1752;
			92:  r_sin_val = -1575;
			93:  r_sin_val = -1392;
			94:  r_sin_val = -1204;
			95:  r_sin_val = -1010;
			96:  r_sin_val = -813;
			97:  r_sin_val = -613;
			98:  r_sin_val = -410;
			99:  r_sin_val = -205;
			default: 
				begin
              //do nothing
				end
	   endcase
	end: LUT100
	

/*
*   PMD 1 core (part 1)
*/

 always @(posedge i_CLK_1)
  begin: PDM1_part1
    r_din_reg_PDM1 <= r_sin_val;
    r_error1_PDM1 <= r_error_PDM1 + `MAX_CURR - r_din_reg_PDM1;
    r_error0_PDM1 <= r_error_PDM1 - r_din_reg_PDM1;
  end: PDM1_part1
/*
*   PDM 1 core (part 2)
*/
 always @(posedge i_CLK_1)
  begin: PDM1_part2  
		if (r_din_reg_PDM1 >= r_error_PDM1) 
			begin
				r_dout_PDM1 <= 1'b1;
				r_error_PDM1 <= r_error1_PDM1;
			end
		else
			begin
				r_dout_PDM1 <= 1'b0;
				r_error_PDM1 <= r_error0_PDM1;
			end
  end: PDM1_part2  

/*
*   PMD 2 core (part 1)
*/
 always @(posedge i_CLK_2)
  begin
    r_din_reg_PDM2 <= r_sin_val;
    r_error1_PDM2 <= r_error_PDM2 + `MAX_CURR - r_din_reg_PDM2;
    r_error0_PDM2 <= r_error_PDM2 - r_din_reg_PDM2;
  end 
 /* 
 * PDM2 core (part 2)
 */
 always @(posedge i_CLK_2)
  begin   
		if (r_din_reg_PDM2 >= r_error_PDM2) 
			begin
				r_dout_PDM2 <= 1'b1;
				r_error_PDM2 <= r_error1_PDM2;
			end
		else
			begin
				r_dout_PDM2 <= 1'b0;
				r_error_PDM2 <= r_error0_PDM2;
			end
  end
 
 //========
 //========
  assign o_led_drive_D1 = r_TOGGLE_1HZ;
  assign o_led_drive_D3 = !r_TOGGLE_1HZ;
  assign o_led_ext_drive = r_TOGGLE_1HZ;
  
  assign o_CLK_REF = r_TOGGLE_1625K;
  assign w_CLK_100K = r_TOGGLE_100K;
  
  `ifdef DEBUG
  assign o_CLK_100K = r_TOGGLE_100K;
  assign o_CLK_200K = r_TOGGLE_200K;
  `endif
  
  assign w_Index_100 = r_Index_100;
  assign w_sin_val = r_sin_val;
  
  assign o_PDM_1 = r_dout_PDM1;
  assign o_PDM_2 = r_dout_PDM2;  

 end  
  
endmodule
