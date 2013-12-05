function [x y z dispx dispy gradx grady ] = h(resolution, area, wind, l, time)

% facetX = area(1) / resolution(1)
% facetY = area(2) / resolution(2)
% g = 9.81;
% L = dot(wind, wind)/g

tmpm  = -resolution(1)/2:1:resolution(1)/2-1;
tmpn  =  resolution(2)/2:-1:-(resolution(2)/2)+1;
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

frequencyspectrum = htilde(k, knorm, knormalised, wind, l, time);

gradientFrequencySpectrumX = 1i .* k(:,:,1) .* frequencyspectrum;
gradientFrequencySpectrumY = 1i .* k(:,:,2) .* frequencyspectrum;

dxTerm = -1i .* k(:,:,1) ./ knorm;
dyTerm = -1i .* k(:,:,2) ./ knorm;
dxTerm(find(isnan(dxTerm)))=0;
dyTerm(find(isnan(dyTerm)))=0;

displacementFrequencySpectrumX = dxTerm .* frequencyspectrum;
displacementFrequencySpectrumY = dyTerm .* frequencyspectrum;

frequencyspectrumShifted = ifftshift(frequencyspectrum);
gradientFrequencySpectrumXShifted = ifftshift(gradientFrequencySpectrumX);
gradientFrequencySpectrumYShifted = ifftshift(gradientFrequencySpectrumY);
displacementFrequencySpectrumXShifted = ifftshift(displacementFrequencySpectrumX);
displacementFrequencySpectrumYShifted = ifftshift(displacementFrequencySpectrumY);

z = ifft2(frequencyspectrumShifted);
gradx = real(ifft2(gradientFrequencySpectrumXShifted));
grady = real(ifft2(gradientFrequencySpectrumYShifted));
dispx = real(ifft2(displacementFrequencySpectrumXShifted));
dispy = real(ifft2(displacementFrequencySpectrumYShifted));

z = z .* (resolution(1) * resolution(2));
gradx = gradx .* (resolution(1) * resolution(2));
grady = grady .* (resolution(1) * resolution(2));
dispx = dispx .* (resolution(1) * resolution(2));
dispy = dispy .* (resolution(1) * resolution(2));

tmpx = tmpm .* area(1);
tmpx = tmpx ./ resolution(1);
x = repmat(tmpx, resolution(2), 1);

tmpy = tmpn .* area(2);
tmpy = tmpy ./ resolution(2);
y = repmat(tmpy', 1, resolution(1));


% test = zeros(resolution(1), resolution(2));
% for x_y=1:resolution(2)
%     for x_x=1:resolution(1)
%         %localx = [tmpx(x_x) tmpy(x_y)];
%         localx = zeros(resolution(1), resolution(2),2);
%         localx(:,:,1) = tmpx(x_x);
%         localx(:,:,2) = tmpy(x_y);
%         localxDotk = dot(localx, k, 3);
%         %localxDotk = 1i .* localxDotk;
%         expResult = exp(localxDotk .* 1i);
%         product = frequencyspectrum .* expResult;
%         test(x_y, x_x) = sum(sum(product));        
%     end
% end
% w = real(test);
