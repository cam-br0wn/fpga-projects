`timescale 1ns/1ps

module leddcd 
  (
    input logic CLK,
    input logic RESET,
    input logic [3:0] data_in,
    
    output logic [6:0] cathode_out,
    output logic       anode_out
  );

  // we need to lower the 100 MHz clock down to 1kHz-62.5Hz
  // accomplish this by using a counter and FSM
  logic [15:0] counter, counter_next;
  logic [1:0]  fsm_state, fsm_state_next;
  logic [6:0]  internal_cathode;

  always_comb begin
    counter_next = counter + 16'b1;
    fsm_state_next = (counter == '0) ? $unsigned(fsm_state) + 2'b01 : fsm_state;
    cathode_out = (fsm_state == 2'b11) ? internal_cathode : '1;
    anode_out = (fsm_state == 2'b11) ? '1 : '0;
    //  AAA
    // F   B
    // F   B
    // F   B
    //  GGG
    // E   C
    // E   C
    // E   C
    //  DDD
    unique casez (data_in)
      4'h0:     internal_cathode = 7'b0000001;
      4'h1:     internal_cathode = 7'b1001111;
      4'h2:     internal_cathode = 7'b0010010;
      4'h3:     internal_cathode = 7'b0000110;
      4'h4:     internal_cathode = 7'b1001100;
      4'h5:     internal_cathode = 7'b0100100;
      4'h6:     internal_cathode = 7'b0100000;
      4'h7:     internal_cathode = 7'b0001111;
      4'h8:     internal_cathode = 7'b0000000;
      4'h9:     internal_cathode = 7'b0001100;
      4'ha:     internal_cathode = 7'b0001000;
      4'hb:     internal_cathode = 7'b1100000;
      4'hc:     internal_cathode = 7'b0110001;
      4'hd:     internal_cathode = 7'b1000010;
      4'he:     internal_cathode = 7'b0110000;
      4'hf:     internal_cathode = 7'b0111000;
      default:  internal_cathode = 7'b1111111;
    endcase
  end

  // now we need an FSM that is clocked on the slower clock
  always_ff @ (posedge CLK) begin
    if (RESET) begin
      counter <= 16'b1;
      fsm_state <= '0;
    end
    else begin
      counter <= counter_next;
      fsm_state <= fsm_state_next;
    end
  end

endmodule

