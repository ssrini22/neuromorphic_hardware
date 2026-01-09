`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 11/13/2025 08:18:19 PM
// Design Name: 
// Module Name: synapse_unit_2
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


module synapse_unit_2#(
    parameter int b_weight = 4,
    parameter int b_time = 3,
    parameter int LEARN = 3,
    parameter int INIT_WEIGHT = 1
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic stdp_enable,
    
    //input logic signed [1:0] spike_in,        // +1, -1, or 0 from UP/DOWN encoding
    input logic signed spike_in,        // 1 or 0 for UP or DOWN

    input logic [b_time:0] neuron_time,     // Time since neuron last fired - cycles
    input logic signed [1:0] spike_polarity,
    
    //output logic [b_time:0] syn_time_o,      // Updated synapse time for STDP
    output logic signed [b_weight+1:0] weight_to_accum // To accumulator (spike x weight)
);

    //Reg for weight and syn tim logic
    logic signed [b_weight-1:0] weight_reg;
    logic [b_time:0] syn_time;
    
    //Reset time if synapse gets a spike, or else increment up to 7
//    logic [b_time:0] syn_time_next;
//    assign syn_time_next = (spike_in != 0) ? '0 : 
//        (syn_time < 2*LEARN+1) ? syn_time + 1 : syn_time;
    
    //Calculate delta-t and abs val, post-pre
    logic signed [b_time:0] delta_t;
    assign delta_t = $signed({1'b0, neuron_time}) - $signed({1'b0, syn_time});
    
    logic [b_time:0] abs_delta_t;
    assign abs_delta_t = (delta_t < 0) ? -delta_t : delta_t;
    
    //STDP logic- enabled, spike, and within window
    logic stdp_calc;
    assign stdp_calc = stdp_enable && ((spike_in != 0) || (neuron_time == 0)) && 
        (abs_delta_t <= LEARN); //add logic for fire, using neuron time is 0 now
    
    //Timing logic fix for updating weights
    logic pre_a_post;
    assign pre_a_post = stdp_calc && (neuron_time == 0); //1 if pre after post update
    
    //STDP LUT
    localparam int LUT_SIZE = (LEARN*2)+1;
    logic signed [3:0] stdp_lut [0:LUT_SIZE-1];
    
    initial begin
        stdp_lut[0] = 1; // d-t = -3
        stdp_lut[1] = 2; // d-t = -2
        stdp_lut[2] = 3; // d-t = -1 (-3 actual)
        stdp_lut[3] = 0; // d-t =  0
        stdp_lut[4] = -2; // d-t = +1
        stdp_lut[5] = -1; // d-t = +2
        stdp_lut[6] = 0; // d-t = +3
    end
    
    logic [b_time:0] lut_index;
    //outside +-3 then no weight (0)
    assign lut_index = ((delta_t < -LEARN) || (delta_t >  LEARN)) ? LEARN : delta_t + LEARN; //hardcoded long time
    //assign lut_index = ((delta_t < -LEARN) || (delta_t >  LEARN)) ? LEARN : pre_a_post ? (delta_t + LEARN + 2) : delta_t + LEARN; //hardcoded long time

    //assign lut_index = (delta_t < -LEARN) ? 0 : (delta_t >  LEARN) ? (2 * LEARN) : delta_t + LEARN; //rework
    //assign lut_index = delta_t + LEARN;
    
    logic signed [b_weight-1:0] pass_weight;
    assign pass_weight = ((weight_reg + stdp_lut[lut_index]) == 0) ? 1 : (weight_reg + stdp_lut[lut_index]); //add overflow log
    
    //assign updated weight to reg if stdp logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            weight_reg <= INIT_WEIGHT;
            syn_time <= 3'd7;
        end else if (enable) begin
            if (spike_in != 0)
                syn_time <= 0;
            else if (syn_time < 2*LEARN+1)
                syn_time <= syn_time + 1;
            if (stdp_calc)
                weight_reg <= pass_weight;
        end
    end
    
    //assign time output and product of weight and spike to be accum
    //assign syn_time_o = syn_time;
    assign weight_to_accum = (enable && spike_in != 0) ?
        ($signed(spike_in) * $signed(weight_reg)) : '0;
    //next check to take out the multiplication
    
    //Display
//    always_ff @(posedge clk) begin
//        if (enable && spike_in != 0) begin
//            $display("T=%0t | spike=%0d | weight=%0d | product=%0d | Δt=%0d | lutval=%0d | weight_new=%0d",
//                $time, spike_in, weight_reg,
//                spike_in * weight_reg, delta_t,
//                stdp_lut[lut_index], weight_reg);

//            $display("neuron_time=%0d (bin=%b), syn_time=%0d (bin=%b)", 
//                 neuron_time, neuron_time, syn_time, syn_time);
//        end
//    end

endmodule
