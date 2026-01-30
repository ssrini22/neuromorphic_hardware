`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/22/2026 11:15:58 AM
// Design Name: 
// Module Name: tb_scan_chain_wrapper
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


module tb_scan_chain_wrapper();


    //parameters, I/O
    localparam int N_inputs = 2;
    localparam int N_neurons = 5;
    localparam int b_weight = 4;
    localparam int b_accum = 8;
    localparam int b_thresh = 8;
    localparam int b_time = 3;
    localparam int LEARN = 3;
    parameter TOTAL_BITS = (N_inputs*N_neurons*(b_weight+2)) + (b_thresh) + 2*(b_time+1);
    
    logic clk = 0;
    logic reset = 1;
    
    //SC
    logic prog_clk = 0;
    logic prog_data;
    logic load_config;
    
    logic [N_inputs-1:0] spike_in = '0;
    logic [N_neurons-1:0] fire;
    logic [2:0] winner;
    
    logic [TOTAL_BITS-1:0] config_bits;
    int offset = TOTAL_BITS-1;
   
    localparam N = N_inputs*N_neurons;
    localparam B_WEIGHT = b_weight+2;
    localparam B_THRESH = b_thresh;
    localparam B_REFRAC = b_time+1;
    localparam B_LEAK = b_time+1;
    int rand_value;

    
    //DELTA MOD
    localparam int DATA_WIDTH = 11;
    localparam int STEP_SIZE = 4;
    localparam int MAX_VAL = 2047;
    localparam int MIN_VAL = 0;
    
    logic [DATA_WIDTH-1:0] ecg_sample;
    logic dm_reset;
    
    integer infile, outfile;
    integer status;
    integer sample_count = 0;

    //DUT
    scan_chain_wrapper#(
        .N_inputs(N_inputs),
        .N_neurons(N_neurons),
        .b_weight(b_weight), //6
        .b_accum(b_accum),
        .b_thresh(b_thresh),
        .b_time(b_time),
        .LEARN(LEARN),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut(
        .clk(clk),
        .reset(reset),
        .prog_clk(prog_clk),
        .prog_data(prog_data),
        .load_config(load_config),
        .dm_reset(dm_reset),
        .ecg_in(ecg_sample),
        .fire(fire),
        .winner(winner)
    );


    always #5 clk = ~clk;
    always #5 prog_clk = ~prog_clk;
    
    //serial shift
    task automatic serial_in(input logic [TOTAL_BITS-1:0] data);
        for (int i = 0; i < TOTAL_BITS; i++) begin
            @(posedge prog_clk);
            prog_data = data[TOTAL_BITS-1-i];
        end
    endtask
    
    initial begin
        reset = 1;
        dm_reset = 1;
        //SCW
        load_config = 0;
        prog_data = 0;
        config_bits = {TOTAL_BITS{1'b0}};
        
        #20 reset = 0; 
        
        //prepare config
        for (int i = 0; i < N; i++) begin
            assert(std::randomize(rand_value) with {rand_value >= -3; rand_value <= 5; rand_value != 0;});
            config_bits[offset -: B_WEIGHT] = rand_value;
            offset -= B_WEIGHT;
        end
        
        config_bits[offset -: B_THRESH] = B_THRESH'(20);
        offset -= B_THRESH;
        config_bits[offset -: B_REFRAC] = B_REFRAC'(2);
        offset -= B_REFRAC;
        config_bits[offset -: B_LEAK] = B_LEAK'(2);
        offset -= B_LEAK;
        
        //shift serial in
        @(negedge prog_clk);
        serial_in(config_bits);
        
        #1
        //load
        @(posedge clk);
        load_config = 1;
        @(posedge clk);
        load_config = 0;           
        
        //DM
        #10
        ecg_sample = DATA_WIDTH'(0);
        
        //File
        infile = $fopen("ecg_input_100.txt", "r");
        if (infile == 0) begin
            $display("Failed to open input file");
            $finish;
        end
        
        outfile = $fopen("dm_output.txt", "w");
        if (outfile == 0) begin
            $display("Failed to open output file");
            $finish;
        end
        
        status = $fscanf(infile, "%d\n", ecg_sample);
        @(posedge clk);

        dm_reset = 0;
        #10;
        
        //Modulator
        while (!$feof(infile)) begin
            sample_count = sample_count + 1;
            status = $fscanf(infile, "%d\n", ecg_sample);
            
            if (ecg_sample > 2047 || ecg_sample < 0) begin
                $display("Sample #%0d out-of-range: %d", sample_count, ecg_sample);
            end
            @(posedge clk);
//            $fwrite(outfile, "t=%0t, sample=%0d, dm_out=%0d\n",
//                    $time, ecg_sample, dm_out);        
        end

        $finish;
    end
    
endmodule
