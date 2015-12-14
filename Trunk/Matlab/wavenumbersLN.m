function wavenumbersLN
clear
close all

config.fetch = 500000;
config.wind = [ 4.5 0 ];

config.area = 100;
config.resolution = 12;
[k, a] = generateSpectrum(config);
write2dcsv(k, a, 'sampling_res_12_area_100.dat');

%plotSpectrum(h, k, a);

config.area = 50;
config.resolution = 12;
[k, a] = generateSpectrum(config);
write2dcsv(k, a, 'sampling_res_12_area_50.dat');

%plotSpectrum(h, k, a);

config.area = 100;
config.resolution = 12;
[k, a] = generateSpectrum(config);
write2dcsv(k, a, 'sampling_area_100_res_12.dat');

plotSpectrum(figure(), k, a);

config.resolution = 24;
[k, a] = generateSpectrum(config);
write2dcsv(k, a, 'sampling_area_100_res_24.dat');

plotSpectrum(figure(), k, a);

end

function [k, a] = generateSpectrum(c)
alphas = 0:1:c.resolution-1;
deltakx = 2*pi / c.area;
k = deltakx .* alphas;
a  = UnifiedSpectrum1Dk(k, c.wind, c.fetch, []);
end

function plotSpectrum(h, k, a)
figure(h)
hold on
plot(k, a);
hold off
end