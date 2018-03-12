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

% nrows = size(x,1);
% ncols = size(x,2);
% image = zeros(nrows,ncols);
% 
% for ys=1:nrows
%     for xs=1:ncols
%         mx = x(ys,xs);
%         my = y(ys,xs);
%         
%         grid_xf = floor(mx);
%         grid_xc = floor(mx) + 1;
%         grid_yf = floor(my);
%         grid_yc = floor(my) + 1;
%         
%         grid_xf_index = mod(grid_xf - 1, pnoise.res) + 1;
%         grid_xc_index = mod(grid_xc - 1, pnoise.res) + 1;
%         grid_yf_index = mod(grid_yf - 1, pnoise.res) + 1;
%         grid_yc_index = mod(grid_yc - 1, pnoise.res) + 1;
%         
%         ll_index = mod(grid_yf_index + pnoise.P(grid_xf_index) - 1, pnoise.res) + 1;
%         lr_index = mod(grid_yf_index + pnoise.P(grid_xc_index) - 1, pnoise.res) + 1;
%         ul_index = mod(grid_yc_index + pnoise.P(grid_xf_index) - 1, pnoise.res) + 1;
%         ur_index = mod(grid_yc_index + pnoise.P(grid_xc_index) - 1, pnoise.res) + 1;
%         
%         gradient_ll = pnoise.G2(:,pnoise.P(ll_index));
%         gradient_lr = pnoise.G2(:,pnoise.P(lr_index));
%         gradient_ul = pnoise.G2(:,pnoise.P(ul_index));
%         gradient_ur = pnoise.G2(:,pnoise.P(ur_index));
%         
%         image(ys,xs) = noise2d_test(...
%             gradient_ll,gradient_ul,gradient_lr,gradient_ur,...
%             [grid_xf,grid_yf]',[grid_xf,grid_yc]',[grid_xc,grid_yf]',[grid_xc,grid_yc]',...
%             [mx,my]');
%     end
% end
% 
% imshow(image,[]);

grid_xf = floor(x);
grid_xc = floor(x) + 1;
grid_yf = floor(y);
grid_yc = floor(y) + 1;

grid_xf_indices = indexmod(grid_xf, pnoise.res);
grid_xc_indices = indexmod(grid_xc, pnoise.res);

ll_indices = indexmod(grid_yf + pnoise.P(grid_xf_indices), pnoise.res);
lr_indices = indexmod(grid_yf + pnoise.P(grid_xc_indices), pnoise.res);
ul_indices = indexmod(grid_yc + pnoise.P(grid_xf_indices), pnoise.res);
ur_indices = indexmod(grid_yc + pnoise.P(grid_xc_indices), pnoise.res);

gradient_ll = pnoise.G2(:,pnoise.P(ll_indices)');
gradient_lr = pnoise.G2(:,pnoise.P(lr_indices)');
gradient_ul = pnoise.G2(:,pnoise.P(ul_indices)');
gradient_ur = pnoise.G2(:,pnoise.P(ur_indices)');

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

ll = reshape(ll, size(x))';
lr = reshape(lr, size(x))';
ul = reshape(ul, size(x))';
ur = reshape(ur, size(x))';

s_x = scurve(x - grid_xf);
s_y = scurve(y - grid_yf);

a = ll .* (1 - s_x) + lr .* s_x;
b = ul .* (1 - s_x) + ur .* s_x;

n = a .* (1 - s_y) + b .* s_y;

end

function r = indexmod(x,res)
    r = mod(x - 1, res) + 1;
end

function s = scurve(p)
    s = 3.*(p.^2) - 2.*(p.^3);
end
