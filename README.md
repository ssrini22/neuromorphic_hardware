DPE-Based Neurmorphic Hardware for Continuous-Time Biomedical Signal Classification   

An event-driven Spiking Neural Network (SNN) accelerator for real-time ECG arrhythmia classification at the edge — designed in SystemVerilog, validated across four Xilinx FPGA families, and carried through a full RTL-to-GDSII ASIC flow on a 130nm process.

291 MHz peak (Kintex-7) · 31,799 µm² die area · 2.64 mW switching power @ 100 MHz · 114 MHz est. max ASIC frequency

Published at IEEE Dallas Circuits and Systems (DCAS) Conference, April 2026. Please use the citation below.

_______________________________________________________________________________________

Overview

Cardiovascular disease detection depends heavily on continuous ECG monitoring, but real-time, on-device arrhythmia classification is a poor fit for conventional deep learning (CNNs/RNNs) on power- and resource-constrained wearables. This project explores Spiking Neural Networks — a event-driven, biologically-inspired computing paradigm — as a low-power alternative, implemented as a Dot Product Engine (DPE)-based SNN accelerator with online learning via STDP (Spike-Timing-Dependent Plasticity).

The system takes raw ECG samples, encodes them into spike trains via delta modulation, classifies each heartbeat into one of five AAMI categories (N, S, V, F, Q) using a DPE-based spiking neuron array, and outputs a classification via Winner-Take-All (WTA) competition — entirely in the event-driven, sparse spike domain.

_______________________________________________________________________________________

System Architecture

<img width="2880" height="1668" alt="image" src="https://github.com/user-attachments/assets/6f37e090-42ba-4a84-96e4-7a17ed94e07a" />

- Delta Modulator — encodes discretized ECG samples into two-channel spike trains (time-difference representation)
- DPE-based SNN array — the core computation: a synapse unit (localized memory, online STDP learning) feeding an accumulator / Leaky-Integrate-and-Fire (LIF) neuron per class
- Winner-Take-All (WTA) — first-spike-priority classification across the 5 output classes
- Scan-Chain Wrapper (SCW) — top-level reconfiguration interface exposing synapse weights, neuron threshold, refractory period, leak rate, and delta-modulator step size at runtime, enabling reuse across other continuous-time biomedical signals beyond ECG

_______________________________________________________________________________________

Results

FPGA Implementation

<img width="512" height="400" alt="image" src="https://github.com/user-attachments/assets/34c8620f-4350-420d-a900-34a129b74ec1" />  

Frequency Analysis


<img width="518" height="400" alt="image" src="https://github.com/user-attachments/assets/d0addb60-c80b-4631-a4f2-cc75972aade1" />  


Dynamic Power Analysis

  
Resource Utilization


<img width="635" height="400" alt="image" src="https://github.com/user-attachments/assets/21f5f81f-356e-4128-a57f-d204d849aa1a" />  

_______________________________________________________________________________________


Repository Structure

This repo (2x5_full_system) contains the RTL implementation across the design iterations, with details in each version
_______________________________________________________________________________________

Tools & Technologies

System Verilog | Vivado | LibreLane | Skywater 130nm PDK | snnTorch/pyTorch | MIT-BIH Arrhythmia Database
_______________________________________________________________________________________

Publication

S. Srinivasan and N. N. Chakraborty, "DPE-Based Neuromorphic Hardware for Continuous-Time Biomedical Signal Classification," 2026 IEEE 19th Dallas Circuits and Systems Conference (DCAS), Dallas, TX, USA, 2026, pp. 1-4, doi: 10.1109/DCAS69364.2026.11545142.
_______________________________________________________________________________________

Citation 

S. Srinivasan and N. N. Chakraborty, "DPE-Based Neuromorphic Hardware for Continuous-Time Biomedical Signal Classification," 2026 IEEE 19th Dallas Circuits and Systems Conference (DCAS), Dallas, TX, USA, 2026, pp. 1-4, doi: 10.1109/DCAS69364.2026.11545142. keywords: {Timing;Electrocardiography;Neurons;Frequency;Architecture;Computer architecture;Printing;Neuromorphics;Field programmable gate arrays;Arrays;Neuromorphic;ECG;spiking neural networks;dot-product engine;delta modulator;FPGA;ASIC},


_______________________________________________________________________________________

Author(s)

Sanjeev Srinivasan - https://www.linkedin.com/in/sanjeevsrinivasan2003/
Nishith Charkraborty
