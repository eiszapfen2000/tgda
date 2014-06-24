close all

g = 9.81;

%1d spectra
omega = [0:0.005:pi/2];
k = (omega .* omega) ./ g;

pm_10 = PiersonMoskovitz1D(omega, 10.0);
pm_12 = PiersonMoskovitz1D(omega, 12.5);
pm_15 = PiersonMoskovitz1D(omega, 15.0);
pm_17 = PiersonMoskovitz1D(omega, 17.5);
pm_20 = PiersonMoskovitz1D(omega, 20.0);

pm_10_k = PiersonMoskovitz1Dk(k, 10.0);
pm_12_k = PiersonMoskovitz1Dk(k, 12.5);
pm_15_k = PiersonMoskovitz1Dk(k, 15.0);
pm_17_k = PiersonMoskovitz1Dk(k, 17.5);
pm_20_k = PiersonMoskovitz1Dk(k, 20.0);

j_10_100km = JONSWAP1D(omega, 10.0, 100000);
j_10_200km = JONSWAP1D(omega, 10.0, 200000);
j_10_300km = JONSWAP1D(omega, 10.0, 300000);
j_10_400km = JONSWAP1D(omega, 10.0, 400000);
j_10_500km = JONSWAP1D(omega, 10.0, 500000);
j_10_1000km = JONSWAP1D(omega, 10.0, 1000000);

j_10_100km_k = JONSWAP1Dk(k, 10.0, 100000);
j_10_200km_k = JONSWAP1Dk(k, 10.0, 200000);
j_10_300km_k = JONSWAP1Dk(k, 10.0, 300000);
j_10_400km_k = JONSWAP1Dk(k, 10.0, 400000);
j_10_500km_k = JONSWAP1Dk(k, 10.0, 500000);
j_10_1000km_k = JONSWAP1Dk(k, 10.0, 1000000);

j_15_100km = JONSWAP1D(omega, 15.0, 100000);
j_15_200km = JONSWAP1D(omega, 15.0, 200000);
j_15_300km = JONSWAP1D(omega, 15.0, 300000);
j_15_400km = JONSWAP1D(omega, 15.0, 400000);
j_15_500km = JONSWAP1D(omega, 15.0, 500000);
j_15_1000km = JONSWAP1D(omega, 15.0, 1000000);

j_15_100km_k = JONSWAP1Dk(k, 15.0, 100000);
j_15_200km_k = JONSWAP1Dk(k, 15.0, 200000);
j_15_300km_k = JONSWAP1Dk(k, 15.0, 300000);
j_15_400km_k = JONSWAP1Dk(k, 15.0, 400000);
j_15_500km_k = JONSWAP1Dk(k, 15.0, 500000);
j_15_1000km_k = JONSWAP1Dk(k, 15.0, 1000000);

j_20_100km = JONSWAP1D(omega, 20.0, 100000);
j_20_200km = JONSWAP1D(omega, 20.0, 200000);
j_20_300km = JONSWAP1D(omega, 20.0, 300000);
j_20_400km = JONSWAP1D(omega, 20.0, 400000);
j_20_500km = JONSWAP1D(omega, 20.0, 500000);
j_20_1000km = JONSWAP1D(omega, 20.0, 1000000);

j_20_100km_k = JONSWAP1Dk(k, 20.0, 100000);
j_20_200km_k = JONSWAP1Dk(k, 20.0, 200000);
j_20_300km_k = JONSWAP1Dk(k, 20.0, 300000);
j_20_400km_k = JONSWAP1Dk(k, 20.0, 400000);
j_20_500km_k = JONSWAP1Dk(k, 20.0, 500000);
j_20_1000km_k = JONSWAP1Dk(k, 20.0, 1000000);

o_pm_10 = [omega', pm_10'];
o_pm_12 = [omega', pm_12'];
o_pm_15 = [omega', pm_15'];
o_pm_17 = [omega', pm_17'];
o_pm_20 = [omega', pm_20'];

k_pm_10 = [k', pm_10_k'];
k_pm_12 = [k', pm_12_k'];
k_pm_15 = [k', pm_15_k'];
k_pm_17 = [k', pm_17_k'];
k_pm_20 = [k', pm_20_k'];

o_j_10_100km = [omega', j_10_100km'];
o_j_10_200km = [omega', j_10_200km'];
o_j_10_300km = [omega', j_10_300km'];
o_j_10_400km = [omega', j_10_400km'];
o_j_10_500km = [omega', j_10_500km'];
o_j_10_1000km = [omega', j_10_1000km'];

