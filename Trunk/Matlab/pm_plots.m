close all

g = 9.81;

%1d spectra
omega = [0:0.005:pi/2];
k = (omega .* omega) ./ g;

pm_10 = PiersonMoskovitz1D(omega, 10.0, 1, 1);
pm_12 = PiersonMoskovitz1D(omega, 12.5, 1, 1);
pm_15 = PiersonMoskovitz1D(omega, 15.0, 1, 1);
pm_17 = PiersonMoskovitz1D(omega, 17.5, 1, 1);
pm_20 = PiersonMoskovitz1D(omega, 20.0, 1, 1);

pm_15_alpha_07 = PiersonMoskovitz1D(omega, 15.0, 0.7, 1);
pm_15_alpha_08 = PiersonMoskovitz1D(omega, 15.0, 0.8, 1);
pm_15_alpha_09 = PiersonMoskovitz1D(omega, 15.0, 0.9, 1);
pm_15_alpha_11 = PiersonMoskovitz1D(omega, 15.0, 1.1, 1);
pm_15_alpha_12 = PiersonMoskovitz1D(omega, 15.0, 1.2, 1);
pm_15_alpha_13 = PiersonMoskovitz1D(omega, 15.0, 1.3, 1);
pm_15_omegap_08 = PiersonMoskovitz1D(omega, 15.0, 1, 0.8);
pm_15_omegap_09 = PiersonMoskovitz1D(omega, 15.0, 1, 0.9);
pm_15_omegap_11 = PiersonMoskovitz1D(omega, 15.0, 1, 1.1);
pm_15_omegap_12 = PiersonMoskovitz1D(omega, 15.0, 1, 1.2);
pm_15_omegap_13 = PiersonMoskovitz1D(omega, 15.0, 1, 1.3);

pm_10_k = PiersonMoskovitz1Dk(k, 10.0);
pm_12_k = PiersonMoskovitz1Dk(k, 12.5);
pm_15_k = PiersonMoskovitz1Dk(k, 15.0);
pm_17_k = PiersonMoskovitz1Dk(k, 17.5);
pm_20_k = PiersonMoskovitz1Dk(k, 20.0);

% figure;
% hold on;
% plot(omega, pm_15);
% plot(omega, pm_15_alpha_07);
% plot(omega, pm_15_alpha_13);
% plot(omega, pm_15_omegap_09);
% plot(omega, pm_15_omegap_13);
% % plot(omega, pm_12);
% % plot(omega, pm_15);
% % plot(omega, pm_17);
% % plot(omega, pm_20);
% hold off;

o_pm_10 = [omega', pm_10'];
o_pm_12 = [omega', pm_12'];
o_pm_15 = [omega', pm_15'];
o_pm_17 = [omega', pm_17'];
o_pm_20 = [omega', pm_20'];

o_pm_15_alpha_07 = [omega', pm_15_alpha_07'];
o_pm_15_alpha_08 = [omega', pm_15_alpha_08'];
o_pm_15_alpha_09 = [omega', pm_15_alpha_09'];
o_pm_15_alpha_11 = [omega', pm_15_alpha_11'];
o_pm_15_alpha_12 = [omega', pm_15_alpha_12'];
o_pm_15_alpha_13 = [omega', pm_15_alpha_13'];

o_pm_15_omegap_08 = [omega', pm_15_omegap_08'];
o_pm_15_omegap_09 = [omega', pm_15_omegap_09'];
o_pm_15_omegap_11 = [omega', pm_15_omegap_11'];
o_pm_15_omegap_12 = [omega', pm_15_omegap_12'];
o_pm_15_omegap_13 = [omega', pm_15_omegap_13'];

k_pm_10 = [k', pm_10_k'];
k_pm_12 = [k', pm_12_k'];
k_pm_15 = [k', pm_15_k'];
k_pm_17 = [k', pm_17_k'];
k_pm_20 = [k', pm_20_k'];

% csvwrite('pm_10.dat', o_pm_10);
% csvwrite('pm_12.dat', o_pm_12);
% csvwrite('pm_15.dat', o_pm_15);
% csvwrite('pm_17.dat', o_pm_17);
% csvwrite('pm_20.dat', o_pm_20);

% csvwrite('pm_15_alpha_07.dat', o_pm_15_alpha_07);
% csvwrite('pm_15_alpha_08.dat', o_pm_15_alpha_08);
% csvwrite('pm_15_alpha_09.dat', o_pm_15_alpha_09);
% csvwrite('pm_15_alpha_11.dat', o_pm_15_alpha_11);
% csvwrite('pm_15_alpha_12.dat', o_pm_15_alpha_12);
% csvwrite('pm_15_alpha_13.dat', o_pm_15_alpha_13);

% csvwrite('pm_15_omegap_08.dat', o_pm_15_omegap_08);
% csvwrite('pm_15_omegap_09.dat', o_pm_15_omegap_09);
% csvwrite('pm_15_omegap_11.dat', o_pm_15_omegap_11);
% csvwrite('pm_15_omegap_12.dat', o_pm_15_omegap_12);
% csvwrite('pm_15_omegap_13.dat', o_pm_15_omegap_13);

% csvwrite('pm_10_k.dat', k_pm_10);
% csvwrite('pm_12_k.dat', k_pm_12);
% csvwrite('pm_15_k.dat', k_pm_15);
% csvwrite('pm_17_k.dat', k_pm_17);
% csvwrite('pm_20_k.dat', k_pm_20);
