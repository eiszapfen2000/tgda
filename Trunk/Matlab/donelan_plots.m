close all

g = 9.81;

% create standard spectra with ranges as below
% omega 0...pi/2
% k 0...0.25

omega = 0.0:0.005:2*pi;
k = (omega .* omega) ./ g;

d_pm_10 = PiersonMoskovitz1D(omega, 10.0, []);
d_10_5km = Donelan19851D(omega, 10.0, 5000, []);
d_10_10km = Donelan19851D(omega, 10.0, 10000, []);
d_10_25km = Donelan19851D(omega, 10.0, 25000, []);
d_10_50km = Donelan19851D(omega, 10.0, 50000, []);
d_10_100km = Donelan19851D(omega, 10.0, 100000, []);
d_10_250km = Donelan19851D(omega, 10.0, 250000, []);
d_10_500km = Donelan19851D(omega, 10.0, 500000, []);
d_10_600km = Donelan19851D(omega, 10.0, 600000, []);

write2dcsv(omega, d_pm_10);
write2dcsv(omega, d_10_5km);
write2dcsv(omega, d_10_10km);
write2dcsv(omega, d_10_25km);
write2dcsv(omega, d_10_50km);
write2dcsv(omega, d_10_100km);
write2dcsv(omega, d_10_250km);
write2dcsv(omega, d_10_500km);
write2dcsv(omega, d_10_600km);

pm_k = PiersonMoskovitz1Dk(k, 10.0, []);
d_10_5km_k = Donelan19851Dk(k, 10.0, 5000);
d_10_10km_k = Donelan19851Dk(k, 10.0, 10000);
d_10_25km_k = Donelan19851Dk(k, 10.0, 25000);
d_10_50km_k = Donelan19851Dk(k, 10.0, 50000);
d_10_100km_k = Donelan19851Dk(k, 10.0, 100000);
d_10_250km_k = Donelan19851Dk(k, 10.0, 250000);
d_10_500km_k = Donelan19851Dk(k, 10.0, 500000);
d_10_600km_k = Donelan19851Dk(k, 10.0, 600000);

% figure
% hold on
% plot(omega, d_pm_10);
% plot(omega, d_10_5km);
% plot(omega, d_10_10km);
% plot(omega, d_10_25km);
% plot(omega, d_10_50km);
% plot(omega, d_10_100km);
% plot(omega, d_10_250km);
% plot(omega, d_10_500km);
% hold off

% figure
% hold on
% plot(omega, d_pm_10);
% plot(omega, d_10_5km);
% plot(omega, d_10_10km);
% plot(omega, d_10_25km);
% plot(omega, d_10_50km);
% plot(omega, d_10_100km);
% plot(omega, d_10_250km);
% plot(omega, d_10_500km);
% hold off


omega = 0.0:0.005:5;
d_pm_wp_25 = PiersonMoskovitz1D(omega, [], struct('wp', 2.5));
d_j_wp_25_wc_4 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 4));
d_wp_25_wc_4 = Donelan19851D(omega, [], [], struct('wp', 2.5, 'wc', 4));
d_j_wp_25_wc_083 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 0.83));
d_wp_25_wc_083 = Donelan19851D(omega, [], [], struct('wp', 2.5, 'wc', 0.83));
% d_156_25 = Donelan19851D(omega, 15.6, 2500, []);
% d_32_104 = Donelan19851D(omega, 3.2, 104000, []);

write2dcsv(omega, d_pm_wp_25);
write2dcsv(omega, d_j_wp_25_wc_4);
write2dcsv(omega, d_wp_25_wc_4);
write2dcsv(omega, d_j_wp_25_wc_083);
write2dcsv(omega, d_wp_25_wc_083);

% figure
% hold on
% plot(omega, pm_10_wp_25);
% plot(omega, j_wp_25_wc_4);
% plot(omega, j_wp_25_wc_083);
% plot(omega, d_wp_25_wc_4);
% plot(omega, d_wp_25_wc_083);
% plot(omega, d_156_25);
% plot(omega, d_32_104);
% hold off


% now to the special versions of spectra

% fiddle with constants and parameters
% restrict omega range
% omega = 0.6:0.005:1.8;
% 
% j_15_50km = JONSWAP1D(omega, 15.0, 50000, scale);
% 
% scale.alphaScale = 1.3;
% 
% j_15_50km_alpha_13 = JONSWAP1D(omega, 15.0, 50000, scale);
% 
% scale.alphaScale = 1;
% scale.wpScale = 1.2;
% 
% j_15_50km_omegap_12 = JONSWAP1D(omega, 15.0, 50000, scale);
% 
% scale.wpScale = 1;
% scale.sigma = 0.03;
% 
% j_15_50km_sigma_003 = JONSWAP1D(omega, 15.0, 50000, scale);
% 
% scale.sigma = 0;
% scale.gamma = 1;
% 
% j_15_50km_gamma_1 = JONSWAP1D(omega, 15.0, 50000, scale);
% 
% o_j_15_50km = [omega', j_15_50km'];
% o_j_15_50km_alpha_13 = [omega', j_15_50km_alpha_13'];
% o_j_15_50km_omegap_12 = [omega', j_15_50km_omegap_12'];
% o_j_15_50km_sigma_003 = [omega', j_15_50km_sigma_003'];
% o_j_15_50km_gamma_1 = [omega', j_15_50km_gamma_1'];
% 
% csvwrite('j_15_50km.dat', o_j_15_50km);
% csvwrite('j_15_50km_alpha_13.dat', o_j_15_50km_alpha_13);
% csvwrite('j_15_50km_omegap_12.dat', o_j_15_50km_omegap_12);
% csvwrite('j_15_50km_sigma_003.dat', o_j_15_50km_sigma_003);
% csvwrite('j_15_50km_gamma_1.dat', o_j_15_50km_gamma_1);

% These are for comparsion with the Phillips spectrum
% k = 0.0:0.001:0.2;
% j_10_200km_k_0_02 = JONSWAP1Dk(k, 10.0, 200000);
% j_12_200km_k_0_02 = JONSWAP1Dk(k, 12.5, 200000);
% j_15_200km_k_0_02 = JONSWAP1Dk(k, 15.0, 200000);
% o_j_10_200km_k_0_02 = [k', j_10_200km_k_0_02'];
% o_j_12_200km_k_0_02 = [k', j_12_200km_k_0_02'];
% o_j_15_200km_k_0_02 = [k', j_15_200km_k_0_02'];
% csvwrite('j_10_200km_k_0_02.dat', o_j_10_200km_k_0_02);
% csvwrite('j_12_200km_k_0_02.dat', o_j_12_200km_k_0_02);
% csvwrite('j_15_200km_k_0_02.dat', o_j_15_200km_k_0_02);