k_j_10_100km = [k', j_10_100km_k'];
k_j_10_200km = [k', j_10_200km_k'];
k_j_10_300km = [k', j_10_300km_k'];
k_j_10_400km = [k', j_10_400km_k'];
k_j_10_500km = [k', j_10_500km_k'];
k_j_10_1000km = [k', j_10_1000km_k'];

o_j_15_100km = [omega', j_15_100km'];
o_j_15_200km = [omega', j_15_200km'];
o_j_15_300km = [omega', j_15_300km'];
o_j_15_400km = [omega', j_15_400km'];
o_j_15_500km = [omega', j_15_500km'];
o_j_15_1000km = [omega', j_15_1000km'];

k_j_15_100km = [k', j_15_100km_k'];
k_j_15_200km = [k', j_15_200km_k'];
k_j_15_300km = [k', j_15_300km_k'];
k_j_15_400km = [k', j_15_400km_k'];
k_j_15_500km = [k', j_15_500km_k'];
k_j_15_1000km = [k', j_15_1000km_k'];

o_j_20_100km = [omega', j_20_100km'];
o_j_20_200km = [omega', j_20_200km'];
o_j_20_300km = [omega', j_20_300km'];
o_j_20_400km = [omega', j_20_400km'];
o_j_20_500km = [omega', j_20_500km'];
o_j_20_1000km = [omega', j_20_1000km'];

k_j_20_100km = [k', j_20_100km_k'];
k_j_20_200km = [k', j_20_200km_k'];
k_j_20_300km = [k', j_20_300km_k'];
k_j_20_400km = [k', j_20_400km_k'];
k_j_20_500km = [k', j_20_500km_k'];
k_j_20_1000km = [k', j_20_1000km_k'];
% 
% csvwrite('pm_10.dat', o_pm_10);
% csvwrite('pm_12.dat', o_pm_12);
% csvwrite('pm_15.dat', o_pm_15);
% csvwrite('pm_17.dat', o_pm_17);
% csvwrite('pm_20.dat', o_pm_20);
% 
% csvwrite('j_10_100km.dat', o_j_10_100km);
% csvwrite('j_10_200km.dat', o_j_10_200km);
% csvwrite('j_10_300km.dat', o_j_10_300km);
% csvwrite('j_10_400km.dat', o_j_10_400km);
% csvwrite('j_10_500km.dat', o_j_10_500km);
% csvwrite('j_10_1000km.dat', o_j_10_1000km);
% 
% csvwrite('j_15_100km.dat', o_j_15_100km);
% csvwrite('j_15_200km.dat', o_j_15_200km);
% csvwrite('j_15_300km.dat', o_j_15_300km);
% csvwrite('j_15_400km.dat', o_j_15_400km);
% csvwrite('j_15_500km.dat', o_j_15_500km);
% csvwrite('j_15_1000km.dat', o_j_15_1000km);
% 
% csvwrite('j_20_100km.dat', o_j_20_100km);
% csvwrite('j_20_200km.dat', o_j_20_200km);
% csvwrite('j_20_300km.dat', o_j_20_300km);
% csvwrite('j_20_400km.dat', o_j_20_400km);
% csvwrite('j_20_500km.dat', o_j_20_500km);
% csvwrite('j_20_1000km.dat', o_j_20_1000km);

% csvwrite('pm_10_k.dat', k_pm_10);
% csvwrite('pm_12_k.dat', k_pm_12);
% csvwrite('pm_15_k.dat', k_pm_15);
% csvwrite('pm_17_k.dat', k_pm_17);
% csvwrite('pm_20_k.dat', k_pm_20);
% 
% csvwrite('j_10_100km_k.dat', k_j_10_100km);
% csvwrite('j_10_200km_k.dat', k_j_10_200km);
% csvwrite('j_10_300km_k.dat', k_j_10_300km);
% csvwrite('j_10_400km_k.dat', k_j_10_400km);
% csvwrite('j_10_500km_k.dat', k_j_10_500km);
% csvwrite('j_10_1000km_k.dat', k_j_10_1000km);
% 
% csvwrite('j_15_100km_k.dat', k_j_15_100km);
% csvwrite('j_15_200km_k.dat', k_j_15_200km);
% csvwrite('j_15_300km_k.dat', k_j_15_300km);
% csvwrite('j_15_400km_k.dat', k_j_15_400km);
% csvwrite('j_15_500km_k.dat', k_j_15_500km);
% csvwrite('j_15_1000km_k.dat', k_j_15_1000km);
% 
% csvwrite('j_20_100km_k.dat', k_j_20_100km);
% csvwrite('j_20_200km_k.dat', k_j_20_200km);
% csvwrite('j_20_300km_k.dat', k_j_20_300km);
% csvwrite('j_20_400km_k.dat', k_j_20_400km);
% csvwrite('j_20_500km_k.dat', k_j_20_500km);
% csvwrite('j_20_1000km_k.dat', k_j_20_1000km);

