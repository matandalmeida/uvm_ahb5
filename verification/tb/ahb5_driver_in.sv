///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_driver_in
//  DESCRIPTION: Driver for axir4lite_in 
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 02:00:25 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

typedef virtual axi4_lite_if #(.DATA_SIZE(32), .ADDR_SIZE(32)) vif_mst;

class ahb5_driver_in extends uvm_driver #(ahb5_transaction_in);
  `uvm_component_utils(ahb5_driver_in)

  typedef enum {CONTROL, READ, WRITE_ADDR, WRITE_DATA, WRITE_ADDR_AND_DATA, READ_WRITE_ADDR, READ_WRITE_DATA, READ_WRITE_ADDR_AND_DATA, RECORD} state_e;

  vif_mst vif;
  ahb5_transaction_in tr_in;

  event begin_record,end_record;
  state_e state;
  bit wdata, waddr, item_done, read;
  int tr;

  function new(string name = "ahb5_driver_in", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(vif_mst)::get(this, "", "vif", vif));
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
//------------------ Write address channel ----------------------------
      vif.awvalid = 0;  
      vif.awaddr = 0;
      vif.awprot = 0;
//------------------ Write data channel -------------------------------
      vif.wvalid = 0;
      vif.wdata = 0;
      vif.wstrb = 0;
//------------------ Read address channel -----------------------------
      vif.arvalid = 0;
      vif.araddr = 0;
      vif.arprot = 0;
//------------------ Internal signals ---------------------------------
      state = CONTROL;
      wdata = 0;
      waddr = 0;
      read = 0;
      item_done = 0;
      tr = 0;
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
          if ((item_done || !tr_in) && vif.ARESETn) begin
            item_done = 0;
            seq_item_port.get_next_item(tr_in);
            `uvm_info("UVM_INFO", $sformatf("\n\n==================================================================================================TRANSACTION %1d===================================================================================================", tr), UVM_MEDIUM);
            tr = tr + 1;
            ->begin_record;
            //if(tr_in.control === 3'b000) `uvm_fatal("UVM_FATAL", "INVALID DRIVER IN STATE");
            if(tr_in.control === 3'b001) state = READ;
            else if(tr_in.control === 3'b010) state = WRITE_ADDR;
            else if(tr_in.control === 3'b011) state = WRITE_DATA;
            else if(tr_in.control === 3'b100) state = WRITE_ADDR_AND_DATA;
            else if(tr_in.control === 3'b101) state = READ_WRITE_ADDR;
            else if(tr_in.control === 3'b110) state = READ_WRITE_DATA;
            else if(tr_in.control === 3'b111) state = READ_WRITE_ADDR_AND_DATA;
            else state = CONTROL;
          end
          else state = CONTROL;
        end
        READ: begin
          vif.araddr  <= tr_in.araddr;
          vif.arprot  <= tr_in.arprot;
          vif.arvalid <= 1;
          state = RECORD;
        end
        WRITE_ADDR: begin
          vif.awaddr  <= tr_in.awaddr;
          vif.awprot  <= tr_in.awprot;
          vif.awvalid <= 1;
          waddr = 1;
          if(wdata) state = RECORD;
          else state = WRITE_DATA;
        end
        WRITE_DATA: begin
          vif.wdata  <= tr_in.wdata;
          vif.wstrb  <= tr_in.wstrb;
          vif.wvalid <= 1;
          wdata = 1;
          if(waddr) state = RECORD;
          else state = WRITE_ADDR;
        end
        WRITE_ADDR_AND_DATA: begin
          vif.awaddr  <= tr_in.awaddr;
          vif.awprot  <= tr_in.awprot;
          vif.awvalid <= 1;
          vif.wdata  <= tr_in.wdata;
          vif.wstrb  <= tr_in.wstrb;
          vif.wvalid <= 1;
          state = RECORD;
        end
        READ_WRITE_ADDR: begin
          vif.awaddr  <= tr_in.awaddr;
          vif.awprot  <= tr_in.awprot;
          vif.awvalid <= 1;
          waddr = 1;
          if(read) begin
            vif.araddr  <= tr_in.araddr;
            vif.arprot  <= tr_in.arprot;
            vif.arvalid <= 1;
            read = 1;
          end
          if(wdata) state = RECORD;
          else state = READ_WRITE_DATA;
        end
        READ_WRITE_DATA: begin
          vif.wdata  <= tr_in.wdata;
          vif.wstrb  <= tr_in.wstrb;
          vif.wvalid <= 1;
          wdata = 1;
          if(read) begin
            vif.araddr  <= tr_in.araddr;
            vif.arprot  <= tr_in.arprot;
            vif.arvalid <= 1;
            read = 1;
          end
          if(waddr) state = RECORD;
          else state = READ_WRITE_ADDR;
        end
        READ_WRITE_ADDR_AND_DATA: begin 
          vif.awaddr  <= tr_in.awaddr;
          vif.awprot  <= tr_in.awprot;
          vif.awvalid <= 1;
          vif.wdata  <= tr_in.wdata;
          vif.wstrb  <= tr_in.wstrb;
          vif.wvalid <= 1;
          vif.araddr  <= tr_in.araddr;
          vif.arprot  <= tr_in.arprot;
          vif.arvalid <= 1;
          state = RECORD;
        end
        RECORD: begin
          if(item_done) begin
            seq_item_port.item_done();
            ->end_record;
            wdata = 0;
            waddr = 0;
            read = 0;
            state = CONTROL;
          end
          else state = RECORD;
        end
      endcase
    end
  endtask: get_and_driver

  virtual task wait_hand_r();
    forever begin
      wait(vif.rvalid && vif.rready) begin
        @(posedge vif.ACLK) begin
          item_done = 1;
        end
      end
    end
  endtask: wait_hand_r

  virtual task wait_hand_b();
    forever begin
      wait(vif.bvalid && vif.bready) begin
        @(posedge vif.ACLK) begin
          item_done = 1;
        end
      end
    end
  endtask: wait_hand_b

  virtual task wait_hand_ar();
    forever begin
      wait(vif.arvalid && vif.arready) begin
        @(posedge vif.ACLK) begin
          vif.arvalid <= 0;
        end
      end
    end
  endtask: wait_hand_ar

  virtual task wait_hand_aw();
    forever begin
      wait(vif.awvalid && vif.awready) begin
          @(posedge vif.ACLK) begin
          vif.awvalid <= 0;
        end
      end
    end
  endtask: wait_hand_aw

  virtual task wait_hand_w();
    forever begin
      wait(vif.wvalid && vif.wready) begin
        @(posedge vif.ACLK) begin
          vif.wvalid <= 0;
        end
      end
    end
  endtask: wait_hand_w

  virtual task record_tr();
    forever begin
      @(begin_record);
      begin_tr(tr_in, "DRIVER IN");
      @(end_record);
      end_tr(tr_in);
    end
  endtask: record_tr

endclass: ahb5_driver_in
