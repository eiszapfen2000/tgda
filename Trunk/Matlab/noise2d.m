function [n, pnoise] = noise2d(pnoise, x, y)

if ~isfield(pnoise, 'res')
    % number of grid points
    pnoise.res = 256;
end

if ~isfield(pnoise, 'P')
    % permutation table
    pnoise.P = randperm(pnoise.res);
end

if ~isfield(pnoise, 'G2')
    % uniform random numbers in the range (-1,1)
    pnoise.G2 = -1 + (1 - (-1)) .* rand(2, pnoise.res);
    
    % normalise gradient vectors
    gn = sqrt(sum(abs(pnoise.G2).^2, 1));
    pnoise.G2(1,:) = pnoise.G2(1,:) ./ gn;
    pnoise.G2(2,:) = pnoise.G2(2,:) ./ gn;
end

grid_xf = floor(x);
grid_xc = floor(x) + 1;
grid_yf = floor(y);
grid_yc = floor(y) + 1;

grid_xf_indices = mod(grid_xf - 1, pnoise.res) + 1;
grid_xc_indices = mod(grid_xc - 1, pnoise.res) + 1;
grid_yf_indices = mod(grid_yf - 1, pnoise.res) + 1;
grid_yc_indices = mod(grid_yc - 1, pnoise.res) + 1;

ll_indices = mod(grid_yf_indices + pnoise.P(grid_xf_indices) - 1, pnoise.res) + 1;
lr_indices = mod(grid_yf_indices + pnoise.P(grid_xc_indices) - 1, pnoise.res) + 1;
ul_indices = mod(grid_yc_indices + pnoise.P(grid_xf_indices) - 1, pnoise.res) + 1;
ur_indices = mod(grid_yc_indices + pnoise.P(grid_xc_indices) - 1, pnoise.res) + 1;

gradient_ll = pnoise.G2(:,pnoise.P(ll_indices));
gradient_lr = pnoise.G2(:,pnoise.P(lr_indices));
gradient_ul = pnoise.G2(:,pnoise.P(ul_indices));
gradient_ur = pnoise.G2(:,pnoise.P(ur_indices));

% delta_ll = [x - grid_xf; y - grid_yf];
% delta_lr = [x - grid_xc; y - grid_yf];
% delta_ul = [x - grid_xf; y - grid_yc];
% delta_ur = [x - grid_xc; y - grid_yc];
delta_ll(1,:) = reshape((x-grid_xf)',1,[]);
delta_ll(2,:) = reshape((y-grid_yf)',1,[]);
delta_lr(1,:) = reshape((x-grid_xc)',1,[]);
delta_lr(2,:) = reshape((y-grid_yf)',1,[]);
delta_ul(1,:) = reshape((x-grid_xf)',1,[]);
delta_ul(2,:) = reshape((y-grid_yc)',1,[]);
delta_ur(1,:) = reshape((x-grid_xc)',1,[]);
delta_ur(2,:) = reshape((y-grid_yc)',1,[]);

ll = dot(gradient_ll, delta_ll);
lr = dot(gradient_lr, delta_lr);
ul = dot(gradient_ul, delta_ul);
ur = dot(gradient_ur, delta_ur);

% ll = reshape(ll, size(x))';
% lr = reshape(lr, size(x))';
% ul = reshape(ul, size(x))';
% ur = reshape(ur, size(x))';

% s_x = scurve(x - grid_xf);
% s_y = scurve(y - grid_yf);

s_x = reshape(scurve(x - grid_xf)',1,[]);
s_y = reshape(scurve(y - grid_yf)',1,[]);

a = ll + s_x .* (lr - ll);
b = ul + s_x .* (ur - ul);

n = a + s_y .* (b - a);

end

function s = scurve(p)
    s = 3.*(p.^2) - 2.*(p.^3);
end
