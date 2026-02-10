`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2026 10:17:05 AM
// Design Name: 
// Module Name: delta_mod
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


module delta_mod#(
    parameter DATA_WIDTH = 11,
    parameter STEP_SIZE = 4, //threshold for spiking
    parameter MAX_VAL = 2047,
    parameter MIN_VAL = 0
)(
    input logic clk,
    input logic dm_reset,
    input logic [DATA_WIDTH-1:0] ecg_in,
    output logic [1:0] dm_spike_out,         //[0] UP, [1] DOWN
    output logic [DATA_WIDTH-1:0] signal
);
    
    logic init;
    logic last_cycle_spiked;
    
    wire [DATA_WIDTH-1:0] next_up = (signal + STEP_SIZE > MAX_VAL) ? MAX_VAL : (signal + STEP_SIZE);
    wire [DATA_WIDTH-1:0] next_down = (signal < STEP_SIZE) ? MIN_VAL : (signal - STEP_SIZE);
    
    always_ff @(posedge clk or posedge dm_reset) begin
        if (dm_reset) begin
            signal <= '0;
            dm_spike_out[0] <= 1'b0;
            dm_spike_out[1] <= 1'b0;
            init <= 1'b0;
            last_cycle_spiked <= 1'b0;
        end else begin
            dm_spike_out[0] <= 1'b0;
            dm_spike_out[1] <= 1'b0;
            if (!init) begin
                signal <= ecg_in;
                init <= 1'b1;
            end else if (last_cycle_spiked) begin
                last_cycle_spiked <= 1'b0;
            end else begin
                if (ecg_in > signal + STEP_SIZE) begin
                    dm_spike_out[0] <= 1'b1;
                    last_cycle_spiked <= 1'b1;
                    signal <= next_up;
                end else if (ecg_in + STEP_SIZE < signal) begin
                    dm_spike_out[1] <= 1'b1;
                    last_cycle_spiked <= 1'b1;
                    signal <= next_down;
                end
            end
        end    
    end
       
endmodule
