///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_agent_out
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 10:44:17 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class ahb5_agent_out extends uvm_agent;
  `uvm_component_utils(ahb5_agent_out)

    ahb5_driver_out  drv_out;
    ahb5_monitor_out mon_out;

    uvm_analysis_port #(ahb5_transaction_out) agt_resp_port;

    function new(string name = "ahb5_agent_out", uvm_component parent = null);
      super.new(name, parent);
      agt_resp_port = new("agt_resp_port", this);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon_out = ahb5_monitor_out::type_id::create("mon_out", this);
      drv_out = ahb5_driver_out::type_id::create("drv_out", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      mon_out.resp_port.connect(agt_resp_port);
    endfunction: connect_phase

endclass: ahb5_agent_out
