close all

g = 9.81;

k = 0.01:0.0005:1000;

u_10_100km = UnifiedSpectrum1Dk(k, 10.0, 500000);
u_10_200km = UnifiedSpectrum1Dk(k, 10.0, 200000);
u_10_300km = UnifiedSpectrum1Dk(k, 10.0, 300000);
u_10_400km = UnifiedSpectrum1Dk(k, 10.0, 400000);
u_10_500km = UnifiedSpectrum1Dk(k, 10.0, 500000);

figure
hold on
plot(k, u_10_100km);
plot(k, u_10_200km);
plot(k, u_10_300km);
plot(k, u_10_400km);
plot(k, u_10_500km);
hold off

