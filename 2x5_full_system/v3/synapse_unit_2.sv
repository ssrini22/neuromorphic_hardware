`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 11/13/2025 08:18:19 PM
// Module Name: synapse_unit_2
// Project Name: neuron_array
// Description: synapse module with weight/time; STDP
// Revision:
// Revision 0.01 - File Created
// Revision 1.1 - Syanpse unit with syanpse time, weight_to_accum; STDP weight update
// Revision 1.2 - Remove excess logic; no STDP update during refractory period
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module synapse_unit_2#(
    parameter int b_weight = 4,
    parameter int b_time = 3,
    parameter int LEARN = 3
)(
    input logic clk,
    input logic reset,
    input logic load_config,
    input logic enable,
    input logic stdp_enable,
    input logic signed spike_in,        // 1 or 0 for UP or DOWN
    input logic [b_time:0] neuron_time,     // Time since neuron last fired - cycles
    input logic [b_time:0] refractory,      //refractory period in clock cycles
    input logic signed [1:0] spike_polarity,
    input logic signed [b_weight+1:0] init_weight,
    output logic signed [b_weight+1:0] weight_to_accum // To accumulator (spike x weight)
);

    //Reg for weight and syn tim logic
    logic signed [b_weight+1:0] weight_reg;
    logic [b_time:0] syn_time;
    
    logic signed [b_time:0] delta_t;    //Calculate delta-t post-pre 
    logic stdp_calc;                    //STDP logic- enabled, spike, and within window

    always_ff @(posedge clk) begin
        if (reset) begin
            delta_t <= '0;
            stdp_calc <= '0;
        end else begin
            delta_t <= $signed({1'b0, neuron_time}) - $signed({1'b0, syn_time});
            stdp_calc <= stdp_enable && (((spike_in != 0) && (neuron_time > refractory)) || (neuron_time == 0)) && (neuron_time <= LEARN);
        end
    end
    
    //STDP LUT
    typedef logic signed [3:0] lut_t;
    localparam lut_t stdp_lut [0:6] = '{1,2,3,0,-2,-1,0};
    
    logic [b_time:0] lut_index;
    //outside +-3 then no weight (0)
    assign lut_index = ((delta_t < -LEARN) || (delta_t >  LEARN)) ? LEARN : delta_t + LEARN; //hardcoded long time

    //assign updated weight to reg if stdp logic
    always_ff @(posedge clk) begin
        //if (reset || load_config_out) begin
        if (reset) begin
            weight_reg <= init_weight;
            syn_time <= 4'd7;
        end else if (load_config) begin
            weight_reg <= init_weight;
        end else if (enable) begin
            if (spike_in != 0)
                syn_time <= 0;
            else if (syn_time < 2*LEARN+1)
                syn_time <= syn_time + 1;
            if (stdp_calc) begin
                if (weight_reg + stdp_lut[lut_index] == 0)
                    weight_reg <= 1;
                else
                    weight_reg <= weight_reg + stdp_lut[lut_index];
            end
        end
    end
    
    //assign time output and product of weight and spike to be accum
    assign weight_to_accum = (enable && spike_in != 0) ?
        ($signed(weight_reg)) : '0;


endmodule
