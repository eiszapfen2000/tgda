function [pn, octaves, pnoise] = perlinNoise3d(pnoise, resolution, octaves, persistence)


startOctave = octaves(1);
nOctaves = octaves(2);

pn = zeros(resolution);
octaves = {};

x = [0:(1/(resolution(1)-1)):1];
y = [1:-(1/(resolution(2)-1)):0];
z = [0:(1/(resolution(3)-1)):1];

for i=startOctave:startOctave+nOctaves-1
    f = 2^(i-1);
    amplitude = persistence^(i-1);
    
    [xm, ym, zm] = meshgrid(x.*f, y.*f, z.*f);    
    [n, pnoise] = noise3d(pnoise, xm, ym, zm);

    pn = pn + n .* amplitude;
end

end