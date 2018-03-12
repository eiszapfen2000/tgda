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
maxK = [ 0 maxWavenumbers(x) ];

% plotRangedSpectra(x, 1, maxK);

% for i=1:numel(x)
% plotSpectrum(figure(), x{i}.k, x{i}.a);
% end

writeRangedSpectra(x, 'sampling_scale_03_lod_%d.dat');
writeRangedSpectra(x, 'sampling_scale_03_lod_%d_capped.dat', 1, maxK);

config.areas = areas(config.maxArea, 4, gsLong);
x = generateSpectra(config);
maxK = [ 0 maxWavenumbers(x) ];

% plotRangedSpectra(x, 1, maxK);

% for i=1:numel(x)
% plotSpectrum(figure(), x{i}.k, x{i}.a);
% end

writeRangedSpectra(x, 'sampling_scale_06_lod_%d.dat');
writeRangedSpectra(x, 'sampling_scale_06_lod_%d_capped.dat', 1, maxK);

end
%%
function spectra = generateSpectra(c)
alphas = 0:1:c.resolution-1;

spectra = cell(1, numel(c.areas));
for i=1:numel(c.areas)
    deltakx = 2*pi / c.areas(i);
    spectra{i}.resolution = c.resolution;
    spectra{i}.area = c.areas(i);
    spectra{i}.k = deltakx .* alphas;
    spectra{i}.a  = UnifiedSpectrum1Dk(spectra{i}.k, c.wind, c.fetch, []);
end

end
%%
function maxK = maxWavenumbers(spectra)
    maxK = zeros(1, numel(spectra));
    for l=1:numel(spectra)
        %maxK(l) = sqrt(2)* pi * (ocean.lods{l}.resolution / ocean.lods{l}.area);
        % we compute maxK not the standard way, because we use only
        % k>=0
        maxK(l) = 2*pi*((spectra{l}.resolution-1)/spectra{l}.area);
    end
end
%%
function a = areas(largestArea, nAreas, scale)
    a = power(scale,0:1:nAreas-1) .* largestArea;
end
%%
function rs = rangedSpectra(spectra, varargin)

delta = 1;
minK = -ones(1, numel(spectra));
rs = cell(1, numel(spectra));

optargin = size(varargin, 2);

if optargin > 0
    delta = varargin{1};
end

if optargin > 1
    minK = varargin{2};
end

for l=1:numel(spectra)
    rs{l}.area = spectra{l}.area;
    rs{l}.resolution = spectra{l}.resolution;
    
    k = spectra{l}.k;
    ix = find(k > minK(l), 1, 'first');
    k = k(ix:end);
    rs{l}.k = k(1:delta:end);
    
    a = spectra{l}.a;
    a = a(ix:end);
    rs{l}.a = a(1:delta:end);
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
function plotRangedSpectra(spectra, varargin)

rs = rangedSpectra(spectra, varargin{:});

figure
hold on
cmap = hsv(numel(rs));
for l=1:numel(rs)
    plot(rs{l}.k, rs{l}.a, 'Color', cmap(l,:));
end
hold off
end
%%
function writeRangedSpectra(spectra, baseFileame, varargin)

rs = rangedSpectra(spectra, varargin{:});

for l=1:numel(rs)   
    write2dcsv(rs{l}.k, rs{l}.a, sprintf(baseFileame, l));
end

end