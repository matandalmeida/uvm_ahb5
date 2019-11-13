///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_driver_out
//  DESCRIPTION: Driver for ahb5_out
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 10:03:32 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class ahb5_driver_out extends uvm_driver #(ahb5_transaction_out);
  `uvm_component_utils(ahb5_driver_out)

  typedef enum {CONTROL, READ, WRITE, READ_AND_WRITE, RECORD} state_e;

  vif_mst vif;
  ahb5_transaction_out tr_out;

  state_e state;
  event begin_record,end_record;
  event hand_ar, hand_aw, hand_w;
  bit [1:0] rwb;
  bit item_done;

  function new(string name = "ahb5_driver_out", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(vif_mst)::get(this, "", "vif", vif));
    tr_out = ahb5_transaction_out::type_id::create("tr_out", this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      reset_signals();
      get_and_driver(phase);
      record_tr();
      wait_hand_ar();
      wait_hand_aw();
      wait_hand_w();
      wait_hand_r();
      wait_hand_b();
    join
  endtask: run_phase

  virtual task reset_signals();
    wait (vif.ARESETn === 0);
    forever begin
//------------------ Write response channel ---------------------------
      vif.bready = 0;
//------------------- Read data channel --------------------------------
      vif.rready = 0;
//------------------ Internal signals ---------------------------------
      state = CONTROL;
      rwb = 0;
      item_done = 0;
    @(posedge vif.ARESETn);
    end
  endtask: reset_signals

  virtual task get_and_driver(uvm_phase phase);
    wait(vif.ARESETn === 0);
    @(posedge vif.ARESETn);
    forever begin
      @(posedge vif.ACLK);
      case(state)        
        CONTROL: begin
          item_done = 0;
          rwb = $urandom_range(3,1);
          if(vif.arvalid && (vif.awvalid || vif.wvalid)) state = READ_AND_WRITE;
          else if(vif.awvalid || vif.wvalid) state = WRITE;
          else if(vif.arvalid) state = READ;
          ->begin_record;
        end
        READ: begin
          @(hand_ar);
          vif.rready <= 1;
          tr_out.rdata <= vif.rdata;
          tr_out.rresp <= vif.rresp;
          state = RECORD;
        end
        WRITE: begin
          @(hand_aw or hand_w);
          vif.bready <= 1;
          tr_out.bresp <= vif.bresp;
          state = RECORD;
        end
        READ_AND_WRITE: begin
          fork
            @(hand_ar);
            @(hand_aw or hand_w);
          join
          vif.bready <= 1;
          vif.rready <= 1;
          tr_out.rdata <= vif.rdata;
          tr_out.rresp <= vif.rresp;
          tr_out.bresp <= vif.bresp;
          state = RECORD;
        end
        RECORD: begin
          if(item_done) begin
            ->end_record;
            state = CONTROL;
          end
          else state = RECORD;
        end
      endcase
    end
  endtask: get_and_driver

  virtual task wait_hand_ar();
    forever begin
      wait(vif.arvalid && vif.arready) begin
        @(posedge vif.ACLK) begin
          ->hand_ar;
        end
      end
    end
  endtask: wait_hand_ar

  virtual task wait_hand_aw();
    forever begin
      wait(vif.awvalid && vif.awready) begin
        @(posedge vif.ACLK) begin
          ->hand_aw;
        end
      end
    end
  endtask: wait_hand_aw

  virtual task wait_hand_w();
    forever begin
      wait(vif.wvalid && vif.wready) begin
        @(posedge vif.ACLK) begin
          ->hand_w;
        end
      end
    end
  endtask

  virtual task wait_hand_r();
    forever begin
      wait(vif.rvalid && vif.rready) begin
        @(posedge vif.ACLK) begin
          item_done = 1;
          vif.rready <= 0;
        end
      end
    end
  endtask: wait_hand_r

  virtual task wait_hand_b();
    forever begin
      wait(vif.bvalid && vif.bready) begin
          @(posedge vif.ACLK) begin
            item_done = 1;
            vif.bready <= 0;
        end
      end
    end
  endtask: wait_hand_b

  virtual task record_tr();
    forever begin
      @(begin_record);
      begin_tr(tr_out, "DRIVER OUT");
      @(end_record);
      end_tr(tr_out);
    end
  endtask: record_tr

 endclass: ahb5_driver_out
