function wavenumberslod

clear
close all

time = 1;
igs = 2 / (1 + sqrt(5));
%igs = 1 / (1 + sqrt(5));
%igs = 0.5;

geometry = [];
geometry.geometryRes = 512;
geometry.gradientRes = 512;

maxArea = 2000;
geometry.lodAreas = [ maxArea, maxArea*igs maxArea*igs*igs maxArea*igs*igs*igs ];

settings = [];
settings.generatorName = 'Unified';
settings.wind = [ 2.5 0 ];
settings.fetch = 500000;

o = ocean_init(geometry, settings);

maxK = 0;
for l=1:numel(o.lods)
    maxK(end+1) = sqrt(2)* pi * (o.lods{l}.resolution / o.lods{l}.area);
end

for l=1:numel(o.lods)
    [ kn, a ] = rangedSpectrum(o.lods{l}, 0, 4, settings);
    write2dcsv(kn', a', sprintf('sampling_scale_06_lod_%d.dat', l));
end

for l=1:numel(o.lods)
    [ kn, a ] = rangedSpectrum(o.lods{l}, maxK(l), 4, settings);
    write2dcsv(kn', a', sprintf('sampling_scale_06_lod_%d_capped.dat', l));
end

igs = 1 / (1 + sqrt(5));
geometry.geometryRes = 256;
geometry.gradientRes = 256;
geometry.lodAreas = [ maxArea, maxArea*igs maxArea*igs*igs maxArea*igs*igs*igs ];
o = ocean_init(geometry, settings);

maxK = 0;
for l=1:numel(o.lods)
    maxK(end+1) = sqrt(2)* pi * (o.lods{l}.resolution / o.lods{l}.area);
end

for l=1:numel(o.lods)
    [ kn, a ] = rangedSpectrum(o.lods{l}, 0, 2, settings);
    write2dcsv(kn', a', sprintf('sampling_scale_03_lod_%d.dat', l));
end

for l=1:numel(o.lods)
    [ kn, a ] = rangedSpectrum(o.lods{l}, maxK(l), 2, settings);
    write2dcsv(kn', a', sprintf('sampling_scale_03_lod_%d_capped.dat', l));
end

end

function k = wavenumberrange(kn, minK)
k = sort(unique(kn));
ix = find(k > minK, 1, 'first');
k = k(ix:end);
end

function [kn, a] = rangedSpectrum(lod, minK, delta, settings)
    kn = wavenumberrange(lod.kn, minK);
    kn = kn(1:delta:end);
    a  = UnifiedSpectrum1Dk(kn, settings.wind, settings.fetch, []);
end

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
