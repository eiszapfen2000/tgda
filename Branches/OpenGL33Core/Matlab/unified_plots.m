close all

g = 9.81;

omega = 0:0.005:0.5*pi;
k = (omega .* omega) ./ g;

pm_10_k = PiersonMoskovitz1Dk(k, 10.0, []);

u_10_5km_k = UnifiedSpectrum1Dk(k, 10.0, 5000, []);
u_10_10km_k = UnifiedSpectrum1Dk(k, 10.0, 10000, []);
u_10_25km_k = UnifiedSpectrum1Dk(k, 10.0, 25000, []);
u_10_50km_k = UnifiedSpectrum1Dk(k, 10.0, 50000, []);
u_10_75km_k = UnifiedSpectrum1Dk(k, 10.0, 75000, []);
u_10_100km_k = UnifiedSpectrum1Dk(k, 10.0, 100000, []);
u_10_200km_k = UnifiedSpectrum1Dk(k, 10.0, 200000, []);
u_10_250km_k = UnifiedSpectrum1Dk(k, 10.0, 250000, []);
u_10_300km_k = UnifiedSpectrum1Dk(k, 10.0, 300000, []);
u_10_400km_k = UnifiedSpectrum1Dk(k, 10.0, 400000, []);
u_10_500km_k = UnifiedSpectrum1Dk(k, 10.0, 500000, []);
u_10_750km_k = UnifiedSpectrum1Dk(k, 10.0, 750000, []);
u_10_1000km_k = UnifiedSpectrum1Dk(k, 10.0, 1000000, []);
u_10_1500km_k = UnifiedSpectrum1Dk(k, 10.0, 1500000, []);
u_10_2000km_k = UnifiedSpectrum1Dk(k, 10.0, 2000000, []);

write2dcsv(k, u_10_5km_k);
write2dcsv(k, u_10_10km_k);
write2dcsv(k, u_10_25km_k);
write2dcsv(k, u_10_50km_k);
write2dcsv(k, u_10_75km_k);
write2dcsv(k, u_10_100km_k);
write2dcsv(k, u_10_200km_k);
write2dcsv(k, u_10_250km_k);
write2dcsv(k, u_10_300km_k);
write2dcsv(k, u_10_400km_k);
write2dcsv(k, u_10_500km_k);
write2dcsv(k, u_10_750km_k);
write2dcsv(k, u_10_1000km_k);
write2dcsv(k, u_10_1500km_k);
write2dcsv(k, u_10_2000km_k);

u_d_10_100km_k = Donelan19851Dk(k, 10.0, 100000, []);
u_d_10_500km_k = Donelan19851Dk(k, 10.0, 500000, []);
u_d_10_1000km_k = Donelan19851Dk(k, 10.0, 1000000, []);
u_d_10_1500km_k = Donelan19851Dk(k, 10.0, 1500000, []);
u_d_10_2000km_k = Donelan19851Dk(k, 10.0, 2000000, []);

write2dcsv(k, u_d_10_500km_k);
write2dcsv(k, u_d_10_1000km_k);
write2dcsv(k, u_d_10_1500km_k);
write2dcsv(k, u_d_10_2000km_k);

u_j_10_100km_k = JONSWAP1Dk(k, 10.0, 100000, []);
u_j_10_500km_k = JONSWAP1Dk(k, 10.0, 500000, []);
u_j_10_1000km_k = JONSWAP1Dk(k, 10.0, 1000000, []);
u_j_10_1500km_k = JONSWAP1Dk(k, 10.0, 1500000, []);
u_j_10_2000km_k = JONSWAP1Dk(k, 10.0, 2000000, []);

figure
hold on
plot(k, pm_10_k, 'xb');
plot(k, u_10_100km_k, 'r');
plot(k, u_d_10_100km_k, 'g');
plot(k, u_j_10_100km_k, 'black');
hold off

u_pm_kp_1 = PiersonMoskovitz1Dk(k, [], struct('kp', 1));
u_d_kp_1_wc_4 = Donelan19851Dk(k, [], [], struct('kp', 1, 'wc', 4));
u_d_kp_1_wc_083 = Donelan19851Dk(k, [], [], struct('kp', 1, 'wc', 0.83));
u_kp_1_wc_4 = UnifiedSpectrum1Dk(k, [], [], struct('kp', 1, 'wc', 4));
u_kp_1_wc_083 = UnifiedSpectrum1Dk(k, [], [], struct('kp', 1, 'wc', 0.83));

