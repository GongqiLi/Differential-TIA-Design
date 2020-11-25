%% Parameter definition
Gain_tot = 42e3; % leave some headroom
gmb_ratio = 0.15;
Vov_CS = 0.3;
Vov_CD = 0.25;
WL2 = 2e-6;  
RL = 10e3;
I1 = 20e-6;
Rload = 10e3;
Cload = 500e-15;

Wl1 = 8e-6;
Ll1 = 2e-6;
Wl2 = 2e-6;
Ll2 = 1e-6;
% Temporarily defined variable
W1 = 5e-6;
L1 = 1e-6;

Gain1 = 10e3:1e3:90e3;
Gain3 = 0.4:0.02:0.8;

Rd = zeros(length(Gain1),1);
Ru = zeros(length(Gain1),1);


Gain2 = zeros(length(Gain1),length(Gain3));

W2 = zeros(length(Gain1),length(Gain3));
Vov_l2 = zeros(length(Gain1),length(Gain3));
I2 = zeros(length(Gain1),length(Gain3));

W3 = zeros(length(Gain1),length(Gain3));
I3 = zeros(length(Gain1),length(Gain3));
I4 = zeros(length(Gain1),length(Gain3));
I_tot = zeros(length(Gain1),length(Gain3));

f3db_miller = zeros(length(Gain1),length(Gain3));
FOM = zeros(length(Gain1),length(Gain3));


%% loop over gains
step = 0;
wait = waitbar(step, 'Sweeping');
for i = 1:1:length(Gain1)
    Gain_twostages = Gain_tot/(Gain1(i));
    [Rd(i),Ru(i)] = Gain_cg_solver(Gain1(i));
    for j = 1:1:length(Gain3)
        step = step+1;
        waitbar(step/(length(Gain1)*length(Gain3)), ...
        wait, sprintf('Sweeping...%f%%',100*step/(length(Gain1)*length(Gain3))))
    
        Gain2(i,j) = Gain_twostages/Gain3(j);
        [W2(i,j), Vov_l2(i,j), I2(i,j)] = Gain_cs_solver(Gain2(i,j), gmb_ratio, WL2, Vov_CS);
        [W3(i,j),I3(i,j)] = Gain_cd_solver(Gain3(j), gmb_ratio, Vov_CD, RL);
        
        %{
        [f3db_miller(i,j)]=ZVTC_calc(W1,L1,Wl1,...
        Ll1,W2(i,j),L1,Wl2,Ll2,W3(i,j),L1,Csb_ratio,Cdb_ratio,gmb_ratio, ...
        I1, I2(i,j), I3(i,j), Gain2(i,j), Gain3(j), Rd(i), Rload, Cload);
        %}
        
        f3db_miller(i,j)=Miller_Calc(W1,L1,Wl1,...
            Ll1,W2(i,j),L1,Wl2,Ll2,W3(i,j),L1,gmb_ratio, ...
            I1, I2(i,j), I3(i,j), Gain2(i,j), Gain3(j), Rd(i), Rload, Cload);

        I4(i,j) = 5/(Ru(i)+Rd(i));
        I_tot(i,j) = I1 + I2(i,j) + I3(i,j) + I4(i,j);
        FOM(i,j) = Gain_tot*f3db_miller(i,j)/(2*5*I_tot(i,j));
    end
end

% Filtering points with bandwidth lower than 70MHz and choose the optimal
% point from the remnant
filter = f3db_miller;
filter(filter <= 70e6) = 0;
max_FOM = max(max(sign(filter).*FOM));

[x,y] = find(FOM==max_FOM)
f3db_miller(x, y)
FOM(x, y)
        
%% Writing data
% writematrix(round(f3db_miller,0), './data/BW.txt');
% writematrix(Gain3, './data/Gain3-xaxis.txt');
% writematrix(Gain1, './data/Gain1-yaxis.txt');
% writematrix(round(I_tot,4,'significant'), './data/I_tot.txt');
% writematrix(round(FOM,4,'significant'), './data/FOM.txt');