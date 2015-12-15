function wavenumbersAreas
clear
close all

gsLong = 2 / (1 + sqrt(5));
gsShort = 1 - gsLong;

config.fetch = 500000;
config.wind = [ 5 0 ];
config.resolution = 128;
config.maxArea = 1750;
config.areas = areas(config.maxArea, 4, gsShort);

x = generateSpectra(config);

for i=1:numel(x)
plotSpectrum(figure(), x{i}.k, x{i}.a);
end

writeRangedSpectra(x, 'sampling_scale_03_lod_%d.dat');

config.areas = areas(config.maxArea, 4, gsLong);
x = generateSpectra(config);

for i=1:numel(x)
plotSpectrum(figure(), x{i}.k, x{i}.a);
end

writeRangedSpectra(x, 'sampling_scale_06_lod_%d.dat');

end
%%
function spectra = generateSpectra(c)
alphas = 0:1:c.resolution-1;

spectra = cell(1, numel(c.areas));
for i=1:numel(c.areas)
    deltakx = 2*pi / c.areas(i);
    spectra{i}.k = deltakx .* alphas;
    spectra{i}.a  = UnifiedSpectrum1Dk(spectra{i}.k, c.wind, c.fetch, []);
end
end
%%
function plotSpectrum(h, k, a)
figure(h)
hold on
plot(k, a);
hold off
end
%%
function a = areas(largestArea, nAreas, scale)
    a = power(scale,0:1:nAreas-1) .* largestArea;
end
%%
function writeRangedSpectra(spectra, baseFileame, varargin)

delta = 1;
minK = -ones(1, numel(spectra));

optargin = size(varargin,2);

if optargin > 0
    delta = varargin{1};
end

for l=1:numel(spectra)
    write2dcsv(spectra{l}.k, spectra{l}.a, sprintf(baseFileame, l));
end

end