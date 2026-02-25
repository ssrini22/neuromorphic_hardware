Code that went through the Librelane flow; some results and config.json used below; Everything passed except 1 antenna pin/net violation

KLayout:
<img width="1446" height="1410" alt="image" src="https://github.com/user-attachments/assets/a35f13da-4d43-4cb6-ac6d-9e8e8aabba9f" />
   
Desgin Instance Area: 31,799.2 um^2  
Total Power (Switching Power): 7.134 mW (2.638 mW)


config.json     
   
{   
    "DESIGN_NAME": "scan_chain_wrapper",    
    "VERILOG_FILES": [  
        "dir::scan_chain_wrapper.sv",  
        "dir::neuron_array.sv",  
        "dir::delta_mod.sv",  
        "dir::accumulator.sv",  
        "dir::synapse_unit_2.sv",  
        "dir::wta.sv"  
    ],  
    "CLOCK_PERIOD": 10.0,  
    "CLOCK_PORT": "clk",  
    "CLOCK_NET": "clk",  
    "pdk::sky130A": {  
        "FP_CORE_UTIL": 30,  
        "PL_TARGET_DENSITY_PCT": 35,  
        "MAX_FANOUT_CONSTRAINT": 8,  
        "SYNTH_STRATEGY": "AREA 0",  
        "GRT_REPAIR_ANTENNAS": true,  
        "RUN_HEURISTIC_DIODE_INSERTION": true,  
        "DIODE_INSERTION_STRATEGY": 3,  
        "GRT_ANTENNA_ITERS": 10,  
        "DPL_RELAX_DIODE_PLACEMENT": true  
    }  
}  


