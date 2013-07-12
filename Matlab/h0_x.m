function y = h0_x(resolution, area, randomnumbers, wind, l)

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

phillipsspectrum = PhillipsSpectrum(k, knorm, knormalised, wind, l);

tmp = complex((1/sqrt(2)));
tmp = tmp.*randomnumbers;
tmp = tmp.*complex(sqrt(phillipsspectrum));
y = tmp;

%k(:,:,1)

end
