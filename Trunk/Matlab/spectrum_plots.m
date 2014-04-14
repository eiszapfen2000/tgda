%1d spectra
% omega = [0:0.005:pi/2];
% 
% pm_10 = PiersonMoskovitz1D(omega, 10.0);
% pm_12 = PiersonMoskovitz1D(omega, 12.5);
% pm_15 = PiersonMoskovitz1D(omega, 15.0);
% pm_17 = PiersonMoskovitz1D(omega, 17.5);
% pm_20 = PiersonMoskovitz1D(omega, 20.0);
% 
% j_10_100km = JONSWAP1D(omega, 10.0, 100000);
% j_10_200km = JONSWAP1D(omega, 10.0, 200000);
% j_10_300km = JONSWAP1D(omega, 10.0, 300000);
% j_10_400km = JONSWAP1D(omega, 10.0, 400000);
% j_10_500km = JONSWAP1D(omega, 10.0, 500000);
% j_10_1000km = JONSWAP1D(omega, 10.0, 1000000);
% 
% j_15_100km = JONSWAP1D(omega, 15.0, 100000);
% j_15_200km = JONSWAP1D(omega, 15.0, 200000);
% j_15_300km = JONSWAP1D(omega, 15.0, 300000);
% j_15_400km = JONSWAP1D(omega, 15.0, 400000);
% j_15_500km = JONSWAP1D(omega, 15.0, 500000);
% j_15_1000km = JONSWAP1D(omega, 15.0, 1000000);
% 
% j_20_100km = JONSWAP1D(omega, 20.0, 100000);
% j_20_200km = JONSWAP1D(omega, 20.0, 200000);
% j_20_300km = JONSWAP1D(omega, 20.0, 300000);
% j_20_400km = JONSWAP1D(omega, 20.0, 400000);
% j_20_500km = JONSWAP1D(omega, 20.0, 500000);
% j_20_1000km = JONSWAP1D(omega, 20.0, 1000000);
% 
% o_pm_10 = [omega', pm_10'];
% o_pm_12 = [omega', pm_12'];
% o_pm_15 = [omega', pm_15'];
% o_pm_17 = [omega', pm_17'];
% o_pm_20 = [omega', pm_20'];
% 
% o_j_10_100km = [omega', j_10_100km'];
% o_j_10_200km = [omega', j_10_200km'];
% o_j_10_300km = [omega', j_10_300km'];
% o_j_10_400km = [omega', j_10_400km'];
% o_j_10_500km = [omega', j_10_500km'];
% o_j_10_1000km = [omega', j_10_1000km'];
% 
% o_j_15_100km = [omega', j_15_100km'];
% o_j_15_200km = [omega', j_15_200km'];
% o_j_15_300km = [omega', j_15_300km'];
% o_j_15_400km = [omega', j_15_400km'];
% o_j_15_500km = [omega', j_15_500km'];
% o_j_15_1000km = [omega', j_15_1000km'];
% 
% o_j_20_100km = [omega', j_20_100km'];
% o_j_20_200km = [omega', j_20_200km'];
% o_j_20_300km = [omega', j_20_300km'];
% o_j_20_400km = [omega', j_20_400km'];
% o_j_20_500km = [omega', j_20_500km'];
% o_j_20_1000km = [omega', j_20_1000km'];
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

kp = [0.0:0.00025:0.15];
wp = [ 15 0 ];

phillips_energy_w_10 = Phillips1D(kp, [10 0], 1, 0);
phillips_energy_w_12 = Phillips1D(kp, [12.5 0], 1, 0);
phillips_energy_w_15 = Phillips1D(kp, [15 0], 1, 0);
phillips_energy_w_17 = Phillips1D(kp, [17.5 0], 1, 0);
phillips_energy_w_20 = Phillips1D(kp, [20 0], 1, 0);

o_phillips_10 = [kp', phillips_energy_w_10'];
o_phillips_12 = [kp', phillips_energy_w_12'];
o_phillips_15 = [kp', phillips_energy_w_15'];
o_phillips_17 = [kp', phillips_energy_w_17'];
o_phillips_20 = [kp', phillips_energy_w_20'];

csvwrite('phillips_10.dat', o_phillips_10);
csvwrite('phillips_12.dat', o_phillips_12);
csvwrite('phillips_15.dat', o_phillips_15);
csvwrite('phillips_17.dat', o_phillips_17);
csvwrite('phillips_20.dat', o_phillips_20);

% figure;
% hold on;
% plot(kp, phillips_energy_w_10);
% plot(kp, phillips_energy_w_12);
% plot(kp, phillips_energy_w_15);
% plot(kp, phillips_energy_w_17);
% plot(kp, phillips_energy_w_20);
% hold off;