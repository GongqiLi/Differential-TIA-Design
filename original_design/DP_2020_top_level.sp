* Design Project EE 114/214A - 2020
* Top-Level Testbench

** Including the model file
.include /afs/ir.stanford.edu/class/ee114/hspice/ee114_hspice.sp
.include ./DP_2020_schematic.sp

** Defining input/output circuit parameters
.param Cin = 100f
.param CL  = 250f
.param RL  = 20k

** Defining the supply voltages
vdd vdd 0 2.5
vss vss 0 -2.5

** Defining the input current source
* Note, having each source with ac magnitude of 0.5 (as below) ensures a differential input magnitude of 1

** For ac simulation uncomment the following 2 lines
Iina	iina	vdd	ac	0.5	
Iinb 	vdd	iinb	ac	0.5	

** For transient simulation uncomment the following 2 lines
*Iina	iina	vdd	sin(0 0.5u 1e6)
*Iinb	vdd	iinb	sin(0 0.5u 1e6)

** Defining input capacitance
Cina	vdd	iina	'Cin'
Cinb	vdd	iinb	'Cin'

** Defining the differential load
RL	vouta	voutb	'RL'
CL	vouta	voutb	'CL'

** Instantiating the TIA
x1 iina iinb vouta voutb vdd vss tia

*** Defining the analysis
.op
.option post brief nomod

** For ac simulation uncomment the following line
.ac dec 100 1k 1g

* For noise simulation uncomment the following line
* .noise v(vouta, voutb) Iina 1000

* Differential gain 
.measure ac gaindiff max vdb(vouta, voutb)
.measure ac f3db when vdb(vouta, voutb) = 'gaindiff-3'

** For transient simulation uncomment the following line
*.tran 0.01u 4u 

.end
