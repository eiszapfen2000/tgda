% close all

g = 9.81;
omega = 0.0:0.005:2*pi;
k = (omega .* omega) ./ g;

j_pm_10 = PiersonMoskovitz1D(omega, 10.0, []);

% interesting at omega = [0, pi/2]
j_10_5km = JONSWAP1D(omega, 10.0, 5000, []);
j_10_10km = JONSWAP1D(omega, 10.0, 10000, []);
j_10_25km = JONSWAP1D(omega, 10.0, 25000, []);
j_10_50km = JONSWAP1D(omega, 10.0, 50000, []);
j_10_75km = JONSWAP1D(omega, 10.0, 75000, []);
j_10_100km = JONSWAP1D(omega, 10.0, 100000, []);
j_10_200km = JONSWAP1D(omega, 10.0, 200000, []);
j_10_300km = JONSWAP1D(omega, 10.0, 300000, []);
j_10_400km = JONSWAP1D(omega, 10.0, 400000, []);
j_10_500km = JONSWAP1D(omega, 10.0, 500000, []);
j_10_1000km = JONSWAP1D(omega, 10.0, 1000000, []);

j_15_50km = JONSWAP1D(omega, 15.0, 50000, []);
j_15_100km = JONSWAP1D(omega, 15.0, 100000, []);
j_15_200km = JONSWAP1D(omega, 15.0, 200000, []);
j_15_300km = JONSWAP1D(omega, 15.0, 300000, []);
j_15_400km = JONSWAP1D(omega, 15.0, 400000, []);
j_15_500km = JONSWAP1D(omega, 15.0, 500000, []);
j_15_1000km = JONSWAP1D(omega, 15.0, 1000000, []);

j_20_100km = JONSWAP1D(omega, 20.0, 100000, []);
j_20_200km = JONSWAP1D(omega, 20.0, 200000, []);
j_20_300km = JONSWAP1D(omega, 20.0, 300000, []);
j_20_400km = JONSWAP1D(omega, 20.0, 400000, []);
j_20_500km = JONSWAP1D(omega, 20.0, 500000, []);
j_20_1000km = JONSWAP1D(omega, 20.0, 1000000, []);

j_wp_25_wc_4 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 4));
j_wp_25_wc_3 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 3));
j_wp_25_wc_2 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 2));
j_wp_25_wc_1 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 1));
j_wp_25_wc_083 = JONSWAP1D(omega, [], [], struct('wp', 2.5, 'wc', 0.83));

% interesting at omega = [0.6, 1.8]
j_15_50km_alpha_13 = JONSWAP1D(omega, 15.0, 50000, struct('alphaScale', 1.3));
j_15_50km_omegap_12 = JONSWAP1D(omega, 15.0, 50000, struct('wpScale', 1.2));
j_15_50km_sigma_003 = JONSWAP1D(omega, 15.0, 50000, struct('sigma', 0.03));
j_15_50km_gamma_1 = JONSWAP1D(omega, 15.0, 50000, struct('gamma_r', 1));

j_10_5km_k = JONSWAP1Dk(k, 10.0, 5000);
j_10_10km_k = JONSWAP1Dk(k, 10.0, 10000);
j_10_25km_k = JONSWAP1Dk(k, 10.0, 25000);
j_10_50km_k = JONSWAP1Dk(k, 10.0, 50000);
j_10_75km_k = JONSWAP1Dk(k, 10.0, 75000);
j_10_100km_k = JONSWAP1Dk(k, 10.0, 100000);
j_10_200km_k = JONSWAP1Dk(k, 10.0, 200000);
j_10_300km_k = JONSWAP1Dk(k, 10.0, 300000);
j_10_400km_k = JONSWAP1Dk(k, 10.0, 400000);
j_10_500km_k = JONSWAP1Dk(k, 10.0, 500000);
j_10_1000km_k = JONSWAP1Dk(k, 10.0, 1000000);

