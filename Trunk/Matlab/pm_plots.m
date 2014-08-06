close all

g = 9.81;

%1d spectra
omega = 0:0.005:2*pi;
k = (omega .* omega) ./ g;

pm_10 = PiersonMoskovitz1D(omega, 10.0, []);
pm_12 = PiersonMoskovitz1D(omega, 12.5, []);
pm_15 = PiersonMoskovitz1D(omega, 15.0, []);
pm_17 = PiersonMoskovitz1D(omega, 17.5, []);
pm_20 = PiersonMoskovitz1D(omega, 20.0, []);

pm_15_alpha_07 = PiersonMoskovitz1D(omega, 15.0, struct('alphaScale', 0.7));
pm_15_alpha_08 = PiersonMoskovitz1D(omega, 15.0, struct('alphaScale', 0.8));
pm_15_alpha_09 = PiersonMoskovitz1D(omega, 15.0, struct('alphaScale', 0.9));
pm_15_alpha_11 = PiersonMoskovitz1D(omega, 15.0, struct('alphaScale', 1.1));
pm_15_alpha_12 = PiersonMoskovitz1D(omega, 15.0, struct('alphaScale', 1.2));
pm_15_alpha_13 = PiersonMoskovitz1D(omega, 15.0, struct('alphaScale', 1.3));
pm_15_omegap_08 = PiersonMoskovitz1D(omega, 15.0, struct('wpScale', 0.8));
pm_15_omegap_09 = PiersonMoskovitz1D(omega, 15.0, struct('wpScale', 0.9));
pm_15_omegap_11 = PiersonMoskovitz1D(omega, 15.0, struct('wpScale', 1.1));
pm_15_omegap_12 = PiersonMoskovitz1D(omega, 15.0, struct('wpScale', 1.2));
pm_15_omegap_13 = PiersonMoskovitz1D(omega, 15.0, struct('wpScale', 1.3));

pm_10_k = PiersonMoskovitz1Dk(k, 10.0);
pm_12_k = PiersonMoskovitz1Dk(k, 12.5);
pm_15_k = PiersonMoskovitz1Dk(k, 15.0);
pm_17_k = PiersonMoskovitz1Dk(k, 17.5);
pm_20_k = PiersonMoskovitz1Dk(k, 20.0);

write2dcsv(omega, pm_10);
write2dcsv(omega, pm_12);
write2dcsv(omega, pm_15);
write2dcsv(omega, pm_17);
write2dcsv(omega, pm_20);

write2dcsv(omega, pm_15_alpha_07);
write2dcsv(omega, pm_15_alpha_08);
write2dcsv(omega, pm_15_alpha_09);
write2dcsv(omega, pm_15_alpha_11);
write2dcsv(omega, pm_15_alpha_12);
write2dcsv(omega, pm_15_alpha_13);

write2dcsv(omega, pm_15_omegap_08);
write2dcsv(omega, pm_15_omegap_09);
write2dcsv(omega, pm_15_omegap_11);
write2dcsv(omega, pm_15_omegap_12);
write2dcsv(omega, pm_15_omegap_13);

write2dcsv(omega, pm_10_k);
write2dcsv(omega, pm_12_k);
write2dcsv(omega, pm_15_k);
write2dcsv(omega, pm_17_k);
write2dcsv(omega, pm_20_k);

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
