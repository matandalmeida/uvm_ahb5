///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_pkg
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 08/14/2019 02:05:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
package rs_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "./rs_types.svh"
  `include "./ahb5_transaction_in.sv"
  `include "./ahb5_transaction_out.sv"
  
  
  `include "./ahb5_sequence.sv"
  `include "./ahb5_driver_in.sv"
  `include "./ahb5_monitor_in.sv"
  `include "./ahb5_agent_mst.sv"
  
  `include "./ahb5_driver_out.sv"
  `include "./ahb5_monitor_out.sv"
  `include "./ahb5_agent_out.sv"

  `include "./rs_refmod.sv"
  `include "./rs_cover.sv"
  `include "./rs_scoreboard.sv"
  `include "./rs_env.sv"

  `include "./rs_test.sv"

endpackage: rs_pkg
