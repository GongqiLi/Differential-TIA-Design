function [f3db, pole_in, pole_x, pole_y, pole_out]= Miller_Calc(W1,L1,Wl1,...
    Ll1,W2,L2,Wl2,Ll2,W3,L3,gmb_ratio, ...
    I1, I2, I3, Gain2, Gain3, Rd, Rload, Cload)
kn = 50e-6;

gm1 = sqrt(2*kn*(W1/L1)*I1);
pole_in = pole_in_calc(gm1,W1,L1, gmb_ratio);

pole_x = pole_x_calc(Rd,W1,L1,Wl1,Ll1,W2,L2,Gain2);

gml2 = sqrt(2*kn*(Wl2/Ll2)*I2);
pole_y = pole_y_calc(gml2,W2,L2,Wl2,Ll2,W3,L3,Gain2,...
    Gain3, gmb_ratio);

gm3 = sqrt(2*kn*(W3/L3)*I3);
pole_out = pole_out_calc(W3, L3,gm3, Rload, Cload, gmb_ratio,Gain3);

zeros = 1e99;
poles = [-1/pole_in -1/pole_x -1/pole_y -1/pole_out];
gain = 1;
sys = zpk(zeros,poles,gain);
f3db = bandwidth(sys)/(2*pi);

end

%% calculate Cgs, Cgd
function [Cgs,Cgd] = Cg_calc(W, L)
Cox = 2.3e-3;
Cov = 0.5e-9;
Cgs = (2/3)*W*L*Cox + W*Cov;
Cgd = W*Cov;
end
%% calculate Cdb, Csb
function [Cdb, Csb] = Cb_calc(W,isNmos, Vdb, Vsb)
% for db, sb calculation:
Ld = 3e-6;
CJ_n = 0.1e-3;
CJSW_n = 0.5e-9;
CJ_p = 0.3e-3;
CJSW_p = 0.35e-9;
MJ = 0.5;
MJSW = 0.33;
PB = 0.95;
AD = W*Ld;
PD = W+2*Ld;
if (isNmos ==1)
    Cdb = (AD*CJ_n)/(1+(Vdb)/(PB))^MJ + (PD*CJSW_n)/(1+(Vdb)/(PB))^MJSW;
    Csb = (AD*CJ_n)/(1+(Vsb)/(PB))^MJ + (PD*CJSW_n)/(1+(Vsb)/(PB))^MJSW;
else
    Cdb = (AD*CJ_p)/(1+(Vdb)/(PB))^MJ + (PD*CJSW_p)/(1+(Vdb)/(PB))^MJSW;
    Csb = (AD*CJ_p)/(1+(Vsb)/(PB))^MJ + (PD*CJSW_p)/(1+(Vsb)/(PB))^MJSW;
end
end
%% Approximate pole at input node
function pole_in = pole_in_calc(gm1,W1,L1,gmb_ratio)
Cin = 100e-15;
[Cdb, Csb] = Cb_calc(W1,1, 1.5, 1.5);

C_tot = Cin + Csb;
pole_in = 0.9*(1/((1+gmb_ratio)*gm1))*C_tot;

% pole_in = (1/((1+gmb_ratio)*gm1))*C_tot;
end
%% Approximate pole at node x
function pole_x = pole_x_calc(Rd,W1,L1,Wl1,Ll1,W2,L2,Gain2)
[Cgs1, Cgd1] = Cg_calc(W1, L1);
[Cgsl1, Cgdl1] = Cg_calc(Wl1, Ll1);
[Cgs2, Cgd2] = Cg_calc(W2, L2);

[Cdb1, Csb1] = Cb_calc(W1,1, 1.5, 1.5);
[Cdbl1, Csbl1] = Cb_calc(Wl1,0, 1.5, 1.5);

C_tot = (Cgd1+Cdb1)+(Cdbl1+Cgdl1)+(Cgs2+(1+1/Gain2)*Cgd2);
pole_x = 0.9*(0.5*Rd)*C_tot;

% C_tot = (Cgd1+Cdb1)+(Cdbl1+Cgdl1)+(Cgs2+(1+Gain2)*Cgd2);
% pole_x = 0.5*Rd*C_tot;
end
%% Approximate pole at node y
function pole_y = pole_y_calc(gml2,W2,L2,Wl2,Ll2,W3,L3,Gain2,...
    Gain3, gmb_ratio)

[Cgs2, Cgd2] = Cg_calc(W2, L2);
[Cgsl2, Cgdl2] = Cg_calc(Wl2, Ll2);
[Cgs3, Cgd3] = Cg_calc(W3, L3);
[Cdb2, Csb2] = Cb_calc(W2,1, 1.5, 1.5);
[Cdbl2, Csbl2] = Cb_calc(Wl2,1, 1.5, 1.5);

C_tot = (Cgsl2 + Csbl2) + (1+Gain2)*Cgd2 + Cdb2 + ...
    (1-Gain3)*Cgs3;
pole_y = 0.9*C_tot/((1+gmb_ratio)*gml2);

% C_tot = (Cgsl2 + Csbl2) + (1+1/Gain2)*Cgd2 + Cdb2 + ...
%     (1-Gain3)*Cgs3;
% pole_y = C_tot/((1+gmb_ratio)*gml2);
end
%% Approximate pole at output node
function pole_out = pole_out_calc(W3, L3,gm3, Rload, Cload, gmb_ratio,Gain3)
[Cgs3, Cgd2] = Cg_calc(W3, L3);
[Cdb3, Csb3] = Cb_calc(W3,1,1.5,1.5);

R_tot = (1/((1+gmb_ratio)*gm3))*Rload/((1/((1+gmb_ratio)*gm3))+Rload);
C_tot = Cload + (1-1/Gain3)*Cgs3;

pole_out = C_tot*(0.9)*R_tot;

% pole_out = (Cgs3 + Cload + Csb3)/((1+gmb_ratio)*gm3 + 1/Rload);
end