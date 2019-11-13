///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_sequence
//  DESCRIPTION: Randon sequence
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 01:18:06 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class ahb5_sequence extends uvm_sequence #(ahb5_transaction_in);    
  `uvm_object_utils(ahb5_sequence)

  function new(string name="ahb5_sequence");
    super.new(name);
  endfunction: new

  task body;
    ahb5_transaction_in tr;
    forever begin
      tr = ahb5_transaction_in::type_id::create("tr");
      start_item(tr);
        assert(tr.randomize() with{tr.control == 3'b001 /*|| tr.control == 3'b010*/ || tr.control == 3'b100;});
      finish_item(tr);
    end
  endtask: body

endclass: ahb5_sequence