write2dcsv(k, u_pm_kp_1);
write2dcsv(k, u_d_kp_1_wc_4);
write2dcsv(k, u_d_kp_1_wc_083);
write2dcsv(k, u_kp_1_wc_4);
write2dcsv(k, u_kp_1_wc_083);


% figure
% hold on
% plot(k, u_pm_kp_1);
% plot(k, u_d_kp_1_wc_4);
% plot(k, u_d_kp_1_wc_083);
% plot(k, u_kp_1_wc_4);
% plot(k, u_kp_1_wc_083);
% hold off

d_10_5km_k = Donelan19851Dk(k, 10.0, 5000, []);
d_10_10km_k = Donelan19851Dk(k, 10.0, 10000, []);
d_10_25km_k = Donelan19851Dk(k, 10.0, 25000, []);
d_10_50km_k = Donelan19851Dk(k, 10.0, 50000, []);
d_10_75km_k = Donelan19851Dk(k, 10.0, 75000, []);
d_10_100km_k = Donelan19851Dk(k, 10.0, 100000, []);
d_10_200km_k = Donelan19851Dk(k, 10.0, 200000, []);
d_10_300km_k = Donelan19851Dk(k, 10.0, 300000, []);
d_10_400km_k = Donelan19851Dk(k, 10.0, 400000, []);
d_10_500km_k = Donelan19851Dk(k, 10.0, 500000, []);
d_10_1000km_k = Donelan19851Dk(k, 10.0, 1000000, []);

% k = 0:0.5:10^3;
%k = 0:0.001:1;
%k = [k, 1.5:0.5:10^3];
k = logspace(-3, 4, 1000);
b = k .^ 3;

u_3_500km_k = UnifiedSpectrum1Dk(k, 3.0, 500000, []);
u_5_500km_k= UnifiedSpectrum1Dk(k, 5.0, 500000, []);
u_7_500km_k = UnifiedSpectrum1Dk(k, 7.0, 500000, []);
u_9_500km_k = UnifiedSpectrum1Dk(k, 9.0, 500000, []);
u_11_500km_k = UnifiedSpectrum1Dk(k, 11.0, 500000, []);
u_13_500km_k = UnifiedSpectrum1Dk(k, 13.0, 500000, []);
u_15_500km_k = UnifiedSpectrum1Dk(k, 15.0, 500000, []);
u_17_500km_k = UnifiedSpectrum1Dk(k, 17.0, 500000, []);
u_19_500km_k = UnifiedSpectrum1Dk(k, 19.0, 500000, []);
u_21_500km_k = UnifiedSpectrum1Dk(k, 21.0, 500000, []);

write2dcsv(k, u_3_500km_k);
write2dcsv(k, u_5_500km_k);
write2dcsv(k, u_7_500km_k);
write2dcsv(k, u_9_500km_k);
write2dcsv(k, u_11_500km_k);
write2dcsv(k, u_13_500km_k);
write2dcsv(k, u_15_500km_k);
write2dcsv(k, u_17_500km_k);
write2dcsv(k, u_19_500km_k);
write2dcsv(k, u_21_500km_k);

u_d_3_500km_k = Donelan19851Dk(k, 3.0, 500000, []);
u_d_5_500km_k= Donelan19851Dk(k, 5.0, 500000, []);
u_d_7_500km_k = Donelan19851Dk(k, 7.0, 500000, []);
u_d_9_500km_k = Donelan19851Dk(k, 9.0, 500000, []);
u_d_11_500km_k = Donelan19851Dk(k, 11.0, 500000, []);
u_d_13_500km_k = Donelan19851Dk(k, 13.0, 500000, []);
u_d_15_500km_k = Donelan19851Dk(k, 15.0, 500000, []);
u_d_17_500km_k = Donelan19851Dk(k, 17.0, 500000, []);
u_d_19_500km_k = Donelan19851Dk(k, 19.0, 500000, []);
u_d_21_500km_k = Donelan19851Dk(k, 21.0, 500000, []);

write2dcsv(k, u_d_3_500km_k);
write2dcsv(k, u_d_5_500km_k);
write2dcsv(k, u_d_7_500km_k);
write2dcsv(k, u_d_9_500km_k);
write2dcsv(k, u_d_11_500km_k);
write2dcsv(k, u_d_13_500km_k);
write2dcsv(k, u_d_15_500km_k);
write2dcsv(k, u_d_17_500km_k);
write2dcsv(k, u_d_19_500km_k);
write2dcsv(k, u_d_21_500km_k);

