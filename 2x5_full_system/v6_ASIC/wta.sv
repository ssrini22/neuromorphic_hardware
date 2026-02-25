module wta#(
    parameter int N_neurons = 5
)(
    input logic enable,
    input logic [N_neurons-1:0] fire,
    output logic [N_neurons-1:0] winner,
    output logic [N_neurons-1:0] reset_accums
);

    logic any_fire;
    logic found;
    
    always_comb begin
        any_fire = '0;
        winner = '0;
        reset_accums = '0;
        found = 1'b0;
        
        if (enable) begin
            any_fire = |fire;
            for (int i = 0; i < N_neurons; i++) begin
                if (fire[i] && !found) begin
                    winner[i] = 1'b1;
                    found = 1'b1;
                end
            end
            reset_accums = any_fire ? (~winner) : '0;      
        end 
    end

endmodule
