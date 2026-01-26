Fully wired 2x5 Neuron Array Neuromorphic Hardware System for ECG Signal Classification.

Includes: Delta Modulation of ECG Signal from MIT-BIH Arrhythmia Database, Serial Scan Chain Wrapper for initial synapse weights and array parameters, 2x5 Neuron Array, and Winner Take All Circuit.

Note: delta_modulator.sv and scan_chain_wrapper.sv are seperate DUT's called in the testbench; can analysze results seperately, or instantiate delta_modulator.sv in scan_chain_wrapper.sv, pass UP/DOWN spikes internally, and pass in the ecg signal from top module (v2).
