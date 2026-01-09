`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 11/04/2025 02:54:05 PM
// Design Name: 
// Module Name: accumulator
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


module accumulator #(
    parameter int b_weight = 4,  // Width of each synapse input
    parameter int b_accum  = 8   // Width of accumulator (membrane potential)
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic signed [b_weight+1:0] syn_0,
    input logic signed [b_weight+1:0] syn_1,
    input logic signed [b_weight+1:0] syn_2,
    input logic signed [b_weight+1:0] syn_3,
    input logic fire,           // Reset trigger
    output logic signed [b_accum+1:0] accum_out    // Membrane potential

);

    logic signed [b_accum+1:0] pre_accum;  // Local sum of syn inputs
    logic signed [b_accum+1:0] accum_reg;
    logic signed [b_accum+1:0] next_accum;

    assign pre_accum   = $signed(syn_0) + $signed(syn_1) + $signed(syn_2) + $signed(syn_3);
    assign next_accum  = $signed(accum_reg) + $signed(pre_accum);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            accum_reg <= 0;
        else if (fire)  // Reset on fire, took out || next_accum[b_accum-1]
            accum_reg <= 0;
        else if (enable)
            accum_reg <= next_accum;
    end

    assign accum_out = accum_reg;

endmodule
