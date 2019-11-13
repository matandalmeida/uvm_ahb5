///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_agent_mst
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 12:46:23 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class ahb5_agent_mst extends uvm_agent;
  `uvm_component_utils(ahb5_agent_mst)

    typedef uvm_sequencer#(ahb5_transaction_in) ahb5_sequencer;
    ahb5_sequencer   sqr;
    ahb5_driver_in   drv_in;
    ahb5_monitor_in  mon_in;

    uvm_analysis_port #(ahb5_transaction_in) agt_req_port;

    function new(string name = "ahb5_agent_mst", uvm_component parent = null);
      super.new(name, parent);
      agt_req_port = new("agt_req_port", this);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon_in = ahb5_monitor_in::type_id::create("mon_in", this);
      drv_in = ahb5_driver_in::type_id::create("drv_in", this);
      sqr    = ahb5_sequencer::type_id::create("sqr", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      mon_in.req_port.connect(agt_req_port);
      drv_in.seq_item_port.connect(sqr.seq_item_export);
    endfunction: connect_phase

endclass: ahb5_agent_mst
