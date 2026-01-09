`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 11/04/2025 07:02:10 PM
// Design Name: 
// Module Name: compare_and_fire
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


module compare_and_fire #(
    parameter int b_thresh = 6, // Bit width of threshold
    parameter int b_accum  = 8  // Bit width of membrane potential
)(
    input logic                    clk,
    input logic                    reset,
    input logic                    enable,

    input logic [b_thresh-1:0]     threshold,       // Firing threshold
    input logic [1:0]              refractory,      // Refractory period (in cycles)
    input logic signed [b_accum-1:0] accum,         // Membrane potential

    output logic [2:0]              neuron_last_fire,// Cycles since last spike (for STDP)
    output logic                    fire             // Output spike (1-cycle pulse)
);

    // Internal state
    logic fire_reg;
    logic [2:0] refrac_counter;

    // Exceeds threshold (only use magnitude of accum)
    logic exceed_threshold;
    assign exceed_threshold = ($unsigned(accum[b_accum-2:0]) > threshold) && ~accum[b_accum-1];

    // Fire logic + refractory enforcement
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            fire_reg        <= 1'b0;
            refrac_counter  <= 3'd0;
            neuron_last_fire <= 3'd4;  // out of STDP window
        end
        else if (enable) begin
            if ((refrac_counter == 0) && exceed_threshold) begin
                // Neuron fires
                fire_reg        <= 1'b1;
                refrac_counter  <= {1'b0, refractory}; // zero-padded 2-bit value
                neuron_last_fire <= 3'd0;
            end else begin
                // No fire
                fire_reg <= 1'b0;

                // Refractory countdown
                if (refrac_counter != 0)
                    refrac_counter <= refrac_counter - 1;

                // Time since last fire (cap at 3'd4)
                if (neuron_last_fire < 3'd4)
                    neuron_last_fire <= neuron_last_fire + 1;
                else
                    neuron_last_fire <= 3'd4;
            end
        end else begin
            fire_reg        <= 1'b0;
            refrac_counter  <= 3'd0;
            neuron_last_fire <= 3'd4;
        end
    end

    assign fire = fire_reg;

endmodule
