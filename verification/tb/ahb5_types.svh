///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_types
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/10/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef RS_TYPES
`define RS_TYPES

  typedef enum logic [4:0]{
      REGFILE_CONFIG,      //00
      REGFILE_STATUS,      //01
      REGFILE_ENC_IN_01,   //02      
      REGFILE_ENC_IN_02,   //03      
      REGFILE_ENC_IN_03,   //04    
      REGFILE_ENC_IN_04,   //05  
      REGFILE_ENC_IN_05,   //06  
      REGFILE_ENC_IN_06,   //07  
      REGFILE_DEC_IN_01,   //08  
      REGFILE_DEC_IN_02,   //09 
      REGFILE_DEC_IN_03,   //10 
      REGFILE_DEC_IN_04,   //11 
      REGFILE_DEC_IN_05,   //12 
      REGFILE_DEC_IN_06,   //13 
      REGFILE_DEC_IN_07,   //14 
      REGFILE_DEC_IN_08,   //15 
      REGFILE_ENC_OUT_01,  //16 
      REGFILE_ENC_OUT_02,  //17 
      REGFILE_ENC_OUT_03,  //18 
      REGFILE_ENC_OUT_04,  //19 
      REGFILE_ENC_OUT_05,  //20 
      REGFILE_ENC_OUT_06,  //21 
      REGFILE_ENC_OUT_07,  //22 
      REGFILE_ENC_OUT_08,  //23 
      REGFILE_DEC_OUT_01,  //24 
      REGFILE_DEC_OUT_02,  //25 
      REGFILE_DEC_OUT_03,  //26 
      REGFILE_DEC_OUT_04,  //27 
      REGFILE_DEC_OUT_05,  //28 
      REGFILE_DEC_OUT_06,  //29 
      REGFILE_FIRSTILLEGAL //30 
  }ADDR_E;

  localparam [31:0] MEMADDR_CONFIG	     = 32'h00;//:32'h0003;
  localparam [31:0] MEMADDR_STATUS	     = 32'h04;//:32'h0007;
  localparam [31:0] MEMADDR_ENC_IN_01    = 32'h08;//:encoder input;
  localparam [31:0] MEMADDR_ENC_IN_02    = 32'h0C;//:encoder input;
  localparam [31:0] MEMADDR_ENC_IN_03    = 32'h10;//:encoder input;
  localparam [31:0] MEMADDR_ENC_IN_04    = 32'h14;//:encoder input;
  localparam [31:0] MEMADDR_ENC_IN_05    = 32'h18;//:encoder input;
  localparam [31:0] MEMADDR_ENC_IN_06    = 32'h1C;//:encoder input;
  localparam [31:0] MEMADDR_DEC_IN_01    = 32'h20;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_02    = 32'h24;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_03    = 32'h28;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_04    = 32'h2C;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_05    = 32'h30;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_06    = 32'h34;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_07    = 32'h38;//:decoder input;
  localparam [31:0] MEMADDR_DEC_IN_08    = 32'h3C;//:decoder input;
  localparam [31:0] MEMADDR_ENC_OUT_01	 = 32'h40;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_02	 = 32'h44;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_03	 = 32'h48;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_04	 = 32'h4C;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_05	 = 32'h50;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_06	 = 32'h54;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_07	 = 32'h58;//:encoder output;
  localparam [31:0] MEMADDR_ENC_OUT_08	 = 32'h5C;//:encoder output;
  localparam [31:0] MEMADDR_DEC_OUT_01	 = 32'h60;//:decoder output;
  localparam [31:0] MEMADDR_DEC_OUT_02	 = 32'h64;//:decoder output;
  localparam [31:0] MEMADDR_DEC_OUT_03	 = 32'h68;//:decoder output;
  localparam [31:0] MEMADDR_DEC_OUT_04	 = 32'h6C;//:decoder output;
  localparam [31:0] MEMADDR_DEC_OUT_05	 = 32'h70;//:decoder output;
  localparam [31:0] MEMADDR_DEC_OUT_06	 = 32'h74;//:decoder output;
  localparam [31:0] MEMADDR_FIRSTILLEGAL = 32'h78;//:encoder output;
                                                   
  localparam [31:0] REGFILE_MAX = 31;
  
  localparam       ECMD     = 0;       //Encoder Status (bit addrs)
  localparam       DCMS     = 1;       //Decoder Status (bit addrs)
  localparam       ES       = 0;       //Encoder Status (bit addrs)
  localparam       DS       = 1;       //Decoder Status (bit addrs)
  localparam       EO       = 16;      //Encoder output Status (bit addrs)
  localparam       DO       = 17;      //Decoder output Status (bit addrs)
  localparam [2:0] EQ_0     = 3'b000;  //No errors found
  localparam [2:0] EQ_1     = 3'b001;  //One errors found
  localparam [2:0] EQ_2     = 3'b010;  //Two errors found
  localparam [2:0] EQ_3     = 3'b011;  //Three errors found
  localparam [2:0] EQ_4     = 3'b100;  //Four errors found
  localparam [2:0] EQ_FULL  = 3'b111;  //Too many errors found
  localparam [2:0] EQ_HEAD  = 8;       //Too many errors found
  localparam [2:0] EQ_MIDD  = 9;       //Too many errors found
  localparam [2:0] EQ_TAIL  = 10;      //Too many errors found
  
  logic [31:0] register_bank[ADDR_E] = '{
  	REGFILE_CONFIG       : MEMADDR_CONFIG,
    REGFILE_STATUS       : MEMADDR_STATUS,
    REGFILE_ENC_IN_01    : MEMADDR_ENC_IN_01,
    REGFILE_ENC_IN_02    : MEMADDR_ENC_IN_02,
    REGFILE_ENC_IN_03    : MEMADDR_ENC_IN_03,
    REGFILE_ENC_IN_04    : MEMADDR_ENC_IN_04,
    REGFILE_ENC_IN_05    : MEMADDR_ENC_IN_05,
    REGFILE_ENC_IN_06    : MEMADDR_ENC_IN_06,
    REGFILE_ENC_OUT_01   : MEMADDR_ENC_OUT_01, 
    REGFILE_ENC_OUT_02   : MEMADDR_ENC_OUT_02, 
    REGFILE_ENC_OUT_03   : MEMADDR_ENC_OUT_03, 
    REGFILE_ENC_OUT_04   : MEMADDR_ENC_OUT_04, 
    REGFILE_ENC_OUT_05   : MEMADDR_ENC_OUT_05, 
    REGFILE_ENC_OUT_06   : MEMADDR_ENC_OUT_06, 
    REGFILE_ENC_OUT_07   : MEMADDR_ENC_OUT_07, 
    REGFILE_ENC_OUT_08   : MEMADDR_ENC_OUT_08, 
    REGFILE_DEC_IN_01    : MEMADDR_DEC_IN_01,  
    REGFILE_DEC_IN_02    : MEMADDR_DEC_IN_02,  
    REGFILE_DEC_IN_03    : MEMADDR_DEC_IN_03,  
    REGFILE_DEC_IN_04    : MEMADDR_DEC_IN_04,  
    REGFILE_DEC_IN_05    : MEMADDR_DEC_IN_05,  
    REGFILE_DEC_IN_06    : MEMADDR_DEC_IN_06,  
    REGFILE_DEC_IN_07    : MEMADDR_DEC_IN_07,  
    REGFILE_DEC_IN_08    : MEMADDR_DEC_IN_08,  
    REGFILE_DEC_OUT_01   : MEMADDR_DEC_OUT_01, 
    REGFILE_DEC_OUT_02   : MEMADDR_DEC_OUT_02, 
    REGFILE_DEC_OUT_03   : MEMADDR_DEC_OUT_03, 
    REGFILE_DEC_OUT_04   : MEMADDR_DEC_OUT_04, 
    REGFILE_DEC_OUT_05   : MEMADDR_DEC_OUT_05, 
    REGFILE_DEC_OUT_06   : MEMADDR_DEC_OUT_06, 
    REGFILE_FIRSTILLEGAL : MEMADDR_FIRSTILLEGAL
  };

`endif
