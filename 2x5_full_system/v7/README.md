This is the final, optimized version from v5 for design accuracy and gathering FPGA results.  
Final Changes:


- synapse_unit.sv: fix stdp_calc to not include refractory period/update properly
- accumulator.sv: fix extra cycle of refractory period; parameterize input synapses so array size can scale
- delta_mod.sv: change STEP_SIZE from parameter to input for SCW
- scan_chain_wrapper.sv: include DM threshold as a serial system parameter
- neuron_array.sv: change to factor in parameterizing input synapses to accumulator from synapse unit



Basys3 (6ns): WNS = 0.493ns => Fmax = 181MHz  
(LUT, FF, IO) : 529, 432, 27  
Pdyn = 0.033W


SOFTWARE MODEL: Hardware faithful implementation using snnTorch to train on MIT-BIH Database and explore classification accuracy and future work
