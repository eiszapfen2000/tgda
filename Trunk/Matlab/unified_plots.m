close all

k = 10^(-3):0.005:10^3;
ik = (k.^(3));
ik(isinf(ik)) = 0;
ik(isnan(ik)) = 0;

% u_10_5km_k = UnifiedSpectrum1Dk(k, 10.0, 5000);
% u_10_10km_k = UnifiedSpectrum1Dk(k, 10.0, 10000);
% u_10_25km_k = UnifiedSpectrum1Dk(k, 10.0, 25000);
% u_10_50km_k = UnifiedSpectrum1Dk(k, 10.0, 50000);
% u_10_100km_k = UnifiedSpectrum1Dk(k, 10.0, 100000);
% u_10_250km_k = UnifiedSpectrum1Dk(k, 10.0, 250000);
% u_10_500km_k = UnifiedSpectrum1Dk(k, 10.0, 500000);
% u_10_600km_k = UnifiedSpectrum1Dk(k, 10.0, 600000);

u_3_500km_k = UnifiedSpectrum1Dk(k, 3.0, 500000);
u_5_500km_k= UnifiedSpectrum1Dk(k, 5.0, 500000);
u_7_500km_k = UnifiedSpectrum1Dk(k, 7.0, 500000);
u_9_500km_k = UnifiedSpectrum1Dk(k, 9.0, 500000);
u_11_500km_k = UnifiedSpectrum1Dk(k, 11.0, 500000);
u_13_500km_k = UnifiedSpectrum1Dk(k, 13.0, 500000);
u_15_500km_k = UnifiedSpectrum1Dk(k, 15.0, 500000);
u_17_500km_k = UnifiedSpectrum1Dk(k, 17.0, 500000);
u_19_500km_k = UnifiedSpectrum1Dk(k, 19.0, 500000);
u_21_500km_k = UnifiedSpectrum1Dk(k, 21.0, 500000);

figure
hold on
% plot(k(1:512), pm_k(1:512));
% plot(k(1:512), d_10_5km_k(1:512));
% plot(k(1:512), d_10_10km_k(1:512));
% plot(k(1:512), d_10_25km_k(1:512));
% plot(k(1:512), d_10_50km_k(1:512));
% plot(k(1:512), d_10_100km_k(1:512));
% plot(k(1:512), d_10_250km_k(1:512));
% plot(k(1:512), d_10_500km_k(1:512));
% plot(k(1:512), u_10_5km_k(1:512), 'r');
% plot(k(1:512), u_10_10km_k(1:512), 'r');
% plot(k(1:512), u_10_25km_k(1:512), 'r');
% plot(k(1:512), u_10_50km_k(1:512), 'r');
% plot(k(1:512), u_10_100km_k(1:512), 'r');
% plot(k(1:512), u_10_250km_k(1:512), 'r');
% plot(k(1:512), u_10_500km_k(1:512), 'r');

% plot(k(1:512), u_10_5km_k(1:512), 'r');
% plot(k(1:512), u_10_10km_k(1:512), 'r');
% plot(k(1:512), u_10_25km_k(1:512), 'r');
% plot(k(1:512), u_10_50km_k(1:512), 'r');
% plot(k(1:512), u_10_100km_k(1:512), 'r');
% plot(k(1:512), u_10_250km_k(1:512), 'r');
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
axis([-3, 4, -16, 5]);
hold off

figure
hold on
% plot(k(1:512), pm_k(1:512));
% plot(k(1:512), d_10_5km_k(1:512));
% plot(k(1:512), d_10_10km_k(1:512));
% plot(k(1:512), d_10_25km_k(1:512));
% plot(k(1:512), d_10_50km_k(1:512));
% plot(k(1:512), d_10_100km_k(1:512));
% plot(k(1:512), d_10_250km_k(1:512));
% plot(k(1:512), d_10_500km_k(1:512));
% plot(k(1:512), u_10_5km_k(1:512), 'r');
% plot(k(1:512), u_10_10km_k(1:512), 'r');
% plot(k(1:512), u_10_25km_k(1:512), 'r');
% plot(k(1:512), u_10_50km_k(1:512), 'r');
% plot(k(1:512), u_10_100km_k(1:512), 'r');
% plot(k(1:512), u_10_250km_k(1:512), 'r');
% plot(k(1:512), u_10_500km_k(1:512), 'r');

% plot(k(1:512), u_10_5km_k(1:512), 'r');
% plot(k(1:512), u_10_10km_k(1:512), 'r');
% plot(k(1:512), u_10_25km_k(1:512), 'r');
% plot(k(1:512), u_10_50km_k(1:512), 'r');
% plot(k(1:512), u_10_100km_k(1:512), 'r');
% plot(k(1:512), u_10_250km_k(1:512), 'r');
plot(log10(k), log10(u_3_500km_k .* ik), 'r');
plot(log10(k), log10(u_5_500km_k .* ik), 'r');
plot(log10(k), log10(u_7_500km_k .* ik), 'r');
plot(log10(k), log10(u_9_500km_k .* ik), 'r');
plot(log10(k), log10(u_11_500km_k .* ik), 'r');
plot(log10(k), log10(u_13_500km_k .* ik), 'r');
plot(log10(k), log10(u_15_500km_k .* ik), 'r');
plot(log10(k), log10(u_17_500km_k .* ik), 'r');
plot(log10(k), log10(u_19_500km_k .* ik), 'r');
plot(log10(k), log10(u_21_500km_k .* ik), 'r');
axis([-3, 4, -4, 0]);
hold off



