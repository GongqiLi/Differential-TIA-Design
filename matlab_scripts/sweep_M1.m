function [W1_optimal, Vov_CG_optimal, I1_optimal, max_FOM] = sweep_M1(Gain1, Gain2, Gain3, W2, W3, I2, I3)

% The function aims for finding optimized operating point of M1 given
% predetermined biasing of M2 and M3.
% 
% Input: 
% Gain1, Gain2, Gain3: Gain of the three stages
% W2, W3: Width of Stage 2 & Stage 3
% I2, I3: Current of Stage 2 & Stage 3
% 
% Output: 
% The value of W1, Vov_CG, I1 that produces the highest FOM

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
Vov_CG = 0.1: 0.01: 0.4;
W1 = 1e-6: 1e-6: 40e-6;
I1 = zeros(length(Vov_CG), length(W1));
f3db = zeros(length(Vov_CG), length(W1));
pole_in = zeros(length(Vov_CG), length(W1));
pole_x = zeros(length(Vov_CG), length(W1));
pole_y = zeros(length(Vov_CG), length(W1));
pole_out = zeros(length(Vov_CG), length(W1));
FOM = zeros(length(Vov_CG), length(W1));
power = zeros(length(Vov_CG), length(W1));

% Sweeping
for i = 1:length(Vov_CG)
    for j = 1:length(W1)
        I1(i,j) = 0.5 * kn * (W1(j)/L1) * Vov_CG(i).^2;
        [f3db(i,j), pole_in(i,j), pole_x(i,j), pole_y(i,j), pole_out(i,j)]=... 
            Miller_Calc(W1(j),L1,Wl1,Ll1,W2,L1,Wl2,Ll2,W3,L1,...
                        gmb_ratio,I1(i,j),I2,I3,Gain2,Gain3,Rd,Rload,Cload);
        power(i,j) = 2*5*(I1(i,j)+I2+I3+I4);
        FOM(i,j) = Gain1*Gain2*Gain3*f3db(i,j)/power(i,j);
    end
end

% Contour Plot
max_FOM = max(max(FOM));
[x,y] = find(FOM==max_FOM);
Vov_CG_optimal = Vov_CG(x);
W1_optimal = W1(y);
I1_optimal = I1(x,y);
contour(Vov_CG, W1, FOM', 100)
xlabel('Vov_CG')
ylabel('W1')

% Envelope Plot
for j=1:length(W1)
    plot(Vov_CG, FOM(:, j))
    hold on
end
xlabel('Vov of CG')
ylabel('FOM')
hold off
end
