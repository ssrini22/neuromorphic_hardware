Current model for accuracy (no latency between accum/fire/WTA); run new implementation numbers.
Kintex-7: 0.773ns at 100MHz -> Fmax ~ 108MHz; compared to Fmax ~ 285MHz previously

Next version will try to:
- Cycle spike trains in Delta Modulator to help STDP
- Add DM threshold into scan chain wrapper
- Delay winner to be the cycle after threshold is reached, but maintain correct reset timing
- Look into pipelining the accumulator/comparing alternating clock cycles
