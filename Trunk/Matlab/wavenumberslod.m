clear
close all

time = 1;
igs = 2 / (1 + sqrt(5));
igs = 1 / (1 + sqrt(5));
%igs = 1/14;
%igs = 0.382;

geometry = [];
geometry.geometryRes = 16;
geometry.gradientRes = 16;

maxArea = 2000;
geometry.lodAreas = [ maxArea, maxArea*igs maxArea*igs*igs maxArea*igs*igs*igs ];
%float GRID1_SIZE = 5488.0; // size in meters (i.e. in spatial domain) of the first grid
%float GRID2_SIZE = 392.0; // size in meters (i.e. in spatial domain) of the second grid
%float GRID3_SIZE = 28.0; // size in meters (i.e. in spatial domain) of the third grid
%float GRID4_SIZE = 2.0; // size in meters (i.e. in spatial domain) of the fourth grid

settings = [];
settings.generatorName = 'Unified';
settings.wind = [ 10 0 ];
settings.fetch = 500000;

o = ocean_init(geometry, settings);

figure
hold on
cmap = hsv(numel(o.lods));
minK = 0;
for l=1:numel(o.lods)
    kn = sort(unique(o.lods{l}.kn));
    %ix = find(kn > minK, 1, 'first');
    kn = kn(2:end);
    %size(kn)
    a = UnifiedSpectrum1Dk(kn, settings.wind, settings.fetch, []);
    harea = area(kn, a);% 'Color', cmap(l,:));
    child = get(harea,'Children');
    set(child,'FaceColor', cmap(l,:))
    set(child,'FaceAlpha', 1.0 - l*0.1);
    set(child,'EdgeColor', 'none');    
    
    minKx = (pi * o.lods{l}.resolution) / o.lods{l}.area;
    minK = sqrt(minKx^2 + minKx^2);
end
hold off



% k = [];
% for l=1:numel(o.lods)
%     u = unique(o.lods{l}.kn);
%     k = [ k;  u];
% end
% 
% k = unique(k);
% 
% [ a b ] = Donelan19851Dk(k, settings.wind, settings.fetch, []);
