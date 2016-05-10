function [pn, octaves, pnoise] = perlinNoise2d(pnoise, resolution, octaves, persistence)


startOctave = octaves(1);
nOctaves = octaves(2);

pn = zeros(resolution,resolution);
octaves = zeros([resolution,resolution,nOctaves]);

for i=startOctave:startOctave+nOctaves-1
    f = 2^(i-1);
    amplitude = persistence^(i-1);
    
    x = [1:(1/(resolution-1))*f:1+f];
    y = x(end:-1:1);
    [xm, ym] = meshgrid(x, y);
    
    [n, pnoise] = noise2d(pnoise, xm, ym);
    
    octaves(:,:,i-startOctave+1) = n .* amplitude;
    pn = pn + n .* amplitude;
end

end