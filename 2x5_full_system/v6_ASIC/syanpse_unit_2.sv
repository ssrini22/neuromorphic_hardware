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
    logic [b_time:0] lut_index;

    //regs
    logic [b_time:0] lut_index_reg;
    logic stdp_calc_reg;
    
    //STDP LUT
    localparam signed [27:0] stdp_lut = {4'sd1,4'sd2,4'sd3,4'sd0,-4'sd2,-4'sd1,4'sd0};
    
    always_comb begin
        delta_t = $signed({1'b0, neuron_time}) - $signed({1'b0, syn_time});
        
        if ((delta_t < -LEARN) || (delta_t > LEARN))
            lut_index = LEARN;
        else
            lut_index = delta_t + LEARN;
           
        stdp_calc = stdp_enable && (((spike_in != 0) && (neuron_time > refractory)) || (neuron_time == 0)) && (neuron_time <= LEARN);
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            stdp_calc_reg <= '0;
            lut_index_reg <= LEARN;
        end else begin
            stdp_calc_reg <= stdp_calc;
            lut_index_reg <= lut_index;
        end
        
    end
    //assign updated weight to reg if stdp logic
    always_ff @(posedge clk) begin
        if (reset) begin
            weight_reg <= init_weight;
            syn_time <= 4'd7;
        end else if (load_config) begin
            weight_reg <= init_weight;
            syn_time <= 4'd7;
        end else if (enable) begin
            if (spike_in != 0)
                syn_time <= 0;
            else if (syn_time < 7)
                syn_time <= syn_time + 1'b1;
            if (stdp_calc_reg) begin
                logic signed [b_weight+1:0] next_w;
                next_w = weight_reg + stdp_lut[lut_index_reg*4 +: 4];
                if (next_w == 0)
                    weight_reg <= 1'b1;
                else
                    weight_reg <= next_w;
            end
        end
    end
    
    //assign time output and product of weight and spike to be accum
    assign weight_to_accum = (enable && spike_in != 0) ?
        ($signed(weight_reg)) : '0;


endmodule

