function [gradx grady] = freq_spec_grad(resolution, area, freqspectrum)

tmpm  = -resolution(1)/2:1:resolution(1)/2-1;
tmpn  =  resolution(2)/2-1:-1:-resolution(2)/2;
tmpms =  tmpm.*(2*pi)./area(1);
tmpns =  tmpn.*(2*pi)./area(2);

k = zeros(resolution(1), resolution(2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(tmpms, tmpns);

gradx = 1i .* k(:,:,1) .* freqspectrum;
grady = 1i .* k(:,:,2) .* freqspectrum;

end
