wind = [15 0.0];

kx = -0.1:0.01:0.2;
ky =  0.1:-0.01:-0.1;
k = zeros(size(ky,2), size(kx,2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(kx, ky);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);
knormalised = zeros(size(ky,2), size(kx,2), 2);
knormalised(:,:,1) = k(:,:,1)./knorm;
knormalised(isnan(knormalised))=0;
knormalised(:,:,2) = k(:,:,2)./knorm;
knormalised(isnan(knormalised))=0;

pmspectrum = PiersonMoskovitzSpectrum(k, knorm, knormalised, wind, [], []);
jspectrum = JONSWAPSpectrum(k, knorm, knormalised, wind, [], []);

% figure;
% mesh(k(:,:,1),k(:,:,2),pmspectrum);
% figure;
% mesh(k(:,:,1),k(:,:,2),jspectrum);

xcolumn = k(:,1,1);
ycolumn = k(:,1,2);
dlmwrite('3dtest.txt', [xcolumn, ycolumn, jspectrum(:,1)], 'newline', 'pc', 'delimiter',',');

for i = 2:size(kx,2)
    xcolumn = k(:,i,1);
    ycolumn = k(:,i,2);
    %ycolumn = 
    dlmwrite('3dtest.txt',[], '-append', 'roffset', 1, 'newline', 'pc');
    dlmwrite('3dtest.txt', [xcolumn, ycolumn, jspectrum(:,i)], '-append', 'newline', 'pc', 'delimiter',',');
end