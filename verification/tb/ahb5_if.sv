///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_if
//  DESCRIPTION: AXI$_LITE Interface
//         BUGS: ---
//       AUTHOR: Matheus Almeida , matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 09:55:24 AM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

interface ahb5_if (input logic HCLK, 
                   input logic HRESETn);

  localparam ADDR_WIDTH   = 32;
  localparam DATA_WIDTH   = 32;
  localparam PROT_WIDTH   = 7;
  localparam BURST_WIDTH  = 3;
  localparam SIZE_WIDTH   = 3;
  localparam TRANS_WIDTH  = 2;
  localparam MASTER_WIDTH = 1; //Number of master on the bus

//------------------ Address and Control ------------------------------
  logic [ADDR_WIDTH-1:0  ] HADDR; 
  logic [SIZE_WIDTH-1:0  ] HSIZE;
  logic [PROT_WIDTH-1:0  ] HPROT;
  logic [TRANS_WIDTH-1:0 ] HTRANS;
  logic [BURST_WIDTH-1:0 ] HBURST;
  logic [MASTER_WIDTH-1:0] HMASTER;
  logic                    HWRITE;
  logic                    HMASTLOCK;
  logic                    HNONSEC;
  logic                    HEXCL;
//------------------------ Data ---------------------------------------
  logic [DATA_WIDTH-1:0  ] HWDATA;
  logic [DATA_WIDTH-1:0  ] HRDATA;
//------------------ Transfer Response --------------------------------
  logic                    HREADY;
  logic                    HREADYOUT;
  logic                    HEXOKAY;
  logic                    HRESP;
//----------------------- Select --------------------------------------
  logic                    HSEL_X;//An address decoder provides a select signal, HSELx, for each slave on the bus. EX: HSEL_S1, HSEL_S2, ...

  modport master(
    input  HCLK,
    input  HRESETn,
    input  HRDATA,
    input  HREADY,
    input  HRESP,  
    output HADDR, 
    output HWRITE,
    output HSIZE,
    output HBURST,
    output HPROT,
    output HTRANS,
    output HMASTLOCK,
    output HWDATA
  );

  modport slave(
    input  HCLK,
    input  HRESETn,
    input  HSEL_X,
    input  HADDR, 
    input  HWRITE,
    input  HSIZE,
    input  HBURST,
    input  HPROT,
    input  HTRANS,
    input  HMASTLOCK,
    input  HREADY,
    output HREADYOUT,
    output HRESP,  
    output HRDATA
  );

endinterface: ahb5_if
