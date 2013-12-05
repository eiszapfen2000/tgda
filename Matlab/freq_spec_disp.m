function [dispx dispy] = freq_spec_disp(resolution, area, freqspectrum)

tmpm  = -resolution(1)/2:1:resolution(1)/2-1;
tmpn  =  resolution(2)/2:-1:-(resolution(2)/2)+1;
tmpms =  tmpm.*(2*pi)./area(1);
tmpns =  tmpn.*(2*pi)./area(2);

k = zeros(resolution(1), resolution(2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(tmpms, tmpns);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);

%dxTerm = -1i .* k(:,:,1) ./ knorm;
%dyTerm = -1i .* k(:,:,2) ./ knorm;
dxTerm = 1i .* k(:,:,1) ./ knorm;
dyTerm = 1i .* k(:,:,2) ./ knorm;
dxTerm(isnan(dxTerm))=0;
dyTerm(isnan(dyTerm))=0;

dispx = dxTerm .* freqspectrum;
dispy = dyTerm .* freqspectrum;

end
