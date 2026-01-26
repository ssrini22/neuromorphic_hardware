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
    input logic load_config, //SCW
    input logic [N_inputs-1:0] spike_in, //N_inputs rows of inputs
    input logic signed [b_weight+1:0] synapse_weights [N_inputs*N_neurons], //SCW
    input logic [b_thresh-1:0] threshold,   //SCW
    input logic [b_time:0] refractory,      //SCW
    input logic [b_time:0] leak_rate,       //SCW
    output logic [N_neurons-1:0] fire,  //N_neurons columns of outputs
    output logic [2:0] winner
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

    genvar i, j;
    generate
        for (i = 0; i < N_inputs; i++) begin : gen_inputs
            for (j = 0; j < N_neurons; j++) begin : gen_outputs
                synapse_unit_2 #(
                    .b_weight(b_weight),
                    .b_time(b_time),
                    .LEARN(LEARN)
                ) syn_inst (
                    .clk(clk),
                    .reset(reset),
                    .load_config(load_config),
                    .enable(1'b1),
                    .stdp_enable(1'b1),
                    .spike_in(spike_in[i]),
                    .neuron_time(neuron_time[j]),
                    .refractory(refractory),
                    .spike_polarity(((i % 2 == 0) ? UP : DOWN)),
                    .init_weight(synapse_weights[4*i+j]),
                    //.fire(fire),
                    .weight_to_accum(syn_out[i][j])
                );
            end
        end
    endgenerate
    
    //accum inputs per neuron / cols
    logic signed [b_accum+1:0] accum_cols [N_neurons];

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
                //.syn_2(syn_out[2][k]),
                //.syn_3(syn_out[3][k]),
                .refractory(refractory),
                .leak_rate(leak_rate),
                .neuron_time(neuron_time[k]),
                .fire(fire[k]),
                .reset_wta(reset_accum[k]),
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
    
    logic wta_clear, fire_first;
    logic [2:0] winner_idx;
    
    always_comb begin
        fire_first = 1'b0;
        winner_idx = 3'b0;
        for (int x = 0; x < N_neurons; x++) begin
            if (!fire_first && fire[x]) begin
                fire_first = 1'b1;
                winner_idx = x;
            end
        end
    end
    
    logic [2:0] winner;
    logic latch_done;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            latch_done <= 0;
            winner <= 0;
        end else begin
            if (fire_first && !latch_done) begin
                winner <= winner_idx;
                latch_done <= 1;
            end else begin
                winner <= 0;
                latch_done <= 0;
            end
        end
    end
    
    logic [4:0] reset_accum;

    always_comb begin
        for (int i = 0; i < 5; i++) begin
            reset_accum[i] = (latch_done && (winner != i));
        end
    end

endmodule
