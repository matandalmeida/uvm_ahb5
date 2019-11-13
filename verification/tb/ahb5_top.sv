///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: top
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 08/14/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

module rs_top;
  
  import uvm_pkg::*;
  import rs_pkg::*;

  logic clk;
  logic reset;
  logic fenconding, fdecoding;
  parameter min_cover = 70;
  parameter min_transa = 5000;

  parameter DATA_WIDTH = 32; 
  parameter ADDR_WIDTH = 32;
  parameter STRB_WIDTH = (DATA_WIDTH/8);
  parameter PROT_WIDTH = (DATA_WIDTH/16);
  parameter RESP_WIDTH = (DATA_WIDTH/16);

  initial begin
    clk = 0;
    reset = 1;
    #20 reset = 0;
    #20 reset = 1;
  end

  always #10 clk = !clk;

  always@(reset) uvm_config_db#(int)::set(uvm_root::get(),"*", "reset", reset);

  axi4_lite_if #(.DATA_SIZE(DATA_WIDTH), 
                 .ADDR_SIZE(ADDR_WIDTH))
                dut_if(.ACLK(clk), 
                       .ARESETn(reset));

  reedsolomon rs_sv(.amba(dut_if),
                    .RS_D_interrupt(fdecoding),
                    .RS_E_interrupt(fenconding));

  //sva rs_sva(.amba(dut_if),
  //           .RS_D_interrupt(fdecoding),
  //           .RS_E_interrupt(fenconding));

  initial begin
    `ifdef XCELIUM
       $recordvars();
    `endif
    `ifdef VCS
       $vcdpluson;
    `endif
    `ifdef QUESTA
       $wlfdumpvars();
       set_config_int("*", "recording_detail", 1);
    `endif
  end

  initial begin
    uvm_config_db#(virtual axi4_lite_if#(.ADDR_SIZE(32), .DATA_SIZE(32)))::set(uvm_root::get(), "*", "vif", dut_if);
    uvm_config_db#(int)::set(uvm_root::get(),"*", "min_cover", min_cover);
    uvm_config_db#(int)::set(uvm_root::get(),"*", "min_transa", min_transa);

    run_test("simple_test");
  end

endmodule
