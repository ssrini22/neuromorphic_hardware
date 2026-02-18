Best Timing Version I was able to achieve so far. It adds/changes the following:

- It incorporates the old compare and fire concept in the accumulator (instead of adding the module itself, just needed to make 'fire' sequential)
- Removes 2-D arrays
- Adds some max fanout constraints for 'pre_accum' and 'accum_reg' to reduce the net delay

Results:
Design accuracy is maintained; no extra accumulation, all columns reset on fire, one cycle fire; same pre_accum latency as v4
-> Accuracy is essentially the same as v4

Behavioral Sim Example

<img width="2819" height="1328" alt="image" src="https://github.com/user-attachments/assets/1d50a98f-e532-479a-b557-b02bb5d5fa91" />


Post Implementation Numbers:   
Kintex-7:   
LUT, FF, IO : (516, 424, 27)    
P(dynamic) = 0.061mW    
WNS @ 300MHz/3.333ns = 0.244ns => Fmax = 324MHz   

Basys3:   
LUT, FF, IO : (509, 424, 27)    
P(dynamic) = 0.032mW    
WNS @ 200MHz/5ns = 0.251ns => Fmax = 211MHz   

ArtyA7:   
LUT, FF, IO : (516, 424, 27)    
P(dynamic) = 0.043mW    
WNS @ 200MHz/5ns = 0.167ns => Fmax = 207MHz    

Spartan7:   
LUT, FF, IO : (514, 424, 27)    
P(dynamic) = 0.042mW    
WNS @ 200MHz/5ns = 0.351ns => Fmax = 215MHz    

