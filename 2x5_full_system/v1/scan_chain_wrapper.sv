`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2026 03:40:16 PM
// Design Name: 
// Module Name: scan_chain_wrapper
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


module scan_chain_wrapper#(
    parameter int N_inputs = 4,
    parameter int N_neurons = 4,
    parameter int b_weight = 4,
    parameter int b_accum = 8,
    parameter int b_thresh = 8,
    parameter int b_time = 3,
    parameter int LEARN = 3,
    parameter int TOTAL_BITS = (N_inputs*N_neurons*(b_weight+2)) + (b_thresh) + 2*(b_time+1)
)(
    //neuron_array
    input logic clk,
    input logic reset,
    
    //scw signals
    input logic prog_clk,
    input logic prog_data,
    input logic load_config,
    
    //neuron_array
    input logic [N_inputs-1:0] spike_in,
    output logic [N_neurons-1:0] fire,
    output logic [2:0] winner
);

    logic [TOTAL_BITS-1:0] shift_reg;
    logic [TOTAL_BITS-1:0] config_reg;
    
    always_ff @(posedge prog_clk or posedge reset) begin
        if (reset)
            shift_reg <= '0;
        else
            shift_reg <= {shift_reg[TOTAL_BITS-2:0], prog_data};
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            config_reg <= '0;
        else if (load_config)
            config_reg <= shift_reg;
    end
    //when scanning go MSB to LSB 
    //start with weight[15][MSB->LSB]..weight[0][0]..config params MSB to LSB
    
    localparam B_WEIGHT = b_weight+2;
    localparam B_THRESH = b_thresh;
    localparam B_REFRAC = b_time+1;
    localparam B_LEAK = b_time+1;
    localparam N = N_inputs*N_neurons;
    
    //Scan chain inputs
    logic signed [b_weight+1:0] synapse_weights [N_inputs*N_neurons]; 
    logic [b_thresh-1:0] threshold;
    logic [b_time:0] refractory;
    logic [b_time:0] leak_rate;
    int offset;

    always_comb begin
        offset = TOTAL_BITS-1;
        
        //MSB N*6 bits for syn_weights
        for (int i = 0; i < N; i++) begin
            synapse_weights[N-1-i] = config_reg[offset -: B_WEIGHT];
            offset -= B_WEIGHT;
        end
        
        //rest is config
        threshold = config_reg[offset -: B_THRESH];
        offset -= B_THRESH;
        refractory = config_reg[offset -: B_REFRAC];
        offset -= B_REFRAC;
        leak_rate = config_reg[offset -: B_LEAK];
        offset -= B_LEAK;
    end

        //Instantiate DUT
    neuron_array #(
        .N_inputs(N_inputs),
        .N_neurons(N_neurons),
        .b_weight(b_weight), //6
        .b_accum(b_accum),
        .b_thresh(b_thresh),
        .b_time(b_time),
        .LEARN(LEARN)
    ) dut (
        .clk(clk),
        .reset(reset),
        .load_config(load_config),
        .spike_in(spike_in),
        .synapse_weights(synapse_weights),
        .threshold(threshold),
        .refractory(refractory),
        .leak_rate(leak_rate),
        .fire(fire),
        .winner(winner)
    );


endmodule
