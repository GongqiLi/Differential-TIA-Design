function [W3,I3] = Gain_cd_solver(Av3, gmb_ratio, Vov_min, RL)
syms gm
L = 1e-6;
kn = 50e-6;
eqn = (gm*RL/(1+gmb_ratio*gm*RL))/((gm*RL)/(1+gmb_ratio*gm*RL)+1) == Av3;
gm3 = solve(eqn, gm);
I3 = 0.5*gm3*Vov_min;
W3 = (2*I3)/(kn*Vov_min^2)*L;
end