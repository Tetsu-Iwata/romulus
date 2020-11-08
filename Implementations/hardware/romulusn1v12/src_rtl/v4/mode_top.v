module mode_top (/*AUTOARG*/
   // Outputs
   pdo, counter,
   // Inputs
   pdi, sdi, domain, decrypt, clk, srst, senc, sse, xrst, xenc, xse,
   yrst, yenc, yse, zrst, zenc, zse, erst, correct_cnt, constant, constant2, constant3, constant4,
	constant5, constant6, constant7, constant8,
   tk1s
   ) ;
   output [31:0] pdo;
   output [55:0] counter;   

   input [31:0]  pdi;
   input [31:0]  sdi;
   input [7:0] 	 domain;
   input [3:0] 	 decrypt;   
   input 	 clk;
   input 	 srst, senc, sse;
   input 	 xrst, xenc, xse;
   input 	 yrst, yenc, yse;
   input 	 zrst, zenc, zse;
   input 	 erst;  
   input 	 correct_cnt;
   input [5:0] 	 constant;
	input [5:0] 	 constant2;
	input [5:0] 	 constant3;
	input [5:0] 	 constant4;
	input [5:0] 	 constant5;
	input [5:0] 	 constant6;
	input [5:0] 	 constant7;
	input [5:0] 	 constant8;
   input 	 tk1s;

   wire [127:0]  tk1, tk2;
   wire [63:0] 	 tk3;
   wire [127:0]  tka, tkb;
   wire [63:0] 	 tkc;
   wire [127:0]  skinnyS;
   wire [127:0]  skinnyX, skinnyY;
   wire [63:0] 	 skinnyZ;
   wire [127:0]  TKX0, TKY0;
   wire [127:0]  TKX1, TKY1;
	wire [127:0]  TKX2, TKY2;
   wire [127:0]  TKX3, TKY3;
	wire [127:0]  TKX4, TKY4;
   wire [127:0]  TKX5, TKY5;
	wire [127:0]  TKX6, TKY6;
   wire [127:0]  TKX7, TKY7;
   wire [63:0] 	 TKZ0;
   wire [63:0] 	 TKZ1;
	wire [63:0] 	 TKZ2;
   wire [63:0] 	 TKZ3;
	wire [63:0] 	 TKZ4;
   wire [63:0] 	 TKZ5;
	wire [63:0] 	 TKZ6;
   wire [63:0] 	 TKZ7;
   wire [127:0]  S;   
   wire [55:0]  cin;  

   assign counter = TKZ0[63:8];
   
 state_update_32b STATE (.state(S), .pdo(pdo), .skinny_state(skinnyS), .pdi(pdi),
			   .clk(clk), .rst(srst), .enc(senc), .se(sse), .decrypt(decrypt));
   
   tkx_update_32b TKEYX (.tkx(TKX0), .skinny_tkx(skinnyX), .skinny_tkx_revert(tk2), .sdi(sdi),
			 .clk(clk), .rst(xrst), .enc(xenc), .se(xse));
   
   tky_update_32b TKEYY (.tky(TKY0), .skinny_tky(skinnyY), .skinny_tky_revert(tk1), .pdi(pdi),
			 .clk(clk), .rst(yrst), .enc(yenc), .se(yse));
   
   tkz_update_32b TKEYZ (.tkz(TKZ0), .skinny_tkz(skinnyZ), .skinny_tkz_revert(tk3),
			 .clk(clk), .rst(zrst), .enc(zenc), .se(zse));


   assign cin = correct_cnt ? TKZ0[63:8] : tkc[63:8];
   //assign TKZZ = {TKZ, 64'h0};
   //assign TKZZ2 = 128'h0
   //assign TKZN = skinnyZ;   

   pt8 permA (.tk1o(tka), .tk1i(TKX0));
   pt8 permB (.tk1o(tkb), .tk1i(TKY0));
   pt4 permC (.tk1o(tkc), .tk1i(TKZ0), .ad(tk1s));

   lfsr_gf56 CNT (.so(tk3), .si(cin), .domain(domain));
   lfsr3_28 LFSR2 (.so(tk1), .si(tkb));
   lfsr2_28 LFSR3 (.so(tk2), .si(tka));

   RoundFunction SKINNY (.ROUND_KEY0({TKZ0, 64'h0, TKY0, TKX0}),
			 .ROUND_KEY1({TKZ1, 64'h0, TKY1, TKX1}),
          .ROUND_KEY2({TKZ2, 64'h0, TKY2, TKX2}),			 
			 .ROUND_KEY3({TKZ3, 64'h0, TKY3, TKX3}),
			 .ROUND_KEY4({TKZ4, 64'h0, TKY4, TKX4}),
			 .ROUND_KEY5({TKZ5, 64'h0, TKY5, TKX5}),
          .ROUND_KEY6({TKZ6, 64'h0, TKY6, TKX6}),			 
			 .ROUND_KEY7({TKZ7, 64'h0, TKY7, TKX7}),
			 .ROUND_IN(S), .ROUND_OUT(skinnyS), .CONST0(constant), .CONST1(constant2), .CONST2(constant3), .CONST3(constant4),
			 .CONST4(constant5), .CONST5(constant6), .CONST6(constant7), .CONST7(constant8));
   KeyExpansion KEYEXP (.ROUND_KEY8({skinnyZ, skinnyY, skinnyX}),
			.ROUND_KEY7({TKZ7, TKY7, TKX7}),
			.ROUND_KEY6({TKZ6, TKY6, TKX6}),
         .ROUND_KEY5({TKZ5, TKY5, TKX5}),
         .ROUND_KEY4({TKZ4, TKY4, TKX4}),			
			.ROUND_KEY3({TKZ3, TKY3, TKX3}),
         .ROUND_KEY2({TKZ2, TKY2, TKX2}),
         .ROUND_KEY1({TKZ1, TKY1, TKX1}),			
			.KEY({TKZ0,TKY0,TKX0}));
   
   
   
   
   
   
endmodule // mode_top
