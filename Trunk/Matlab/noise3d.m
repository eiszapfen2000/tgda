function [n, pnoise] = noise3d(pnoise, x, y, z)

if ~isfield(pnoise, 'res')
    % number of grid points
    pnoise.res = 256;
end

if ~isfield(pnoise, 'P')
    % permutation table
    pnoise.P = randperm(pnoise.res);
end

if ~isfield(pnoise, 'G3')
    % uniform random numbers in the range (-1,1)
    pnoise.G3 = -1 + (1 - (-1)) .* rand(3, pnoise.res);
    
    % normalise gradient vectors
    gn = sqrt(sum(abs(pnoise.G3).^2, 1));
    pnoise.G3(1,:) = pnoise.G3(1,:) ./ gn;
    pnoise.G3(2,:) = pnoise.G3(2,:) ./ gn;
    pnoise.G3(3,:) = pnoise.G3(3,:) ./ gn;
end

nrows = size(x,1);
ncols = size(x,2);
nlayers = size(x,3);
n = zeros(nrows,ncols,nlayers);

for zs=1:nlayers
    for ys=1:nrows
        for xs=1:ncols
            mx = x(ys,xs,zs);
            my = y(ys,xs,zs);
            mz = z(ys,xs,zs);

            grid_xf = floor(mx);
            grid_xc = floor(mx) + 1;
            grid_yf = floor(my);
            grid_yc = floor(my) + 1;
            grid_zf = floor(mz);
            grid_zc = floor(mz) + 1;

            b_ll_index = gindex(pnoise,grid_xf,grid_yf,grid_zf);
            b_lr_index = gindex(pnoise,grid_xc,grid_yf,grid_zf);
            b_ul_index = gindex(pnoise,grid_xf,grid_yc,grid_zf);
            b_ur_index = gindex(pnoise,grid_xc,grid_yc,grid_zf);
            
            t_ll_index = gindex(pnoise,grid_xf,grid_yf,grid_zc);
            t_lr_index = gindex(pnoise,grid_xc,grid_yf,grid_zc);
            t_ul_index = gindex(pnoise,grid_xf,grid_yc,grid_zc);
            t_ur_index = gindex(pnoise,grid_xc,grid_yc,grid_zc);

            gradient_b_ll = pnoise.G2(:,b_ll_index);
            gradient_b_lr = pnoise.G2(:,b_lr_index);
            gradient_b_ul = pnoise.G2(:,b_ul_index);
            gradient_b_ur = pnoise.G2(:,b_ur_index);
            
            gradient_t_ll = pnoise.G2(:,t_ll_index);
            gradient_t_lr = pnoise.G2(:,t_lr_index);
            gradient_t_ul = pnoise.G2(:,t_ul_index);
            gradient_t_ur = pnoise.G2(:,t_ur_index);
            
            b_ll = [grid_xf,grid_yf,grid_zf]';
            b_lr = [grid_xc,grid_yf,grid_zf]';
            b_ul = [grid_xf,grid_yc,grid_zf]';
            b_ur = [grid_xc,grid_yc,grid_zf]';
            
            t_ll = [grid_xf,grid_yf,grid_zc]';
            t_lr = [grid_xc,grid_yf,grid_zc]';
            t_ul = [grid_xf,grid_yc,grid_zc]';
            t_ur = [grid_xc,grid_yc,grid_zc]';
            
            m = [mx,my,mz]';
            
            delta_b_ll = m - b_ll;
            delta_b_lr = m - b_lr;
            delta_b_ul = m - b_ul;
            delta_b_ur = m - b_ur;

            delta_t_ll = m - t_ll;
            delta_t_lr = m - t_lr;
            delta_t_ul = m - t_ul;
            delta_t_ur = m - t_ur;
            
            n_b_ll = dot(gradient_b_ll, delta_b_ll);
            n_b_ul = dot(gradient_b_ul, delta_b_ul);
            n_b_lr = dot(gradient_b_lr, delta_b_lr);
            n_b_ur = dot(gradient_b_ur, delta_b_ur);
            
            n_t_ll = dot(gradient_t_ll, delta_t_ll);
            n_t_ul = dot(gradient_t_ul, delta_t_ul);
            n_t_lr = dot(gradient_t_lr, delta_t_lr);
            n_t_ur = dot(gradient_t_ur, delta_t_ur);
            
            s_x = scurve(delta_b_ll(1));
            s_y = scurve(delta_b_ll(2));
            s_z = scurve(delta_b_ll(3));

            a = n_b_ll * (1 - s_x) + n_b_lr * s_x;
            b = n_b_ul * (1 - s_x) + n_b_ur * s_x;

            c = n_t_ll * (1 - s_x) + n_t_lr * s_x;
            d = n_t_ul * (1 - s_x) + n_t_ur * s_x;
            
            e = a * (1 - s_y) + b * s_y;
            f = c * (1 - s_y) + d * s_y;
            
            g = e * (1 - s_z) + f * s_z;
            
            n(ys,xs,zs) = g;
        end
    end
end

imshow(n(:,:,1),[]);
end

function r = indexmod(x,res)
    r = mod(x - 1, res) + 1;
end

function r = gindex(pnoise,x,y,z)
    k = indexmod(x, pnoise.res);
    jk = indexmod(y + pnoise.P(k), pnoise.res);
    ijk = indexmod(z + pnoise.P(jk), pnoise.res);
    r = ijk;    
end

function s = scurve(p)
    s = 3.*(p.^2) - 2.*(p.^3);
end