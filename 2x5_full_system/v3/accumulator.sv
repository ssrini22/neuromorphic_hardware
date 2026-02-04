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
    parameter int b_time = 3,
    parameter int b_thresh = 8
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic signed [b_weight+1:0] syn_0,
    input logic signed [b_weight+1:0] syn_1,
    input logic [b_time:0] refractory,      //refractory period in clock cycles
    input logic [b_time:0] leak_rate,       //-1 every leak_rate clock cycles
    input logic [b_thresh-1:0] threshold,
    input logic [b_time:0] neuron_time,     // Time since neuron last fired - cycles
    input logic any_fire,
    output logic fire,           // Reset trigger
    output logic signed [b_accum+1:0] accum_out    // Membrane potential

);

    logic signed [b_accum+1:0] pre_accum;  // Local sum of syn inputs
    logic signed [b_accum+1:0] accum_reg;
    logic [b_time:0] leak_counter;
    
    assign pre_accum = $signed(syn_0) + $signed(syn_1);
    
    //assign fire
    assign fire = enable && (((accum_reg > 0) ? accum_reg : -accum_reg) >= $signed(threshold));
        
    logic accum_on;
    assign accum_on = enable && (refractory < neuron_time); //<=?

    always_ff @(posedge clk) begin
        if (reset) begin
            accum_reg <= 0;
            leak_counter <= '0;
        end else if (fire || any_fire) begin
            accum_reg <= '0;
            leak_counter <= '0;
        end else if (accum_on) begin
            if (leak_counter < leak_rate) begin
                accum_reg <= accum_reg + pre_accum;
                leak_counter <= leak_counter + 1'b1; //should only incremembt if pre_accum is 0
            end else begin
                leak_counter <= '0;
                
                if (accum_reg + pre_accum > 0)
                    accum_reg <= accum_reg + pre_accum - 1'b1;
                else if (accum_reg + pre_accum < 0)
                    accum_reg <= accum_reg + pre_accum + 1'b1;
                else
                    accum_reg <= accum_reg + pre_accum;
            end
        end
    end

    assign accum_out = accum_reg;

endmodule