% figure
% hold on
% plot(k, pm_10_k);
% plot(k, j_10_100km_k);
% plot(k, j_10_200km_k);
% plot(k, j_10_300km_k);
% plot(k, j_10_400km_k);
% plot(k, j_10_500km_k);
% plot(k, j_10_1000km_k);
% hold off

% kp = [0.0:0.00025:0.15];
% wp = [ 15 0 ];
% 
phillips_energy_w_10 = Phillips1D(k, [10 0], 1, 0);
phillips_energy_w_12 = Phillips1D(k, [12.5 0], 1, 0);
phillips_energy_w_15 = Phillips1D(k, [15 0], 1, 0);
phillips_energy_w_17 = Phillips1D(k, [17.5 0], 1, 0);
phillips_energy_w_20 = Phillips1D(k, [20 0], 1, 0);

l = 10^(-3);
phillips_energy_w_10_l = Phillips1D(k, [10 0], 1, l);
phillips_energy_w_12_l = Phillips1D(k, [12.5 0], 1, l);
phillips_energy_w_15_l = Phillips1D(k, [15 0], 1, l);
phillips_energy_w_17_l = Phillips1D(k, [17.5 0], 1, l);
phillips_energy_w_20_l = Phillips1D(k, [20 0], 1, l);

% 
phillips_energy_w_10_a = Phillips1D(k, [10 0], 0.000081, 0);
phillips_energy_w_12_a = Phillips1D(k, [12.5 0], 0.000081, 0);
phillips_energy_w_15_a = Phillips1D(k, [15 0], 0.000081, 0);
phillips_energy_w_17_a = Phillips1D(k, [17.5 0], 0.000081, 0);
phillips_energy_w_20_a = Phillips1D(k, [20 0], 0.000081, 0);

phillips_energy_w_10_a_l = Phillips1D(k, [10 0], 0.0081, l);
phillips_energy_w_12_a_l = Phillips1D(k, [12.5 0], 0.0081, l);
phillips_energy_w_15_a_l = Phillips1D(k, [15 0], 0.0081, l);
phillips_energy_w_17_a_l = Phillips1D(k, [17.5 0], 0.0081, l);
phillips_energy_w_20_a_l = Phillips1D(k, [20 0], 0.0081, l);


% o_phillips_10 = [kp', phillips_energy_w_10'];
% o_phillips_12 = [kp', phillips_energy_w_12'];
% o_phillips_15 = [kp', phillips_energy_w_15'];
% o_phillips_17 = [kp', phillips_energy_w_17'];
% o_phillips_20 = [kp', phillips_energy_w_20'];
% 
% csvwrite('phillips_10.dat', o_phillips_10);
% csvwrite('phillips_12.dat', o_phillips_12);
% csvwrite('phillips_15.dat', o_phillips_15);
% csvwrite('phillips_17.dat', o_phillips_17);
% csvwrite('phillips_20.dat', o_phillips_20);

figure
hold on
plot(k, phillips_energy_w_10_a);
plot(k, phillips_energy_w_12_a);
plot(k, phillips_energy_w_15_a);
plot(k, phillips_energy_w_17_a);
plot(k, phillips_energy_w_20_a);

plot(k, phillips_energy_w_10_a_l, 'Color', 'red');
plot(k, phillips_energy_w_12_a_l, 'Color', 'red');
plot(k, phillips_energy_w_15_a_l, 'Color', 'red');
plot(k, phillips_energy_w_17_a_l, 'Color', 'red');
plot(k, phillips_energy_w_20_a_l, 'Color', 'red');
hold off

% figure;
% hold on;
% plot(k, pm_10_k, 'Color', 'red');
% plot(k, pm_12_k, 'Color', 'red');
% plot(k, pm_15_k, 'Color', 'red');
% plot(k, pm_17_k, 'Color', 'red');
% plot(k, pm_20_k, 'Color', 'red');
% plot(k, phillips_energy_w_10_a);
% plot(k, phillips_energy_w_12_a);
% plot(k, phillips_energy_w_15_a);
% plot(k, phillips_energy_w_17_a);
% plot(k, phillips_energy_w_20_a);
% hold off;