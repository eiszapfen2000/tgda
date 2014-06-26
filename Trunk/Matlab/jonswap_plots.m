close all

g = 9.81;

% create standard spectra with ranges as below
% omega 0...pi/2
% k 0...0.25

omega = 0.0:0.005:pi/2;
k = (omega .* omega) ./ g;

j_10_100km = JONSWAP1D(omega, 10.0, 100000, []);
j_10_200km = JONSWAP1D(omega, 10.0, 200000, []);
j_10_300km = JONSWAP1D(omega, 10.0, 300000, []);
j_10_400km = JONSWAP1D(omega, 10.0, 400000, []);
j_10_500km = JONSWAP1D(omega, 10.0, 500000, []);
j_10_1000km = JONSWAP1D(omega, 10.0, 1000000, []);

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

j_10_100km_k = JONSWAP1Dk(k, 10.0, 100000);
j_10_200km_k = JONSWAP1Dk(k, 10.0, 200000);
j_10_300km_k = JONSWAP1Dk(k, 10.0, 300000);
j_10_400km_k = JONSWAP1Dk(k, 10.0, 400000);
j_10_500km_k = JONSWAP1Dk(k, 10.0, 500000);
j_10_1000km_k = JONSWAP1Dk(k, 10.0, 1000000);

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

o_j_10_100km = [omega', j_10_100km'];
o_j_10_200km = [omega', j_10_200km'];
o_j_10_300km = [omega', j_10_300km'];
o_j_10_400km = [omega', j_10_400km'];
o_j_10_500km = [omega', j_10_500km'];
o_j_10_1000km = [omega', j_10_1000km'];

o_j_15_100km = [omega', j_15_100km'];
o_j_15_200km = [omega', j_15_200km'];
o_j_15_300km = [omega', j_15_300km'];
o_j_15_400km = [omega', j_15_400km'];
o_j_15_500km = [omega', j_15_500km'];
o_j_15_1000km = [omega', j_15_1000km'];

o_j_20_100km = [omega', j_20_100km'];
o_j_20_200km = [omega', j_20_200km'];
o_j_20_300km = [omega', j_20_300km'];
o_j_20_400km = [omega', j_20_400km'];
o_j_20_500km = [omega', j_20_500km'];
o_j_20_1000km = [omega', j_20_1000km'];

k_j_10_100km = [k', j_10_100km_k'];
k_j_10_200km = [k', j_10_200km_k'];
k_j_10_300km = [k', j_10_300km_k'];
k_j_10_400km = [k', j_10_400km_k'];
k_j_10_500km = [k', j_10_500km_k'];
k_j_10_1000km = [k', j_10_1000km_k'];

k_j_15_100km = [k', j_15_100km_k'];
k_j_15_200km = [k', j_15_200km_k'];
k_j_15_300km = [k', j_15_300km_k'];
k_j_15_400km = [k', j_15_400km_k'];
k_j_15_500km = [k', j_15_500km_k'];
k_j_15_1000km = [k', j_15_1000km_k'];

k_j_20_100km = [k', j_20_100km_k'];
k_j_20_200km = [k', j_20_200km_k'];
k_j_20_300km = [k', j_20_300km_k'];
k_j_20_400km = [k', j_20_400km_k'];
k_j_20_500km = [k', j_20_500km_k'];
k_j_20_1000km = [k', j_20_1000km_k'];

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

% now to the special versions of spectra
% 
% fiddle with constants and parameters
% restrict omega range
% omega = 0.6:0.005:1.8;
% 
% j_15_50km = JONSWAP1D(omega, 15.0, 50000, []);
% j_15_50km_alpha_13 = JONSWAP1D(omega, 15.0, 50000, struct('alphaScale', 1.3));
% j_15_50km_omegap_12 = JONSWAP1D(omega, 15.0, 50000, struct('wpScale', 1.2));
% j_15_50km_sigma_003 = JONSWAP1D(omega, 15.0, 50000, struct('sigma', 0.03));
% j_15_50km_gamma_1 = JONSWAP1D(omega, 15.0, 50000, struct('gamma_r', 1));
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