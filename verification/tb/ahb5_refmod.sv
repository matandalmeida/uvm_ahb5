///////////////////////////////////////////////////////////////////////////////////////////////////
//
//        CLASS: rs_refmod
//  DESCRIPTION: 
//         BUGS: ---
//       AUTHOR: Matheus Almeida, matheus.almeida@embedded.ufcg.edu.br
// ORGANIZATION: XMEN - Laboratorio de Excelencia em Microeletronica do Nordeste 
//      VERSION: 1.0
//      CREATED: 10/03/2019 10:55:25 AM
//     REVISION: ---
///////////////////////////////////////////////////////////////////////////////////////////////////

typedef int a23[23];
typedef int a31[31];

import "DPI-C" context function void encoder(input a23 data, output a31 encodedata);
import "DPI-C" context function void decoder(input a31 data2decode, output a23 data_decoded, output int nerror, output int lambda_degree);

class rs_refmod extends uvm_component;
  `uvm_component_utils(rs_refmod)
  
  typedef enum {INIT, READ, WRITE_ADDR, WRITE_DATA, WRITE_ADDR_AND_DATA, READ_WRITE_ADDR, READ_WRITE_DATA, READ_WRITE_ADDR_AND_DATA, RECORD, ERROR} control_e;
  localparam AXI4_RESP_B_OKAY   = 2'b00;
  localparam AXI4_RESP_B_SLVERR = 2'b10;

  ahb5_transaction_in tr_in;
  ahb5_transaction_out tr_out;

  uvm_analysis_imp #(ahb5_transaction_in, rs_refmod) in;
  uvm_analysis_port #(ahb5_transaction_out) out;

  control_e state_control;

  event begin_record_in, end_record_in;
  event begin_record_out, end_record_out;
  event begin_refmodtask;
  event compare;
  event write_reg, read_reg; 
  event start_encode, start_decode;
  event done_enc, done_dec;
  event over_read_reg, over_write_reg, codificator, decodificator;

  bit [31:0] addr, addw;
  bit [2:0] control;
  bit read_err, write_err;
  bit reset;

  a23 encoder_data; // Input encoder
  a31 encoded_data; // Output encoder
  a31 decoder_data; // Input decoder
  a23 decoded_data; // Output decoder
  int num_error, l_degree;
    
  function new(string name = "rs_refmod", uvm_component parent);
    super.new(name, parent);
    in = new("in", this);
    out = new("out", this);
  endfunction: new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(int)::get(this, "", "reset", reset);
  endfunction: build_phase

  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      fork
        get_reset();
        reset_tr();
        amba_ahb5();
        record_tr_in();
        record_tr_out();
      join
    end
  endtask: run_phase

  virtual function write (ahb5_transaction_in t);
    tr_in = ahb5_transaction_in#()::type_id::create("tr_in", this);
    ->begin_record_in;
    tr_in.copy(t);
    ->end_record_in;
    ->begin_refmodtask;
  endfunction: write
  
  virtual task get_reset();
    forever begin
      uvm_config_db#(int)::wait_modified(this, "", "reset");
      uvm_config_db#(int)::get(this, "", "reset", reset);
    end
  endtask: get_reset

  virtual task reset_tr();
    forever begin
      wait(reset === 0) begin
        foreach(register_bank[i])  register_bank[i]  = 32'h00000000;
        foreach(encoder_data[i]) encoder_data[i] = '0;
        foreach(encoded_data[i]) encoded_data[i] = '0;
        foreach(decoder_data[i]) decoder_data[i] = '0;
        foreach(decoded_data[i]) decoded_data[i] = '0;
        addr = '0;
        addw = '0; 
        read_err = 0;
        write_err = 0;
        state_control = INIT;
        @(posedge reset);
      end
    end
  endtask: reset_tr

  virtual task amba_ahb5();
    wait(reset === 0);
    @(posedge reset);
    forever begin
      tr_out = ahb5_transaction_out::type_id::create("tr_out", this);
      fork
        write_register();
        read_register();
        encoder_task();
        decoder_task();
        control_machine();
      join
    end
  endtask: amba_ahb5

  virtual task control_machine();
    forever begin
      case(state_control)
        INIT: begin
          @(begin_refmodtask);
          control = tr_in.control;
          case(control)
            3'b000: state_control = ERROR;
            3'b001: state_control = READ;
            3'b010: state_control = WRITE_ADDR;
            3'b011: state_control = WRITE_DATA;
            3'b100: state_control = WRITE_ADDR_AND_DATA;
            3'b101: state_control = READ_WRITE_ADDR;
            3'b110: state_control = READ_WRITE_DATA;
            3'b111: state_control = READ_WRITE_ADDR_AND_DATA;
          endcase
        end
        READ: begin
          ->read_reg;
          ->begin_record_out;
          state_control = RECORD;
        end
        WRITE_ADDR: begin
          ->write_reg;
          ->begin_record_out;
          state_control = RECORD;
        end 
        WRITE_DATA: begin
          ->write_reg;
          ->begin_record_out;
          state_control = RECORD;
        end 
        WRITE_ADDR_AND_DATA: begin
          ->write_reg;
          ->begin_record_out;
          state_control = RECORD;
        end
        READ_WRITE_ADDR: begin 
          ->read_reg;
          ->write_reg;
          ->begin_record_out;
          state_control = RECORD;
        end
        READ_WRITE_DATA: begin
          ->read_reg;
          ->write_reg;
          ->begin_record_out;
          state_control = RECORD;
        end
        READ_WRITE_ADDR_AND_DATA: begin
          ->read_reg;
          ->write_reg;
          ->begin_record_out;
          state_control = RECORD;
        end
        RECORD: begin
          fork
            @(over_read_reg);
            @(over_write_reg);
            @(codificator);
            @(decodificator);
          join_any
          out.write(tr_out);
          $display("DEU WRITE REFMOD OUT");
          ->end_record_out;
          state_control = INIT;
        end
        ERROR:begin
          `uvm_fatal("UVM_FATAL", "INVALID VALUE FOR CONTROL");
        end
      endcase
    end
  endtask: control_machine

  virtual task read_register();
    forever begin
      @(read_reg);
      addr = tr_in.araddr >> 2;
      read_err  = ((addr === REGFILE_CONFIG) && (register_bank[REGFILE_CONFIG][1:0] !== 00));
      read_err |= (((addr >= REGFILE_ENC_OUT_01) && (addr <= REGFILE_ENC_OUT_08)) && (register_bank[REGFILE_STATUS][ES]));
      read_err |= (((addr >= REGFILE_DEC_OUT_01) && (addr <= REGFILE_DEC_OUT_06)) && (register_bank[REGFILE_STATUS][DS]));
      read_err |= ((addr < REGFILE_CONFIG) && (addr > REGFILE_DEC_OUT_06));

      if((addr >= REGFILE_CONFIG) && (addr <= REGFILE_DEC_OUT_06)) begin
        tr_out.rdata = register_bank[addr];
        tr_out.rresp = (read_err) ? AXI4_RESP_B_SLVERR : AXI4_RESP_B_OKAY;
      end
      else begin
        tr_out.rdata = 32'b0;
        tr_out.rresp = AXI4_RESP_B_SLVERR;
      end
      ->over_read_reg;
      $display("TERMINEI DE LER");
    end
  endtask: read_register

  virtual task write_register();
    forever begin
      @(write_reg);
      addw = tr_in.awaddr >> 2;
      write_err  = (((addw >= REGFILE_ENC_OUT_01) && (addw <= REGFILE_ENC_OUT_08)) || ((addw >= REGFILE_DEC_OUT_01) && (addw <= REGFILE_DEC_OUT_06)));
      write_err |= (((addw >= REGFILE_ENC_IN_01) && (addw <= REGFILE_ENC_IN_06)) && (register_bank[REGFILE_STATUS][ES]));
      write_err |= (((addw >= REGFILE_DEC_IN_01) && (addw <= REGFILE_DEC_IN_08)) && (register_bank[REGFILE_STATUS][DS]));
      write_err |= ((addw === REGFILE_STATUS));
      write_err |= ((addw < REGFILE_CONFIG) && (addw > REGFILE_DEC_OUT_06));

      //Write in Configuration Register
      if((addw == REGFILE_CONFIG) && !write_err) begin
        register_bank[addw][31:2] = '0;
        register_bank[addw][1:0] = (tr_in.wstrb[0]) ? tr_in.wdata[1:0] : register_bank[addw][1:0]; 
        tr_out.bresp = AXI4_RESP_B_OKAY;
      end

      //Write in Encoder and Decoder Input Register
      else if((addw >= REGFILE_STATUS) && (addw <= REGFILE_DEC_OUT_06) && !write_err) begin
        if(tr_in.wstrb === 4'b0000) register_bank[addw] = tr_in.wdata;
        else begin
          for(int i = 0; i < 4; i++) begin
            register_bank[addw][i*8+:8] = (tr_in.wstrb[i]) ? tr_in.wdata[i*8+:8] : register_bank[addw][i*8+:8]; 
          end
        end
        tr_out.bresp = AXI4_RESP_B_OKAY;
      end

      else begin
        tr_out.bresp = AXI4_RESP_B_SLVERR;
      end

      //foreach(register_bank[i]) $display("REGISTER %1d: %h",i,register_bank[i]);

      if(register_bank[REGFILE_CONFIG][ECMD]) ->start_encode;
      if(register_bank[REGFILE_CONFIG][DCMS]) ->start_decode;
      else if(!register_bank[REGFILE_CONFIG][ECMD] && !register_bank[REGFILE_CONFIG][DCMS]) begin
        ->over_write_reg;
        $display("TERMINEI DE ESCREVER");
      end
    end
  endtask: write_register

  virtual task encoder_task();
    forever begin
      @(start_encode);
      //register_bank[REGFILE_STATUS][ES] = 1;
      //register_bank[REGFILE_STATUS][EO] = 0;
      for(int a =  0, b = 0; a <  4; a++, b++)encoder_data[a] = register_bank[REGFILE_ENC_IN_01][b*8+:8];
      for(int a =  4, b = 0; a <  8; a++, b++)encoder_data[a] = register_bank[REGFILE_ENC_IN_02][b*8+:8];
      for(int a =  8, b = 0; a < 12; a++, b++)encoder_data[a] = register_bank[REGFILE_ENC_IN_03][b*8+:8];
      for(int a = 12, b = 0; a < 16; a++, b++)encoder_data[a] = register_bank[REGFILE_ENC_IN_04][b*8+:8];
      for(int a = 16, b = 0; a < 20; a++, b++)encoder_data[a] = register_bank[REGFILE_ENC_IN_05][b*8+:8];
      for(int a = 20, b = 0; a < 24; a++, b++)encoder_data[a] = register_bank[REGFILE_ENC_IN_06][b*8+:8];

      encoder(encoder_data, encoded_data);

      for(int a =  0, b = 0; a <  4; a++, b++)register_bank[REGFILE_ENC_OUT_01][b*8+:8] = encoded_data[a]; 
      for(int a =  4, b = 0; a <  8; a++, b++)register_bank[REGFILE_ENC_OUT_02][b*8+:8] = encoded_data[a]; 
      for(int a =  8, b = 0; a < 12; a++, b++)register_bank[REGFILE_ENC_OUT_03][b*8+:8] = encoded_data[a]; 
      for(int a = 12, b = 0; a < 16; a++, b++)register_bank[REGFILE_ENC_OUT_04][b*8+:8] = encoded_data[a]; 
      for(int a = 16, b = 0; a < 20; a++, b++)register_bank[REGFILE_ENC_OUT_05][b*8+:8] = encoded_data[a]; 
      for(int a = 20, b = 0; a < 24; a++, b++)register_bank[REGFILE_ENC_OUT_06][b*8+:8] = encoded_data[a]; 
      for(int a = 24, b = 0; a < 28; a++, b++)register_bank[REGFILE_ENC_OUT_07][b*8+:8] = encoded_data[a]; 
      for(int a = 28, b = 0; a < 32; a++, b++)register_bank[REGFILE_ENC_OUT_08][b*8+:8] = encoded_data[a]; 
      $display("ENCODER REG 1: %h", register_bank[REGFILE_ENC_OUT_01]);
      $display("ENCODER REG 2: %h", register_bank[REGFILE_ENC_OUT_02]);
      $display("ENCODER REG 3: %h", register_bank[REGFILE_ENC_OUT_03]);
      $display("ENCODER REG 4: %h", register_bank[REGFILE_ENC_OUT_04]);
      $display("ENCODER REG 5: %h", register_bank[REGFILE_ENC_OUT_05]);
      $display("ENCODER REG 6: %h", register_bank[REGFILE_ENC_OUT_06]);
      $display("ENCODER REG 7: %h", register_bank[REGFILE_ENC_OUT_07]);
      $display("ENCODER REG 8: %h", register_bank[REGFILE_ENC_OUT_08]);
      //register_bank[REGFILE_STATUS][ES] = 0;
      //register_bank[REGFILE_STATUS][EO] = 1;
      //register_bank[REGFILE_CONFIG][ECMD] = 0;
      ->codificator;
      $display("TERMINEI DE ENCODAR");
    end
  endtask: encoder_task

  virtual task decoder_task();
    forever begin
      @(start_decode);
      //register_bank[REGFILE_STATUS][DS] = 1;
      //register_bank[REGFILE_STATUS][DO] = 0;
      for(int a =  0, b = 0; a <  4; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_01][b*8+:8];
      for(int a =  4, b = 0; a <  8; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_02][b*8+:8];
      for(int a =  8, b = 0; a < 12; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_03][b*8+:8];
      for(int a = 12, b = 0; a < 16; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_04][b*8+:8];
      for(int a = 16, b = 0; a < 20; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_05][b*8+:8];
      for(int a = 20, b = 0; a < 24; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_06][b*8+:8];
      for(int a = 24, b = 0; a < 28; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_07][b*8+:8];
      for(int a = 28, b = 0; a < 32; a++, b++)decoder_data[a] = register_bank[REGFILE_DEC_IN_08][b*8+:8];

      decoder(decoder_data, decoded_data, num_error, l_degree);

      for(int a =  0, b = 0; a <  4; a++, b++)register_bank[REGFILE_DEC_OUT_01][b*8+:8] = decoded_data[a]; 
      for(int a =  4, b = 0; a <  8; a++, b++)register_bank[REGFILE_DEC_OUT_02][b*8+:8] = decoded_data[a]; 
      for(int a =  8, b = 0; a < 12; a++, b++)register_bank[REGFILE_DEC_OUT_03][b*8+:8] = decoded_data[a]; 
      for(int a = 12, b = 0; a < 16; a++, b++)register_bank[REGFILE_DEC_OUT_04][b*8+:8] = decoded_data[a]; 
      for(int a = 16, b = 0; a < 20; a++, b++)register_bank[REGFILE_DEC_OUT_05][b*8+:8] = decoded_data[a]; 
      for(int a = 20, b = 0; a < 24; a++, b++)register_bank[REGFILE_DEC_OUT_06][b*8+:8] = decoded_data[a]; 

      if(num_error > EQ_4) begin
        tr_out.rresp = AXI4_RESP_B_SLVERR;
        tr_out.bresp = AXI4_RESP_B_SLVERR;
      end

      $display("Numero de ERROS l_degree = %h", l_degree);
      $display("Numero de ERROS num_error = %h", num_error);
      $display("DECODED REG 1: %h", register_bank[REGFILE_DEC_OUT_01]);
      $display("DECODED REG 2: %h", register_bank[REGFILE_DEC_OUT_02]);
      $display("DECODED REG 3: %h", register_bank[REGFILE_DEC_OUT_03]);
      $display("DECODED REG 4: %h", register_bank[REGFILE_DEC_OUT_04]);
      $display("DECODED REG 5: %h", register_bank[REGFILE_DEC_OUT_05]);
      $display("DECODED REG 6: %h", register_bank[REGFILE_DEC_OUT_06]);
      //register_bank[REGFILE_STATUS][DS] = 0;
      //register_bank[REGFILE_STATUS][DO] = 1;
      //register_bank[REGFILE_CONFIG][DCMS] = 0;
      //register_bank[REGFILE_STATUS][EQ_TAIL:EQ_HEAD] = num_error[2:0];
      ->decodificator;
      $display("TERMINEI DE DECODAR");
    end
  endtask: decoder_task

  virtual task record_tr_in();
    forever begin
      @(begin_record_in);
      begin_tr(tr_in, "REFMOD_IN");
      #80;
      //@(end_record_in);
      end_tr(tr_in);
    end
  endtask: record_tr_in

  virtual task record_tr_out();
    forever begin
      @(begin_record_out);
      begin_tr(tr_out, "REFMOD_OUT");
      @(end_record_out);
      end_tr(tr_out);
    end
  endtask: record_tr_out

endclass: rs_refmod
