///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: rs_env
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 08/14/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class rs_env extends uvm_env;
  `uvm_component_utils(rs_env)

  ahb5_agent_mst    mst_in;
  ahb5_agent_out   mst_out;
  rs_scoreboard  sb;
  rs_cover       cov;


  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mst_in  = ahb5_agent_mst::type_id::create("mst_in", this);
    mst_out = ahb5_agent_out::type_id::create("mst_out", this);
    sb      = rs_scoreboard::type_id::create("sb", this);
    cov     = rs_cover::type_id::create("cov",this);
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mst_in.agt_req_port.connect(cov.req_port);
    mst_out.agt_resp_port.connect(cov.resp_port);
    mst_in.agt_req_port.connect(sb.ap_rfm);
    mst_out.agt_resp_port.connect(sb.ap_comp);
  endfunction: connect_phase

endclass: rs_env