figure
hold on
plot(log10(k), log10(u_3_500km_k), 'r');
plot(log10(k), log10(u_5_500km_k), 'r');
plot(log10(k), log10(u_7_500km_k), 'r');
plot(log10(k), log10(u_9_500km_k), 'r');
plot(log10(k), log10(u_11_500km_k), 'r');
plot(log10(k), log10(u_13_500km_k), 'r');
plot(log10(k), log10(u_15_500km_k), 'r');
plot(log10(k), log10(u_17_500km_k), 'r');
plot(log10(k), log10(u_19_500km_k), 'r');
plot(log10(k), log10(u_21_500km_k), 'r');

plot(log10(k), log10(u_d_3_500km_k), 'b');
plot(log10(k), log10(u_d_5_500km_k), 'b');
plot(log10(k), log10(u_d_7_500km_k), 'b');
plot(log10(k), log10(u_d_9_500km_k), 'b');
plot(log10(k), log10(u_d_11_500km_k), 'b');
plot(log10(k), log10(u_d_13_500km_k), 'b');
plot(log10(k), log10(u_d_15_500km_k), 'b');
plot(log10(k), log10(u_d_17_500km_k), 'b');
plot(log10(k), log10(u_d_19_500km_k), 'b');
plot(log10(k), log10(u_d_21_500km_k), 'b');

axis([-3, 5, -16, 5]);
hold off

figure
hold on
plot(log10(k), log10(u_3_500km_k .* b), 'r');
plot(log10(k), log10(u_5_500km_k .* b), 'r');
plot(log10(k), log10(u_7_500km_k .* b), 'r');
plot(log10(k), log10(u_9_500km_k .* b), 'r');
plot(log10(k), log10(u_11_500km_k .* b), 'r');
plot(log10(k), log10(u_13_500km_k .* b), 'r');
plot(log10(k), log10(u_15_500km_k .* b), 'r');
plot(log10(k), log10(u_17_500km_k .* b), 'r');
plot(log10(k), log10(u_19_500km_k .* b), 'r');
plot(log10(k), log10(u_21_500km_k .* b), 'r');

plot(log10(k), log10(u_d_3_500km_k .* b), 'b');
plot(log10(k), log10(u_d_5_500km_k .* b), 'b');
plot(log10(k), log10(u_d_7_500km_k .* b), 'b');
plot(log10(k), log10(u_d_9_500km_k .* b), 'b');
plot(log10(k), log10(u_d_11_500km_k .* b), 'b');
plot(log10(k), log10(u_d_13_500km_k .* b), 'b');
plot(log10(k), log10(u_d_15_500km_k .* b), 'b');
plot(log10(k), log10(u_d_17_500km_k .* b), 'b');
plot(log10(k), log10(u_d_19_500km_k .* b), 'b');
plot(log10(k), log10(u_d_21_500km_k .* b), 'b');

axis([-3, 4, -4, 0]);
hold off



% figure
% hold on
% plot(log10(k), log10(u_3_500km_k .* ik), 'r');
% plot(log10(k), log10(u_5_500km_k .* ik), 'r');
% plot(log10(k), log10(u_7_500km_k .* ik), 'r');
% plot(log10(k), log10(u_9_500km_k .* ik), 'r');
% plot(log10(k), log10(u_11_500km_k .* ik), 'r');
% plot(log10(k), log10(u_13_500km_k .* ik), 'r');
% plot(log10(k), log10(u_15_500km_k .* ik), 'r');
% plot(log10(k), log10(u_17_500km_k .* ik), 'r');
% plot(log10(k), log10(u_19_500km_k .* ik), 'r');
% plot(log10(k), log10(u_21_500km_k .* ik), 'r');
% axis([-3, 4, -4, 0]);
% hold off

% figure
% hold on
% plot(k, pm_10_k, 'g');
% plot(k, u_10_5km_k);
% plot(k, u_10_10km_k);
% plot(k, u_10_25km_k);
% plot(k, u_10_50km_k);
% plot(k, u_10_75km_k);
% plot(k, u_10_100km_k);
% plot(k, u_10_200km_k);
% plot(k, u_10_300km_k);
% plot(k, u_10_400km_k);
% plot(k, u_10_500km_k);
% plot(k, u_10_1000km_k);
% plot(k, d_10_5km_k, 'r');
% plot(k, d_10_10km_k, 'r');
% plot(k, d_10_25km_k, 'r');
% plot(k, d_10_50km_k, 'r');
% plot(k, d_10_75km_k, 'r');
% plot(k, d_10_100km_k, 'r');
% plot(k, d_10_200km_k, 'r');
% plot(k, d_10_300km_k, 'r');
% plot(k, d_10_400km_k, 'r');
% plot(k, d_10_500km_k, 'r');
% plot(k, d_10_1000km_k, 'r');
% hold off

