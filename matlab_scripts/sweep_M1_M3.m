function [W1_optimal, Vov_CG_optimal, I1_optimal, ...
    W3_optimal, Vov_CD_optimal, I3_optimal] = sweep_M1_M3(Gain1, Gain2, Gain3, W2, I2)

% This is an ambitious function that sweep M1 and M3 concurrently. The
% result however is not satisfactory since the global optimal point requires
% an Vov of CD stage 0.07V.
% 
% Input: 
% Gain1, Gain2, Gain3: Gain of the three stages
% W2: Width of Stage 2
% I2: Current of Stage 2
% 
% Output: 
% The value of W1, Vov_CG, I1, W3, Vov_CD, I3 that produces highest FOM


% Constant
kn = 50e-6;
Rload = 10e3;
Cload = 500e-15;
gmb_ratio = 0.15;

[Ru, Rd] = Gain_cg_solver(Gain1);
I4 = 5/(Ru+Rd);

% Temporarily defined variable
Wl1 = 8e-6;
Ll1 = 2e-6;
Wl2 = 2e-6;
Ll2 = 1e-6;
L1 = 1e-6;

% Sweeping Initialization
Vov_CG = 0.15: 0.001: 0.16;
W1 = 8.4e-6: 0.01e-6: 8.6e-6;
Vov_CD = 0.06: 0.001: 0.08;

I1 = zeros(length(Vov_CG), length(W1), length(Vov_CD));
W3 = zeros(length(Vov_CG), length(W1), length(Vov_CD));
I3 = zeros(length(Vov_CG), length(W1), length(Vov_CD));

f3db = zeros(length(Vov_CG), length(W1), length(Vov_CD));
pole_in = zeros(length(Vov_CG), length(W1), length(Vov_CD));
pole_x = zeros(length(Vov_CG), length(W1), length(Vov_CD));
pole_y = zeros(length(Vov_CG), length(W1), length(Vov_CD));
pole_out = zeros(length(Vov_CG), length(W1), length(Vov_CD));
FOM = zeros(length(Vov_CG), length(W1), length(Vov_CD));
power = zeros(length(Vov_CG), length(W1), length(Vov_CD));

% Sweeping
step = 0;
wait = waitbar(step, 'Sweeping');
for i = 1:length(Vov_CG)
    for j = 1:length(W1)
        for k = 1:length(Vov_CD)
         
            step = step+1;
            waitbar(step/(length(Vov_CG)*length(W1)*length(Vov_CD)), ...
            wait, sprintf('Sweeping...%f%%',100*step/(length(Vov_CG)*length(W1)*length(Vov_CD))))
            I1(i,j,k) = 0.5 * kn * (W1(j)/L1) * Vov_CG(i).^2;
            [W3(i,j,k),I3(i,j,k)] = Gain_cd_solver(Gain3,gmb_ratio,Vov_CD(k),Rload);     
            [f3db(i,j,k), pole_in(i,j,k), pole_x(i,j,k), pole_y(i,j,k), pole_out(i,j,k)]=... 
            Miller_Calc(W1(j),L1,Wl1,Ll1,W2,L1,Wl2,Ll2,W3(i,j,k),L1,...
                        gmb_ratio,I1(i,j,k),I2,I3(i,j,k),Gain2,Gain3,Rd,Rload,Cload);
            power(i,j,k) = 2*5*(I1(i,j,k)+I2+I3(i,j,k)+I4);
            FOM(i,j,k) = Gain1*Gain2*Gain3*f3db(i,j,k)/power(i,j,k);
        end
    end
end
close(wait)

% Maximal Point 
max_FOM = max(max(max(FOM)));
[x,y,z] = ind2sub(size(FOM),find(FOM == max_FOM));
W1_optimal = W1(y);
Vov_CG_optimal = Vov_CG(x);
I1_optimal = I1(x,y,z);
W3_optimal = W3(x,y,z);
Vov_CD_optimal = Vov_CD(z);
I3_optimal = I3(x,y,z);

end