j_12_200km_k = JONSWAP1Dk(k, 12.5, 200000);

j_15_100km_k = JONSWAP1Dk(k, 15.0, 100000);
j_15_200km_k = JONSWAP1Dk(k, 15.0, 200000);
j_15_300km_k = JONSWAP1Dk(k, 15.0, 300000);
j_15_400km_k = JONSWAP1Dk(k, 15.0, 400000);
j_15_500km_k = JONSWAP1Dk(k, 15.0, 500000);
j_15_1000km_k = JONSWAP1Dk(k, 15.0, 1000000);

j_20_100km_k = JONSWAP1Dk(k, 20.0, 100000);
j_20_200km_k = JONSWAP1Dk(k, 20.0, 200000);
j_20_300km_k = JONSWAP1Dk(k, 20.0, 300000);
j_20_400km_k = JONSWAP1Dk(k, 20.0, 400000);
j_20_500km_k = JONSWAP1Dk(k, 20.0, 500000);
j_20_1000km_k = JONSWAP1Dk(k, 20.0, 1000000);

write2dcsv(omega, j_10_5km);
write2dcsv(omega, j_10_10km);
write2dcsv(omega, j_10_25km);
write2dcsv(omega, j_10_50km);
write2dcsv(omega, j_10_75km);
write2dcsv(omega, j_10_100km);
write2dcsv(omega, j_10_200km);
write2dcsv(omega, j_10_300km);
write2dcsv(omega, j_10_400km);
write2dcsv(omega, j_10_500km);
write2dcsv(omega, j_10_1000km);

write2dcsv(omega, j_15_50km);
write2dcsv(omega, j_15_100km);
write2dcsv(omega, j_15_200km);
write2dcsv(omega, j_15_300km);
write2dcsv(omega, j_15_400km);
write2dcsv(omega, j_15_500km);
write2dcsv(omega, j_15_1000km);

write2dcsv(omega, j_20_100km);
write2dcsv(omega, j_20_200km);
write2dcsv(omega, j_20_300km);
write2dcsv(omega, j_20_400km);
write2dcsv(omega, j_20_500km);
write2dcsv(omega, j_20_1000km);

write2dcsv(omega, j_15_50km_alpha_13);
write2dcsv(omega, j_15_50km_omegap_12);
write2dcsv(omega, j_15_50km_sigma_003);
write2dcsv(omega, j_15_50km_gamma_1);

write2dcsv(omega, j_wp_25_wc_4);
write2dcsv(omega, j_wp_25_wc_3);
write2dcsv(omega, j_wp_25_wc_2);
write2dcsv(omega, j_wp_25_wc_1);
write2dcsv(omega, j_wp_25_wc_083);

write2dcsv(k, j_10_5km_k);
write2dcsv(k, j_10_10km_k);
write2dcsv(k, j_10_25km_k);
write2dcsv(k, j_10_50km_k);
write2dcsv(k, j_10_75km_k);
write2dcsv(k, j_10_100km_k);
write2dcsv(k, j_10_200km_k);
write2dcsv(k, j_10_300km_k);
write2dcsv(k, j_10_400km_k);
write2dcsv(k, j_10_500km_k);
write2dcsv(k, j_10_1000km_k);

write2dcsv(k, j_12_200km_k);

write2dcsv(k, j_15_100km_k);
write2dcsv(k, j_15_200km_k);
write2dcsv(k, j_15_300km_k);
write2dcsv(k, j_15_400km_k);
write2dcsv(k, j_15_500km_k);
write2dcsv(k, j_15_1000km_k);

write2dcsv(k, j_20_100km_k);
write2dcsv(k, j_20_200km_k);
write2dcsv(k, j_20_300km_k);
write2dcsv(k, j_20_400km_k);
write2dcsv(k, j_20_500km_k);
write2dcsv(k, j_20_1000km_k);
