Description: This version maintains the design accuracy, and significantly improves all performance metrics. More detailed description to come.
Changes: DM spike trains now pulsed. Modified comb/seq logic in accumulator.sv and synapse_unit.sv, bug fixes in top modules.
Yet to add: Adding DM Threshold to SCW, Replace 2D array with 1D, syanpse_unit correct bit sizing/4 bit size limit, STDP logic check and more..

Simulation Results:

<img width="2831" height="1471" alt="image" src="https://github.com/user-attachments/assets/7d7a26de-0193-4327-bd68-c3b4ba2ec39a" />


Performance:
Kintex-7: WNS @ 200MHz/5ns: 0.766ns -> Fmax (calculated)~ 236 MHz    

Utilization: LUT: 548 (1.34%), FF: 419 (0.51%), IO: 27 (9.47%)    

Dyanmic Power: @ 200MHz/5ns: 0.039W   


Basys3: WNS @ 100MHz/10ns: 2.777ns; WNS @ 142.9MHz/7ns: 0.813ns -> Fmax (calculated)~ 161 MHz   

Utilization: LUT: 549 (2.64%), FF: 419 (1.01%), IO: 27 (25.47%)    

Dyanmic Power: @ 100MHz/10ns: 0.018W; @ 142.9MHz/7ns: 0.026W
