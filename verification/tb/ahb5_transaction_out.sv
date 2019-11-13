///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_transaction_out
//  DESCRIPTION: Master transaction_out 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 12:34:10 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////
 
class ahb5_transaction_out #(parameter DATA_WIDTH = 32, 
                                 parameter ADDR_WIDTH = 32,
                                 parameter STRB_WIDTH = (DATA_WIDTH/8),
                                 parameter PROT_WIDTH = (DATA_WIDTH/16),
                                 parameter RESP_WIDTH = (DATA_WIDTH/16)) 
                                 extends uvm_sequence_item;

  rand bit [DATA_WIDTH-1:0] rdata;
  rand bit [RESP_WIDTH-1:0] rresp;
  rand bit [RESP_WIDTH-1:0] bresp;
 
  constraint constantes{
    rresp != 2'b01;
    bresp != 2'b01;
  }

  function new(string name = "");
    super.new(name);
  endfunction: new

  `uvm_object_utils_begin(ahb5_transaction_out)
    `uvm_field_int(rdata, UVM_ALL_ON|UVM_HEX)
    `uvm_field_int(rresp, UVM_ALL_ON|UVM_HEX)
    `uvm_field_int(bresp, UVM_ALL_ON|UVM_HEX)
  `uvm_object_utils_end

  function string convert2string();
      return $sformatf(": { READ DATA = %h,  READ RESP = %h,  WRITE RESP = %h } ", rdata, rresp, bresp);
  endfunction: convert2string

endclass: ahb5_transaction_out
