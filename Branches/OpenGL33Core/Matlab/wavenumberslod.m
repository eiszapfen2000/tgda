function wavenumberslod

clear
close all

gsLong = 2 / (1 + sqrt(5));

config.fetch = 500000;
config.wind = [ 4.5 0 ];
config.maxArea = 100;
config.nLods = 1;
config.areaScaleFactor = gsLong;

config.resolution = 16;
ol1 = generateOcean(config);
config.resolution = 64;
ol2 = generateOcean(config);


config.maxArea = 120;
config.resolution = 16;
ol3 = generateOcean(config);

config.maxArea = 40;
config.resolution = 16;
ol4 = generateOcean(config);

plotRangedSpectra(ol1, 1);
plotRangedSpectra(ol2, 1);

% plotRangedSpectra(ol3, 1);
% plotRangedSpectra(ol4, 1);

% writeRangedSpectra(ol1, 'sampling_area_100_res_16.dat');
% writeRangedSpectra(ol2, 'sampling_area_100_res_64.dat');
% 
% writeRangedSpectra(ol3, 'sampling_res_16_area_120.dat');
% writeRangedSpectra(ol4, 'sampling_res_16_area_40.dat');

end

%%
function a = areas(largestArea, nAreas, scale)
    a = power(scale,0:1:nAreas-1) .* largestArea;
end
%%
function k = uniqueWavenumbers(kn, minK)
k = sort(unique(kn));
ix = find(k > minK, 1, 'first');
k = k(ix:end);
end
%%
function [kn, a] = rangedSpectrum(lod, minK, delta, settings)
    kn = uniqueWavenumbers(lod.kn, minK);
    kn = kn(1:delta:end);
    a  = UnifiedSpectrum1Dk(kn, settings.wind, settings.fetch, []);
end
%%
function maxK = maxWavenumbers(ocean)
    maxK = zeros(1, numel(ocean.lods));
    for l=1:numel(ocean.lods)
        maxK(l) = sqrt(2)* pi * (ocean.lods{l}.resolution / ocean.lods{l}.area);
    end
end
%%
function writeRangedSpectra(ocean, baseFileame, varargin)

delta = 1;
minK = -ones(1, numel(ocean.lods));

optargin = size(varargin,2);

if optargin > 0
    delta = varargin{1};
end

if optargin > 1
    minK = varargin{2};
end

for l=1:numel(ocean.lods)
    [ kn, a ] = rangedSpectrum(ocean.lods{l}, minK(l), delta, ocean.settings);
    write2dcsv(kn', a', sprintf(baseFileame, l));
end

end
%%
function plotRangedSpectra(ocean, varargin)
delta = 1;
minK = -ones(1, numel(ocean.lods));

optargin = size(varargin,2);

if optargin > 0
    delta = varargin{1};
end

if optargin > 1
    minK = varargin{2};
end

figure
hold on
cmap = hsv(numel(ocean.lods));
for l=1:numel(ocean.lods)
    [ kn, a ] = rangedSpectrum(ocean.lods{l}, minK(l), delta, ocean.settings);
    plot(kn, a, 'Color', cmap(l,:));
end
hold off
end
%%
function o = generateOcean(c)

settings.fetch = c.fetch;
settings.wind = c.wind;
settings.generatorName = 'Unified';

geometry.geometryRes = c.resolution;
geometry.gradientRes = c.resolution;
geometry.lodAreas = areas(c.maxArea, c.nLods, c.areaScaleFactor);

o = ocean_init(geometry, settings);

end
%%

% figure
% hold on
% cmap = hsv(numel(o.lods));
% minK = 0;
% maxK = realmax();
% 
% for l=1:numel(o.lods)
%     minKx = (pi * o.lods{l}.resolution) / o.lods{l}.area;
%     minK(end+1) = sqrt(minKx^2 + minKx^2);
%     maxK(end+1) = 2*pi/o.lods{l}.area;
% end
% 
% for l=1:numel(o.lods)
%     kn = sort(unique(o.lods{l}.kn));
%     ix = find(kn > minK(l), 1, 'first');
%     kn = kn(ix:end);
%     %size(kn)
%     a = UnifiedSpectrum1Dk(kn, settings.wind, settings.fetch, []);
%     harea = area(kn, a);% 'Color', cmap(l,:));
%     child = get(harea,'Children');
%     set(child,'FaceColor', cmap(l,:))
%     set(child,'FaceAlpha', 1.0 - l*0.1);
%     set(child,'EdgeColor', 'black'); 
% end
% hold off
% 
% for l=1:numel(o.lods)
%     kn = sort(unique(o.lods{l}.kn));
%     kn = kn(2:end);
%     a = UnifiedSpectrum1Dk(kn, settings.wind, settings.fetch, []);
%     figure
%     harea = area(kn, a);% 'Color', cmap(l,:));
%     child = get(harea,'Children');
%     set(child,'FaceColor', cmap(l,:))
%     set(child,'FaceAlpha', l*0.1);
%     set(child,'EdgeColor', 'black'); 
% end



% k = [];
% for l=1:numel(o.lods)
%     u = unique(o.lods{l}.kn);
%     k = [ k;  u];
% end
% 
% k = unique(k);
% 
% [ a b ] = Donelan19851Dk(k, settings.wind, settings.fetch, []);
