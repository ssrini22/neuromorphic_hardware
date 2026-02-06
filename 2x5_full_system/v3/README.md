Current model for accuracy (no latency between accum/fire/WTA); run new implementation numbers.

Spartan-7: WNS-0.773ns at 100MHz (10ns) -> Fmax ~ 108MHz; compared to Fmax ~ 181Hz previously
Basys3: WNS-0.576 at 100MHz (10ns),  at  -> Fmax ~ 106MHz; compared to Fmax ~ 185MHz previously
Kintex7: WNS-2.964 at 100MHz (10ns),  at  -> Fmax ~ 142MHz; compared to Fmax ~ 285MHz previously

Next version will try to:
- Cycle spike trains in Delta Modulator to help STDP
- Add DM threshold into scan chain wrapper
- Delay winner to be the cycle after threshold is reached, but maintain correct reset timing
- Look into pipelining the accumulator/comparing alternating clock cycles


<img width="2836" height="1318" alt="image" src="https://github.com/user-attachments/assets/9aebedf1-508e-42c8-8b64-91338c059d32" />
Fig. 1: Behavioral Simulation Results

Fig. 1 shows the correct accumulation timing and reset, but early fire/winner.
