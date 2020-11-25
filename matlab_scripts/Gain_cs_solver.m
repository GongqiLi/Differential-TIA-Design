function [W2, Vov, I2] = Gain_cs_solver(Av2, gmb_ratio, WL2, Vov_min)
kn = 50e-6;
L = 1e-6;
W2 = Av2^2*(1+gmb_ratio)^2*WL2;
Vov = Vov_min*Av2*(1+gmb_ratio);
I2 = 0.5*kn*(W2/L)*(Vov_min)^2;
end