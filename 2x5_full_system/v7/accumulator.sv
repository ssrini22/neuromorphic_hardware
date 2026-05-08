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
    parameter int N_inputs = 2,
    parameter int b_weight = 4,  // Width of each synapse input
    parameter int b_accum  = 8,   // Width of accumulator (membrane potential)
    parameter int b_time = 3,
    parameter int b_thresh = 8
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic signed [b_weight+1:0] syn_in [N_inputs],
    input logic [b_time:0] refractory,      //refractory period in clock cycles
    input logic [b_time:0] leak_rate,       //-1 every leak_rate clock cycles
    input logic [b_thresh-1:0] threshold,
    input logic [b_time:0] neuron_time,     // Time since neuron last fired - cycles
    input logic any_fire,
    output logic fire,           // Reset trigger
    output logic signed [b_accum+1:0] accum_out    // Membrane potential

);

    (* max_fanout = 4 *) logic signed [b_accum+1:0] accum_reg;
    logic [b_time:0] leak_counter;
    (* max_fanout = 4 *) logic signed [b_accum+1:0] pre_accum;
    logic accum_on;
    
    //preaccum
    always_ff @(posedge clk) begin
        if (reset)
            pre_accum <= '0;
        else begin
            automatic logic signed [b_accum+1:0] sum = '0;
            for (int i = 0; i < N_inputs; i++)
                sum = sum + $signed(syn_in[i]);
            pre_accum <= sum;
        end
    end
    
    //compare and fire
    always_ff @(posedge clk) begin
        //pre_accum <= $signed(syn_0) + $signed(syn_1);
        if (fire)
            fire <= 1'b0;
        else
            fire <= enable && (accum_reg >= $signed(threshold));
    end
    
    
    assign accum_on = enable && (neuron_time > refractory - 1'b1);

    always_ff @(posedge clk) begin
        if (reset) begin
            accum_reg <= 0;
            leak_counter <= '0;
        end else if (fire || any_fire) begin
            accum_reg <= 0;
            leak_counter <= '0;
        end else if (accum_on) begin
//            logic signed [b_accum+1:0] next_accum;
//            next_accum = accum_reg + pre_accum;
            automatic logic signed [b_accum+1:0] next_accum = accum_reg + pre_accum;
            
            if (leak_counter < leak_rate) begin
                accum_reg <= next_accum;
                leak_counter <= leak_counter + 1'b1;
            end else begin
                leak_counter <= '0;
                
//                if (next_accum > 0)
//                    accum_reg <= next_accum - 1'b1;
//                else if (next_accum < 0)
//                    accum_reg <= next_accum + 1'b1;
//                else
//                    accum_reg <= next_accum;
                accum_reg <= (next_accum > 0) ? (next_accum - 1'b1) :
                             (next_accum < 0) ? (next_accum + 1'b1) :
                             next_accum;
            end
        end
    end

    assign accum_out = accum_reg;

endmodule
