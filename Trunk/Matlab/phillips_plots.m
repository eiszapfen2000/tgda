close all

g = 9.81;
k = 0:0.001:0.15;

phillips_10_k = Phillips1D(k, [10 0], 1, 0);
phillips_12_k = Phillips1D(k, [12.5 0], 1, 0);
phillips_15_k = Phillips1D(k, [15 0], 1, 0);
phillips_17_k = Phillips1D(k, [17.5 0], 1, 0);
phillips_20_k = Phillips1D(k, [20 0], 1, 0);

% l = 10^(-3);
% phillips_energy_w_10_l = Phillips1D(k, [10 0], 1, l);
% phillips_energy_w_12_l = Phillips1D(k, [12.5 0], 1, l);
% phillips_energy_w_15_l = Phillips1D(k, [15 0], 1, l);
% phillips_energy_w_17_l = Phillips1D(k, [17.5 0], 1, l);
% phillips_energy_w_20_l = Phillips1D(k, [20 0], 1, l);
% 
% % 
% phillips_energy_w_10_a = Phillips1D(k, [10 0], 0.000081, 0);
% phillips_energy_w_12_a = Phillips1D(k, [12.5 0], 0.000081, 0);
% phillips_energy_w_15_a = Phillips1D(k, [15 0], 0.000081, 0);
% phillips_energy_w_17_a = Phillips1D(k, [17.5 0], 0.000081, 0);
% phillips_energy_w_20_a = Phillips1D(k, [20 0], 0.000081, 0);
% 
% phillips_energy_w_10_a_l = Phillips1D(k, [10 0], 0.0081, l);
% phillips_energy_w_12_a_l = Phillips1D(k, [12.5 0], 0.0081, l);
% phillips_energy_w_15_a_l = Phillips1D(k, [15 0], 0.0081, l);
% phillips_energy_w_17_a_l = Phillips1D(k, [17.5 0], 0.0081, l);
% phillips_energy_w_20_a_l = Phillips1D(k, [20 0], 0.0081, l);


% o_phillips_10_k = [k', phillips_10_k'];
% o_phillips_12_k = [k', phillips_12_k'];
% o_phillips_15_k = [k', phillips_15_k'];
% o_phillips_17_k = [k', phillips_17_k'];
% o_phillips_20_k = [k', phillips_20_k'];
% 
% csvwrite('phillips_10_k.dat', o_phillips_10_k);
% csvwrite('phillips_12_k.dat', o_phillips_12_k);
% csvwrite('phillips_15_k.dat', o_phillips_15_k);
% csvwrite('phillips_17_k.dat', o_phillips_17_k);
% csvwrite('phillips_20_k.dat', o_phillips_20_k);

k = 0:0.001:0.25;
phillips_12_k_0_025 = Phillips1D(k, [12.5 0], 1, 0);
o_phillips_12_k_0_025 = [k', phillips_12_k_0_025'];
csvwrite('phillips_12_k_0_025.dat', o_phillips_12_k_0_025);

