`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 11/04/2025 07:02:10 PM
// Module Name: compare_and_fire
// Project Name: neuron_array
// Description: compares accumulated value against threshold
// Revision:
// Revision 0.01 - File Created
// Revision 1.1 - compare and fire output
// Revision 1.2 - remove refractory period, excess logic; add rising edge det.
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module compare_and_fire #(
    parameter int b_thresh = 8, // Bit width of threshold
    parameter int b_accum  = 8  // Bit width of membrane potential
)(
    input logic clk,
    input logic reset,
    input logic enable,

    input logic [b_thresh-1:0] threshold,       // Firing threshold
    //input logic [1:0] refractory,      // Refractory period (in cycles)
    input logic signed [b_accum-1:0] accum,         // Membrane potential

    //output logic [2:0] neuron_last_fire,// Cycles since last spike (for STDP)
    output logic fire             // Output spike (1-cycle pulse)
);

    // Internal state
    logic fire_reg;

    // Exceeds threshold (only use magnitude of accum)
    logic exceed_threshold;
    assign exceed_threshold = accum > $signed(threshold);

    //rising edge detection; fires when exceed_threshold rises
    logic exceed_threshold_d;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            exceed_threshold_d <= 0;
        else if (enable)
            exceed_threshold_d <= exceed_threshold;
    end
    
    wire fire_pulse = exceed_threshold & ~exceed_threshold_d;

    
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            fire_reg <= 1'b0;
        else if (enable)
            fire_reg <= fire_pulse;
    end

    assign fire = fire_reg;

endmodule
