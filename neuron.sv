`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 10/30/2025 04:12:10 PM
// Design Name: 
// Module Name: neuron
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module neuron#(
    parameter int b_weight = 6,
    parameter int b_accum = 8,
    parameter int b_thresh = 6,
    parameter int b_time = 3,
    
    parameter int LEARN = 3,
    parameter int SPIKE_POLARITY = 1
)(
    input logic clk,
    input logic reset,
    input logic spike_in,
    output logic fire
);

    //PROCESS SPIKE INPUTS
    //UP SPIKE (1) => 1
    //DOWN SPIKE (1) => -1
    //EITHER (0) => 0
    logic signed [1:0] delta_spike; 
    
    always_comb begin
        if (spike_in)
            delta_spike = SPIKE_POLARITY;
        else
            delta_spike = 0;
    end
    
    //TIMING (FOR STDP)
    logic [3:0] neuron_time;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            neuron_time <= 3'd7;
        else if (fire)
            neuron_time <= 3'd0;
        else if (neuron_time < 3'd7)
            neuron_time <= neuron_time + 3'd1;
    end
    
    //SYNAPSE UNIT
    logic signed [b_weight+1:0] weight_to_accum;

    synapse_unit_2 #(
        .b_weight(b_weight),
        .b_time(b_time),
        .LEARN(LEARN)
    ) syn_inst (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .stdp_enable(1'b1),
        .spike_in(delta_spike),
        .neuron_time(neuron_time),
        .syn_time_o(),
        .weight_to_accum(weight_to_accum)
    );
        
    /*logic signed [b_weight+1:0] weight_to_accum_2;
    
    synapse_unit_2 #(
        .b_weight(b_weight),
        .b_time(b_time),
        .LEARN(LEARN)
    ) syn_inst_2 (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .stdp_enable(1'b1),
        .spike_in(delta_spike),
        .neuron_time(neuron_time),
        .syn_time_o(),
        .weight_to_accum(weight_to_accum_2)
    );
    */
    //ACCUMULATOR
    logic signed [b_accum-1:0] accum;
    
    accumulator #(
        .b_weight(b_weight),
        .b_accum(b_accum)
    ) acc_inst (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .syn_0(weight_to_accum),
        //.syn_1(weight_to_accum_2),
        //.syn_2('0),
        .fire(fire),
        .accum_out(accum)
    );
    
    //COMPARE AND FIRE
    logic [2:0] neuron_last_fire;

    localparam logic [b_thresh-1:0] threshold = 6'd10;
    localparam logic [1:0] refrac_t = 2'd2;

    compare_and_fire #(
        .b_thresh(b_thresh),
        .b_accum(b_accum)
    ) cf_inst (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .threshold(threshold),
        .refractory(refrac_t),
        .accum(accum),
        .neuron_last_fire(neuron_last_fire),
        .fire(fire)
    );
    
endmodule
