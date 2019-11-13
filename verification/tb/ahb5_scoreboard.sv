///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: rs_scoreboard
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 08/14/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class rs_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(rs_scoreboard)
   
   typedef ahb5_transaction_out T;
   typedef uvm_in_order_class_comparator #(T) comp_type;

   rs_refmod rfm;
   comp_type comp;

   uvm_analysis_port #(T) ap_comp;
   uvm_analysis_port #(ahb5_transaction_in) ap_rfm;


   function new(string name="rs_scoreboard", uvm_component parent = null);
     super.new(name, parent);
     ap_comp = new("ap_comp", this);
     ap_rfm = new("ap_rfm", this);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     rfm = rs_refmod::type_id::create("rfm", this);
     comp = comp_type::type_id::create("comp", this);
   endfunction: build_phase
   
   virtual function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     ap_comp.connect(comp.before_export);
     ap_rfm.connect(rfm.in);
     rfm.out.connect(comp.after_export);
   endfunction: connect_phase

endclass: rs_scoreboard
