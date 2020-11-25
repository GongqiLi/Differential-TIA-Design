* Design Project EE 114/214A - 2020
* Team Member 1 Name:
* Team Member 2 Name:
* Please fill in the specification achieved by your circuit 
* before you submit the netlist.
**************************************************************
* SUNET IDs of team members = 
* The specifications that this script achieves are: 
* Power  =
* Gain   =
* Bandwidth =
* FOM = 
* Bonus
* Spot Noise @ 1 kHz = 
* FOM =  
***************************************************************

.subckt tia iina iinb vouta voutb vdd vss cg_outa cs_outa feed_outa feed_outb

** Including the model file
.include /afs/ir.stanford.edu/class/ee114/hspice/ee114_hspice.sp

*** Your Transimpedance Amplifier
** parameters 
.param ml1_w = 2.6u	ml1_l = 4u
.param m1_w = 6.8u	m1_l = 2u
.param mb1_w = 2.6u	mb1_l = 8u

.param ru = 105k    rd = 210k 

.param ml2_w = 2.2u	ml2_l = 1u
.param m2_w = 3.6u	m2_l = 1u
.param mb2_w = 2u	mb2_l = 5u

.param m3_w = 40u		m3_l = 1u
.param mb3_w = 4u	mb3_l = 2u

.param iref = 10u
.param mi1_w = 2u       mi1_l = 4u
.param mi2_w = 2u       mi2_l = 4u
.param mi3_w = 2u       mi3_l = 2u

** Adding new structure
.param rb = 50k
.param mb_w = 8u mb_l = 4u

**	d	g	s	b	n/pmos114	w	l
*** A Side ***
* CG stage 
ml1a	cg_outa	vb_pmos	vdd	vdd	pmos114	w='ml1_w'	l='ml1_l'
m1a	cg_outa	feed_outa	iina	vss	nmos114	w='m1_w'	l='m1_l'
mb1a	iina	vb_nmos	vss	vss	nmos114	w='mb1_w'	l='mb1_l'
rua	vdd	cg_outa	'ru'
rda	cg_outa	vss	'rd'
* Feedback stage
mba   feed_outa iina vss vss nmos114 w='mb_w' l='mb_l'
rba   vdd feed_outa 'rb'
* CS stage
ml2a	vdd	vdd	cs_outa	vss	nmos114	w='ml2_w'	l='ml2_l'
m2a	cs_outa	cg_outa	d_gnd	vss	nmos114	w='m2_w'	l='m2_l'
mb2a	d_gnd	vb_nmos	vss	vss	nmos114	w='mb2_w'	l='mb2_l'
* CD stage
m3a	vdd	cs_outa vouta	vss	nmos114	w='m3_w'	l='m3_l'
mb3a	vouta	vb_nmos	vss	vss	nmos114 w='mb3_w'	l='mb3_l'

*** B Side ***
* CG stage 
ml1b	cg_outb	vb_pmos	vdd	vdd	pmos114	w='ml1_w'	l='ml1_l'
m1b	cg_outb	feed_outb	iinb	vss	nmos114	w='m1_w'	l='m1_l'
mb1b	iinb	vb_nmos	vss	vss	nmos114	w='mb1_w'	l='mb1_l'
rub	vdd	cg_outb	'ru'
rdb	cg_outb	vss	'rd'
* Feedback stage
mbb   feed_outb iinb vss vss nmos114 w='mb_w' l='mb_l'
rbb   vdd feed_outb 'rb'
* CS stage
ml2b	vdd	vdd	cs_outb	vss	nmos114	w='ml2_w'	l='ml2_l'
m2b	cs_outb	cg_outb	d_gnd	vss	nmos114	w='m2_w'	l='m2_l'
mb2b	d_gnd	vb_nmos	vss	vss	nmos114	w='mb2_w'	l='mb2_l'
* CD stage
m3b	vdd	cs_outb voutb	vss	nmos114	w='m3_w'	l='m3_l'
mb3b	voutb	vb_nmos	vss	vss	nmos114 w='mb3_w'	l='mb3_l'

*** Current Bias ***
iref    vdd     vb_nmos 'iref'
mi1     vb_nmos vb_nmos vss     vss     nmos114 w='mi1_w'       l='mi1_l'
mi2     vb_pmos vb_nmos vss     vss     nmos114 w='mi2_w'       l='mi2_l'
mi3     vb_pmos vb_pmos vdd     vdd     pmos114 w='mi3_w'       l='mi3_l'


.ends
