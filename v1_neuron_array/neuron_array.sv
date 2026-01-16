`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 12/11/2025 01:26:28 PM
// Module Name: neuron_array
// Project Name: neuron_array
// Description: 4x4 array top module
// Revision: 1.1
// Revision 0.01 - File Created
// Revision 1.1 - Neuron time logic, Instantiate submodules
// Revision 1.2 - Setup for scan chain wrapper
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module neuron_array#(
    parameter int N_inputs = 4,
    parameter int N_neurons = 4,
    parameter int b_weight = 4,
    parameter int b_accum = 8,
    parameter int b_thresh = 8,
    parameter int b_time = 3,
    parameter int LEARN = 3
)(
    input logic clk,
    input logic reset,
    input logic [N_inputs-1:0] spike_in, //N_inputs rows of inputs
    output logic [N_neurons-1:0] fire  //N_neurons columns of outputs
);
    
    //neuron time for each row of synapses
    //TIMING (FOR STDP)
    logic [b_time:0] neuron_time [N_neurons];
    
    always_ff @(posedge clk or posedge reset) begin : post_timing
        if (reset) begin
            for (int j = 0; j < N_neurons; j++)
                neuron_time[j] <= {b_time{1'b1}};
        end
        else begin
            for (int j = 0; j < N_neurons; j++) begin
                if (fire[j] != 0)
                    neuron_time[j] <= '0;
                else if (neuron_time[j] < {b_time{1'b1}})
                    neuron_time[j] <= neuron_time[j] + 3'd1;
            end
        end
    end
    
    //synapse outputs, one per input to each output
    //N-inputs*N_neurons synapse_units, weight_to_accum singals
    logic signed [b_weight+1:0] syn_out [N_inputs][N_neurons];
    localparam signed [1:0] UP   = 2'sd1;
    localparam signed [1:0] DOWN = -2'sd1;
    localparam [b_time:0] refractory = 3'd2;

    genvar i, j;
    generate
        for (i = 0; i < N_inputs; i++) begin : gen_inputs
            for (j = 0; j < N_neurons; j++) begin : gen_outputs
                synapse_unit_2 #(
                    .b_weight(b_weight),
                    .b_time(b_time),
                    .LEARN(LEARN),
                    .INIT_WEIGHT(2'd2)
                ) syn_inst (
                    .clk(clk),
                    .reset(reset),
                    .enable(1'b1),
                    .stdp_enable(1'b1),
                    .spike_in(spike_in[i]),
                    .neuron_time(neuron_time[j]),
                    .refractory(refractory),
                    .spike_polarity(((i % 2 == 0) ? UP : DOWN)),
                    .weight_to_accum(syn_out[i][j])
                );
            end
        end
    endgenerate
    
    //accum inputs per neuron / cols
    logic signed [b_accum+1:0] accum_cols [N_neurons];
    localparam [b_thresh-1:0] threshold = b_thresh'(20);
    localparam [b_time:0] leak_rate = 3'd2;

    genvar k;
    generate
        for (k = 0; k < N_neurons; k++) begin : gen_cols
            //accum 4 synapses in column
            accumulator #(
                .b_weight(b_weight),
                .b_accum(b_accum),
                .b_time(b_time)
            ) acc_inst (
                .clk(clk),
                .reset(reset),
                .enable(1'b1),
                .syn_0(syn_out[0][k]),
                .syn_1(syn_out[1][k]),
                .syn_2(syn_out[2][k]),
                .syn_3(syn_out[3][k]),
                .refractory(refractory),
                .leak_rate(leak_rate),
                .neuron_time(neuron_time[k]),
                .fire(fire[k]),
                .accum_out(accum_cols[k])
            );
            //cf accum val
            compare_and_fire #(
                .b_thresh(b_thresh),
                .b_accum(4'd10)
            ) cf_inst (
                .clk(clk),
                .reset(reset),
                .enable(1'b1),
                .threshold(threshold),
                .accum(accum_cols[k]),
                .fire(fire[k])
            );
            
        end
    endgenerate

endmodule
