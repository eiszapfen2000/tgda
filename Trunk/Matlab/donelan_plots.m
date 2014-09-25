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
d_10_5km_k = Donelan19851Dk(k, 10.0, 5000, []);
d_10_10km_k = Donelan19851Dk(k, 10.0, 10000, []);
d_10_25km_k = Donelan19851Dk(k, 10.0, 25000, []);
d_10_50km_k = Donelan19851Dk(k, 10.0, 50000, []);
d_10_100km_k = Donelan19851Dk(k, 10.0, 100000, []);
d_10_250km_k = Donelan19851Dk(k, 10.0, 250000, []);
d_10_500km_k = Donelan19851Dk(k, 10.0, 500000, []);
d_10_600km_k = Donelan19851Dk(k, 10.0, 600000, []);

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

