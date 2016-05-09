function [n, pnoise] = noise1d(pnoise, x)

% https://web.archive.org/web/20150607183420/http://webstaff.itn.liu.se/~stegu/TNM022-2005/perlinnoiselinks/perlin-noise-math-faq.html

if ~isfield(pnoise, 'res')
    % number of grid points
    pnoise.res = 256;
end

if ~isfield(pnoise, 'P')
    % permutation table
    pnoise.P = randperm(pnoise.res);
end

if ~isfield(pnoise, 'G1')
    % uniform random numbers in the range (-1,1)
    pnoise.G1 = -1 + (1 - (-1)) .* rand(1, pnoise.res);
end

grid_xf = floor(x);
grid_xc = floor(x) + 1;

grid_xf_indices = mod(grid_xf - 1, pnoise.res) + 1;
grid_xc_indices = mod(grid_xc - 1, pnoise.res) + 1;

gradient_xf = pnoise.G1(pnoise.P(grid_xf_indices));
gradient_xc = pnoise.G1(pnoise.P(grid_xc_indices));

delta_xf = x - grid_xf;
delta_xc = x - grid_xc;

s = gradient_xf .* delta_xf;
t = gradient_xc .* delta_xc;

s_x = scurve(delta_xf);
n = s .* (1 - s_x) + t .* s_x;

end

function s = scurve(p)
    s = 3.*(p.^2) - 2.*(p.^3);
end