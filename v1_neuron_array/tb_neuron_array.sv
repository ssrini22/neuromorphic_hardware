`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Sanjeev Srinivasan
// 
// Create Date: 12/19/2025 11:20:27 AM
// Design Name: 
// Module Name: tb_neuron_array
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


module tb_neuron_array;

    //parameters, I/O
    localparam int N_inputs = 4;
    localparam int N_neurons = 4;
    localparam int DATA_WIDTH = 16;
    localparam int b_weight = 4;
    localparam int b_accum = 8;
    localparam int b_thresh = 8;
    localparam int b_time = 3;
    localparam int LEARN = 3;
    
    logic clk = 0;
    logic reset = 1;
    logic [N_inputs-1:0] spike_in = '0;
    logic [N_neurons-1:0] fire;
    
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
        .spike_in(spike_in),
        .fire(fire)
    );

    always #5 clk = ~clk;

    initial begin
        #20 reset = 0;
        #15;
        
        repeat (12) begin
            @(posedge clk);
            spike_in = 4'b0001;   // input 0
            @(posedge clk);
            spike_in = 4'b0000;
        end
        
        #10;

        @(posedge clk);
        spike_in = 4'b0001;   // input 0
        @(posedge clk);
        spike_in = 4'b0000;
        
        #30;
        
        $finish;
    end

endmodule
