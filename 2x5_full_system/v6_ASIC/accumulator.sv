module accumulator #(
    parameter int b_weight = 4,  // Width of each synapse input
    parameter int b_accum  = 8,   // Width of accumulator (membrane potential)
    parameter int b_time = 3,
    parameter int b_thresh = 8
)(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic signed [b_weight+1:0] syn_0,
    input logic signed [b_weight+1:0] syn_1,
    input logic [b_time:0] refractory,      //refractory period in clock cycles
    input logic [b_time:0] leak_rate,       //-1 every leak_rate clock cycles
    input logic [b_thresh-1:0] threshold,
    input logic [b_time:0] neuron_time,     // Time since neuron last fired - cycles
    input logic any_fire,
    output logic fire,           // Reset trigger
    output logic signed [b_accum+1:0] accum_out    // Membrane potential

);

    logic signed [b_accum+1:0] accum_reg;
    logic [b_time:0] leak_counter;
    logic signed [b_accum+1:0] pre_accum;
    logic accum_on;
    
    always_ff @(posedge clk) begin
        pre_accum <= $signed(syn_0) + $signed(syn_1);
        if (fire)
            fire <= 1'b0;
        else
            fire <= enable && (accum_reg >= $signed(threshold));
    end

    assign accum_on = enable && (refractory < neuron_time);

    always_ff @(posedge clk) begin
        logic signed [b_accum+1:0] next_accum;
        if (reset) begin
            accum_reg <= 0;
            leak_counter <= '0;
        end else if (fire || any_fire) begin
            accum_reg <= 0;
            leak_counter <= '0;
        end else if (accum_on) begin
            next_accum = accum_reg + pre_accum;
            
            if (leak_counter < leak_rate) begin
                accum_reg <= next_accum;
                leak_counter <= leak_counter + 1'b1;
            end else begin
                leak_counter <= '0;
                accum_reg <= (next_accum > 0) ? (next_accum - 1'b1) :
                             (next_accum < 0) ? (next_accum + 1'b1) :
                             next_accum;
            end
        end
    end

    assign accum_out = accum_reg;

endmodule
