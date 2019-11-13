///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_transaction_in
//  DESCRIPTION: Master transaction_in
//         BUGS: ---
//       AUTHOR: Matheus Andrade Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 10:32:13 AM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

typedef enum bit [2:0] {ERROR, READ, WRITE_ADDR, WRITE_DATA, WRITE_ADDR_AND_DATA, READ_WRITE_ADDR, READ_WRITE_DATA, READ_WRITE_ADDR_AND_DATA} tr_state_e;
class ahb5_transaction_in #(parameter DATA_WIDTH = 32, 
                                parameter ADDR_WIDTH = 32,
                                parameter STRB_WIDTH = (DATA_WIDTH/8),
                                parameter PROT_WIDTH = (DATA_WIDTH/16),
                                parameter RESP_WIDTH = (DATA_WIDTH/16)) 
                                extends uvm_sequence_item;


  rand bit [ADDR_WIDTH-1:0] araddr;
  rand bit [ADDR_WIDTH-1:0] awaddr;
  rand bit [DATA_WIDTH-1:0] wdata;
  rand bit [STRB_WIDTH-1:0] wstrb;
  rand bit [PROT_WIDTH-1:0] awprot;
  rand bit [PROT_WIDTH-1:0] arprot;
  rand tr_state_e              control;

  constraint constantes{
    control != ERROR;
    awaddr == MEMADDR_ENC_OUT_02;
    //awaddr <= MEMADDR_FIRSTILLEGAL;
    araddr == MEMADDR_ENC_OUT_02;
    //araddr <= MEMADDR_FIRSTILLEGAL;
  }


  function new(string name = "");
    super.new(name);
  endfunction: new

  `uvm_object_utils_begin(ahb5_transaction_in)
    `uvm_field_int(araddr , UVM_ALL_ON|UVM_HEX)
    `uvm_field_int(awaddr , UVM_ALL_ON|UVM_HEX)
    `uvm_field_int(wdata  , UVM_ALL_ON|UVM_HEX)
    `uvm_field_int(wstrb  , UVM_ALL_ON|UVM_BIN)
    `uvm_field_int(awprot , UVM_ALL_ON|UVM_BIN)
    `uvm_field_int(arprot , UVM_ALL_ON|UVM_BIN)
    `uvm_field_enum(tr_state_e, control, UVM_ALL_ON|UVM_ENUM)
  `uvm_object_utils_end

  function string convert2string();
      return $sformatf("{AWADDR = %h, AWPROT = %h, WDATA = %h, WSTRB = %h, ARADDR = %h, ARPROT = %h, CONTROL = %s}", 
                         awaddr, awprot, wdata, wstrb, araddr, arprot, control.name());
  endfunction: convert2string

endclass: ahb5_transaction_in
