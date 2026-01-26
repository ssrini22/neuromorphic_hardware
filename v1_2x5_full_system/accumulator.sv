`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 11/04/2025 02:54:05 PM
// Module Name: accumulator
// Project Name: neuron_array
// Description: accumulates synapse weights, reset accumulator
// Revision:
// Revision 0.01 - File Created
// Revision 1.1 - Accumulates 4 syanpses weight, resets on fire
// Revision 1.2 - Add leaking; refractory period
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module accumulator #(
    parameter int b_weight = 4,  // Width of each synapse input
    parameter int b_accum  = 8,   // Width of accumulator (membrane potential)
    parameter int b_time = 3
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic signed [b_weight+1:0] syn_0,
    input logic signed [b_weight+1:0] syn_1,
    //input logic signed [b_weight+1:0] syn_2,
    //input logic signed [b_weight+1:0] syn_3,
    input logic [b_time:0] refractory,      //refractory period in clock cycles
    input logic [b_time:0] leak_rate,       //-1 every leak_rate clock cycles
    input logic [b_time:0] neuron_time,     // Time since neuron last fired - cycles
    input logic fire,           // Reset trigger
    input logic reset_wta,
    output logic signed [b_accum+1:0] accum_out    // Membrane potential

);

    logic signed [b_accum+1:0] pre_accum;  // Local sum of syn inputs
    logic signed [b_accum+1:0] accum_reg;
    logic signed [b_accum+1:0] next_accum;

    assign pre_accum = $signed(syn_0) + $signed(syn_1);
    //assign pre_accum = $signed(syn_0) + $signed(syn_1) + $signed(syn_2) + $signed(syn_3);
    assign next_accum = $signed(accum_reg) + $signed(pre_accum);
    
    logic [b_time:0] leak_counter;
    //assign leak_counter = '0;
    
    logic accum_on;
    assign accum_on = enable && (refractory < neuron_time);

    always_ff @(posedge clk or posedge reset) begin
        if (reset || fire || reset_wta) begin
            accum_reg <= 0;
            leak_counter <= 0;
        //end else if (accum_on && (next_accum >= 0)) begin
        end else if (accum_on) begin
            if (leak_counter < leak_rate) begin
                accum_reg <= next_accum;
                leak_counter <= leak_counter + 1;
            end
            else if (next_accum > 0) begin
                accum_reg <= next_accum - 1;
                leak_counter <= 0;
            end
            else if (next_accum < 0) begin
                accum_reg <= next_accum + 1;
                leak_counter <= 0;
            end
        end
    end

    assign accum_out = accum_reg;

endmodule
