function [z x y] = h0_x(resolution, area, randomnumbers, wind, A, l)

tmpm = -resolution(1)/2:1:resolution(1)/2-1;
tmpn = resolution(2)/2-1:-1:-resolution(2)/2;
tmpms = tmpm.*(2*pi)./area(1);
tmpns = tmpn.*(2*pi)./area(2);
k = zeros(resolution(1), resolution(2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(tmpms, tmpns);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);
knormalised = zeros(resolution(1), resolution(2), 2);
knormalised(:,:,1) = k(:,:,1)./knorm;
knormalised(find(isnan(knormalised)))=0;
knormalised(:,:,2) = k(:,:,2)./knorm;
knormalised(find(isnan(knormalised)))=0;

z = h0(k, knorm, knormalised, randomnumbers, wind, A, l);

tmpx = tmpm .* area(1);
tmpx = tmpx ./ resolution(1);
x = repmat(tmpx, resolution(2), 1);

tmpy = tmpn .* area(2);
tmpy = tmpy ./ resolution(2);
y = repmat(tmpy', 1, resolution(1));

end
