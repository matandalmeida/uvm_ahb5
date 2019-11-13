///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: rs_sva
//  DESCRIPTION: Asserts for verification
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 11/01/2019 09:19:09 AM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

module rs_sva(
	axi4_lite_if.slave amba,
	output logic RS_D_interrupt, 
	output logic RS_E_interrupt
);

  logic [31:0] addr = amba.araddr >> 2;
  logic [31:0] addw = amba.awaddr >> 2;

  

endmodule 
