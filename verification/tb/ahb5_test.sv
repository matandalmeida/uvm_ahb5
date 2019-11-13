///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: rs_test
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 08/14/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class rs_test extends uvm_test;
  `uvm_component_utils(rs_test)

  rs_env env_h;
  ahb5_sequence seq;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env_h = rs_env::type_id::create("env_h", this);
    seq = ahb5_sequence::type_id::create("seq", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    seq.start(env_h.mst_in.sqr);
  endtask: run_phase

endclass: rs_test
