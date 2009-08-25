function y = h(resolution,area,wind,time)

tmpm = -resolution(1)/2:1:resolution(1)/2-1;
tmpn = resolution(2)/2:-1:-resolution(2)/2+1;
tmpm = tmpm.*(2*pi)./area(1);
tmpn = tmpn.*(2*pi)./area(2);
k = zeros(resolution(1),resolution(2),2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(tmpm,tmpn);

kx2tmp = realpow(k(:,:,1),2);
ky2tmp = realpow(k(:,:,2),2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);
knormalised = zeros(resolution(1),resolution(2),2);
knormalised(:,:,1) = k(:,:,1)./knorm;
knormalised(find(isnan(knormalised)))=0;
knormalised(:,:,2) = k(:,:,2)./knorm;
knormalised(find(isnan(knormalised)))=0;

frequencyspectrum = htilde(k,knorm,knormalised,wind,time);
frequencyspectrum = ifftshift(frequencyspectrum);

y = zeros(resolution(1),resolution(2),3);

y(:,:,1) = ifft2((frequencyspectrum));
y(:,:,2) = (-k(:,:,1) * imag(frequencyspectrum)) + i.*(k(:,:,1) * real(frequencyspectrum));
y(:,:,3) = k(:,:,1) * real(frequencyspectrum);
