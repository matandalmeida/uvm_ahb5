///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_monitor_out
//  DESCRIPTION: Monitor for ahb5_out
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 10:33:47 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class ahb5_monitor_out extends uvm_monitor;
  `uvm_component_utils(ahb5_monitor_out)

  vif_mst  vif;
  ahb5_transaction_out tr_out;
  uvm_analysis_port #(ahb5_transaction_out) resp_port;

  typedef enum {CONTROL, READ, WRITE, READ_AND_WRITE, RECORD} state_e;
  state_e state;
  event begin_record, end_record;
  event hand_r, hand_b;
 
  function new(string name, uvm_component parent);
    super.new(name, parent);
    resp_port = new("resp_port", this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(vif_mst)::get(this, "", "vif", vif));
    tr_out = ahb5_transaction_out::type_id::create("tr_out", this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      collect_transactions(phase);
      record_tr();
      wait_hand_b();
      wait_hand_r();
    join
  endtask: run_phase

  virtual task collect_transactions(uvm_phase phase);
    wait (vif.ARESETn === 0);
    @(posedge vif.ARESETn);  
    forever begin
      @(posedge vif.ACLK);
      case(state) 
        CONTROL:begin
          if((vif.bready) && (vif.rready)) state = READ_AND_WRITE;
          else if(vif.rready) state = READ;
          else if(vif.bready) state = WRITE;
          else state = CONTROL;
        end
        READ: begin
          @(hand_r);
          ->begin_record;
          tr_out.rresp = vif.rresp;
          tr_out.rdata = vif.rdata;
          state = RECORD;
        end
        WRITE: begin
          @(hand_b);
          ->begin_record;
          tr_out.bresp = vif.bresp;
          state = RECORD;
        end
        READ_AND_WRITE: begin
          fork
            @(hand_r);
            @(hand_b);
          join
          ->begin_record;
          tr_out.bresp = vif.bresp;
          tr_out.rresp = vif.rresp;
          tr_out.rdata = vif.rdata;
          state = RECORD;
        end
        RECORD: begin
          resp_port.write(tr_out);
          ->end_record;
          state = CONTROL;
        end
      endcase
    end
  endtask: collect_transactions

  virtual task wait_hand_r();
    forever begin
      wait(vif.rvalid && vif.rready) begin
        @(posedge vif.ACLK) begin
          ->hand_r;
        end
      end
    end
  endtask: wait_hand_r

  virtual task wait_hand_b();
    forever begin
      wait(vif.bvalid && vif.bready) begin
        @(posedge vif.ACLK) begin
          ->hand_b;
        end
      end
    end
  endtask: wait_hand_b

  virtual task record_tr();
    forever begin
      @(begin_record);
      begin_tr(tr_out, "MONITOR OUT");
      @(end_record);
      end_tr(tr_out);
    end
  endtask: record_tr

endclass: ahb5_monitor_out
