///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: rs_cover
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 08/14/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

`uvm_analysis_imp_decl(_req)
`uvm_analysis_imp_decl(_resp)

class rs_cover extends uvm_component;
  `uvm_component_utils(rs_cover)

  ahb5_transaction_in req;
  ahb5_transaction_out resp;

  uvm_analysis_imp_req#(ahb5_transaction_in, rs_cover) req_port;
  uvm_analysis_imp_resp#(ahb5_transaction_out, rs_cover) resp_port;

  int min_cover = 100;
  int min_transa = 5120;
  int transa = 0;

  event end_of_simulation;

  function new(string name = "rs_cover", uvm_component parent= null);
    super.new(name, parent);
    req_port = new("req_port", this);        
    resp_port = new("resp_port", this);
    resp=new;        
    req=new;
    min_transa = 5000;
    min_cover = 80;
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase (phase);
    uvm_config_db#(int)::get(this, "", "min_cover", min_cover);
    uvm_config_db#(int)::get(this, "", "min_transa", min_transa);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);        
    @(end_of_simulation);
    phase.drop_objection(this);    
  endtask: run_phase

//============= Função para copiar transações do agent (Requisições) ======================
  function void write_req(ahb5_transaction_in tr_req);
    req.copy (tr_req);
    if(transa >= min_transa)begin
      `uvm_info("UVM_INFO", "\n\n===================================================================================================OVER SIMULATION===================================================================================================", UVM_MEDIUM);
      ->end_of_simulation;
    end
    transa = transa + 1;
  endfunction: write_req

//============= Função para copiar transações do agent (Respostas) ========================
  function void write_resp(ahb5_transaction_out tr_resp);
    //if($get_coverage() >= min_cover) begin
    // $display("Dropou Cover");
    // ->end_of_simulation;
    //end
  endfunction: write_resp

endclass: rs_cover
