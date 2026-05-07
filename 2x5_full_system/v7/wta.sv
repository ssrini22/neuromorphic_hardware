`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2026 04:11:58 PM
// Design Name: 
// Module Name: wta
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


module wta#(
    parameter int N_neurons = 5
)(
    input logic enable,
    input logic [N_neurons-1:0] fire,
    output logic [N_neurons-1:0] winner,
    output logic [N_neurons-1:0] reset_accums
);

    logic any_fire;
    
    always_comb begin
        any_fire = '0;
        winner = '0;
        reset_accums = '0;
        
        if (enable) begin
            any_fire = |fire;
            for (int i = 0; i < N_neurons; i++) begin
                if (fire[i]) begin
                    winner[i] = 1'b1;
                    break;
                end
            end
            
            reset_accums = any_fire ? (~winner) : '0;    
        end 
    end

endmodule
