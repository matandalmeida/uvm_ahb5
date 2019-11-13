///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: ahb5_monitor_in
//  DESCRIPTION: Monitor for ahb5_in 
//         BUGS: ---
//       AUTHOR: Matheus Andrade de Almeida (), matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/01/2019 09:31:51 PM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

class ahb5_monitor_in extends uvm_monitor;
  `uvm_component_utils(ahb5_monitor_in)

  vif_mst  vif;
  ahb5_transaction_in  tr_in;
  uvm_analysis_port #(ahb5_transaction_in) req_port;

  typedef enum {CONTROL, READ, WRITE_ADDR, WRITE_DATA, WRITE_ADDR_AND_DATA, READ_WRITE_ADDR, READ_WRITE_DATA, READ_WRITE_ADDR_AND_DATA, RECORD} state_e;

  event begin_record, end_record;
  event hand_w, hand_aw, hand_ar;
  bit wdata, waddr;
  state_e state;
 
  function new(string name, uvm_component parent);
    super.new(name, parent);
    req_port = new("req_port", this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    assert(uvm_config_db#(vif_mst)::get(this, "", "vif", vif));
    tr_in = ahb5_transaction_in::type_id::create("tr_in", this);
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      collect_transactions(phase);
      record_tr();
      wait_hand_ar();
      wait_hand_aw();
      wait_hand_w();
    join
  endtask: run_phase

  virtual task collect_transactions(uvm_phase phase);
    wait (vif.ARESETn === 0);
    @(posedge vif.ARESETn);  
    forever begin
      @(posedge vif.ACLK);
      case(state)
        CONTROL: begin
          if(vif.arvalid && vif.awvalid && vif.wvalid) state = READ_WRITE_ADDR_AND_DATA;
          else if(vif.arvalid && vif.wvalid) state = READ_WRITE_DATA;
          else if(vif.arvalid && vif.awvalid) state = READ_WRITE_ADDR;
          else if(vif.awvalid && vif.wvalid) state = WRITE_ADDR_AND_DATA;
          else if(vif.wvalid) state = WRITE_DATA;
          else if(vif.awvalid) state = WRITE_ADDR;
          else if(vif.arvalid) state = READ;
          else state = CONTROL;
        end
        READ: begin
          ->begin_record;
          @(hand_ar);
          tr_in.araddr = vif.araddr;
          tr_in.arprot = vif.arprot;
          tr_in.control = 3'b001;
          state = RECORD;
        end
        WRITE_ADDR: begin
          ->begin_record;
          @(hand_aw);
          tr_in.awaddr = vif.awaddr;
          tr_in.awprot = vif.awprot;
          tr_in.control = 3'b010;
          waddr = 1;
          if(wdata) state = WRITE_DATA;
          else state = RECORD;
        end
        WRITE_DATA: begin
          ->begin_record;
          @(hand_w);
          tr_in.wdata = vif.wdata;
          tr_in.wstrb = vif.wstrb;
          tr_in.control = 3'b011;
          wdata = 1;
          if(waddr) state = WRITE_ADDR;
          else state = RECORD;
        end
        WRITE_ADDR_AND_DATA: begin
          ->begin_record;
          fork
            @(hand_aw);
            @(hand_w);
          join
          tr_in.wdata = vif.wdata;
          tr_in.wstrb = vif.wstrb;
          tr_in.awaddr = vif.awaddr;
          tr_in.awprot = vif.awprot;
          tr_in.control = 3'b100;
          state = RECORD;
        end
        READ_WRITE_ADDR: begin
          ->begin_record;
          fork
            @(hand_ar);
            @(hand_aw);
          join
          tr_in.araddr = vif.araddr;
          tr_in.arprot = vif.arprot;
          tr_in.awaddr = vif.awaddr;
          tr_in.awprot = vif.awprot;
          tr_in.control = 3'b101;
          waddr = 1;
          if(wdata) state = READ_WRITE_DATA;
          else state = RECORD;
        end
        READ_WRITE_DATA: begin
          ->begin_record;
          fork
            @(hand_ar);
            @(hand_w);
          join
          tr_in.araddr = vif.araddr;
          tr_in.arprot = vif.arprot;
          tr_in.wdata = vif.wdata;
          tr_in.wstrb = vif.wstrb;
          tr_in.control = 3'b110;
          wdata = 1;
          if(waddr) state = READ_WRITE_ADDR;
          else state = RECORD;
        end
        READ_WRITE_ADDR_AND_DATA: begin
          ->begin_record;
          fork
            @(hand_ar);
            @(hand_aw);
            @(hand_w);
          join
          tr_in.araddr = vif.araddr;
          tr_in.arprot = vif.arprot;
          tr_in.awaddr = vif.awaddr;
          tr_in.awprot = vif.awprot;
          tr_in.wdata = vif.wdata;
          tr_in.wstrb = vif.wstrb;
          tr_in.control = 3'b111;
          state = RECORD;
        end
        RECORD: begin
          `uvm_info("UVM_INFO", $sformatf("\nUVM_INFO @ %1d: READ ADDR = %h, WRITE ADDR = %h, WRITE DATA = %h, WRITE STRB = %b, WRITE PROT = %b, READ PROT = %b, CTRL MACHN = %s", $realtime, vif.araddr, vif.awaddr, vif.wdata, vif.wstrb, vif.awprot, vif.arprot, tr_in.control.name()), UVM_MEDIUM);
          req_port.write(tr_in);
          ->end_record;
          state = CONTROL;
        end
      endcase
    end
  endtask: collect_transactions

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
  endtask: wait_hand_w

  virtual task record_tr();
    forever begin
      @(begin_record);
      begin_tr(tr_in, "MONITOR IN");
      @(end_record);
      end_tr(tr_in);
    end
  endtask: record_tr

endclass: ahb5_monitor_in
