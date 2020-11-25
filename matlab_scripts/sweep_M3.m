function [W3_optimal, Vov_CD_optimal, I3_optimal] = sweep_M3(Gain1, Gain2, Gain3, W1, W2, I1, I2)

% The function aims for finding optimized operating point of M3 given
% predetermined biasing of M1 and M2.
% 
% Input: 
% Gain1, Gain2, Gain3: Gain of the three stages
% W1, W2: Width of Stage 1 & Stage 2
% I1, I2: Current of Stage 1 & Stage 2
% 
% Output: 
% The value of W3, Vov_CD, I3 that produces the highest FOM


% Constant
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
Vov_CD = 0.1: 0.01: 0.4;
W3 = zeros(length(Vov_CD),1);
I3 = zeros(length(Vov_CD),1);
f3db = zeros(length(Vov_CD),1);
pole_in = zeros(length(Vov_CD),1);
pole_x = zeros(length(Vov_CD),1);
pole_y = zeros(length(Vov_CD),1);
pole_out = zeros(length(Vov_CD),1);
FOM = zeros(length(Vov_CD),1);
power = zeros(length(Vov_CD),1);

% Sweeping
for i = 1:length(Vov_CD)
    [W3(i),I3(i)] = Gain_cd_solver(Gain3, gmb_ratio, Vov_CD(i), Rload);
    [f3db(i), pole_in(i), pole_x(i), pole_y(i), pole_out(i)]=... 
        Miller_Calc(W1,L1,Wl1,Ll1,W2,L1,Wl2,Ll2,W3(i),L1,...
                    gmb_ratio,I1,I2,I3(i),Gain2,Gain3,Rd,Rload,Cload);
        power(i) = 2*5*(I1+I2+I3(i)+I4);
        FOM(i) = Gain1*Gain2*Gain3*f3db(i)/power(i);
end

% Optimal Point 
max_FOM = max(FOM);
x = find(FOM==max_FOM);
Vov_CD_optimal = Vov_CD(x);
W3_optimal = W3(x);
I3_optimal = I3(x);

% Some plots potentially useful
subplot(3,2,1)
plot(Vov_CD, FOM)
xlabel('Vov of CD')
ylabel('FOM')
subplot(3,2,2)
plot(Vov_CD, f3db)
xlabel('Vov of CD')
ylabel('f3db')
subplot(3,2,3)
plot(Vov_CD, I3)
xlabel('Vov of CD')
ylabel('I3')
subplot(3,2,4)
plot(Vov_CD, W3)
xlabel('Vov of CD')
ylabel('W3')
subplot(3,2,5)
plot(Vov_CD,pole_out)
xlabel('Vov of CD')
ylabel('pole out')
subplot(3,2,6)
plot(Vov_CD,pole_y)
xlabel('Vov of CD')
ylabel('pole y')
% sgtitle('Gain1=37000, Gain2=1.49, Gain3=0.76, I1=20e-6, I2=13e-6, W1=5e-6, W2=5.9e-6')
end