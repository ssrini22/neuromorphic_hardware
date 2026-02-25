module neuron_array#(
    parameter int N_inputs = 2,
    parameter int N_neurons = 5,
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
    input logic signed [(N_inputs*N_neurons)*(b_weight+2)-1:0] synapse_weights, //SCW
    input logic [b_thresh-1:0] threshold,   //SCW
    input logic [b_time:0] refractory,      //SCW
    input logic [b_time:0] leak_rate,       //SCW
    output logic [N_neurons-1:0] fire,  //N_neurons columns of outputs
    output logic [N_neurons-1:0] winner
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
    
    //ENABLE LOGIC
    logic sys_en, load_active;
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            load_active <= 1'b0;
            sys_en <= 1'b0;
        end else begin
            load_active <= load_config;
            if (load_active)
                sys_en <= 1'b1;
        end     
    end
    
    //synapse outputs, one per input to each output
    //N-inputs*N_neurons synapse_units, weight_to_accum singals
    logic signed [(N_inputs*N_neurons)*(b_weight+2)-1:0] syn_out;
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
                    .load_config(load_active),
                    .enable(sys_en),
                    .stdp_enable(1'b1),
                    .spike_in(spike_in[i]),
                    .neuron_time(neuron_time[j]),
                    .refractory(refractory),
                    .spike_polarity(((i % 2 == 0) ? UP : DOWN)),
                    .init_weight(synapse_weights[(N_neurons*i+j)*(b_weight+2) +: (b_weight+2)]),
                    .weight_to_accum(syn_out[(N_neurons*i+j)*(b_weight+2) +: (b_weight+2)])
                );
            end
        end
    endgenerate
    
    //accum inputs per neuron / cols
    //logic signed [b_accum+1:0] accum_cols [N_neurons];

    genvar k;
    generate
        for (k = 0; k < N_neurons; k++) begin : gen_cols
            accumulator #(
                .b_weight(b_weight),
                .b_accum(b_accum),
                .b_time(b_time),
                .b_thresh(b_thresh)
            ) acc_inst (
                .clk(clk),
                .reset(reset),
                .enable(sys_en),
                .syn_0(syn_out[(k)*(b_weight+2) +: (b_weight+2)]),
                .syn_1(syn_out[(N_neurons+k)*(b_weight+2) +: (b_weight+2)]),
                .refractory(refractory),
                .leak_rate(leak_rate),
                .threshold(threshold),
                .neuron_time(neuron_time[k]),
                .any_fire(reset_accums[k]),
                .fire(fire[k]),
                .accum_out() //was just accum_cols[k]
            );
            
        end
    endgenerate
    
    logic [N_neurons-1:0] reset_accums;
    
    wta #(
        .N_neurons(N_neurons)
    ) wta_inst (
        .enable(sys_en),
        .fire(fire),
        .winner(winner),
        .reset_accums(reset_accums)
    );

endmodule
