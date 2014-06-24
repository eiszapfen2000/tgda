clear all;
close all;

resolution = [ 256 256 ];
area = [ 15 15 ];
wind = [ 20 0];
deltakx = 2*pi / area(1);
deltaky = 2*pi / area(2);
% 
% kx = -0.2:deltakx:0.2;
% ky =  0.2:-deltaky:-0.2;
% k = zeros(size(ky,2), size(kx,2), 2);
% [ k(:,:,1) k(:,:,2) ] = meshgrid(kx, ky);

tmpm  = -resolution(1)/2:1:resolution(1)/2-1;
tmpn  =  resolution(2)/2:-1:-(resolution(2)/2)+1;
tmpms = tmpm.*(2*pi)./area(1);
tmpns = tmpn.*(2*pi)./area(2);
k = zeros(resolution(1), resolution(2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(tmpms, tmpns);

tmpx = tmpm .* area(1);
tmpx = tmpx ./ resolution(1);
x = repmat(tmpx, resolution(2), 1);

tmpy = tmpn .* area(2);
tmpy = tmpy ./ resolution(2);
y = repmat(tmpy', 1, resolution(1));

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);
knormalised = zeros(resolution(1), resolution(2), 2);
knormalised(:,:,1) = k(:,:,1)./knorm;
knormalised(find(isnan(knormalised)))=0;
knormalised(:,:,2) = k(:,:,2)./knorm;
knormalised(find(isnan(knormalised)))=0;



% windr = [50 0.0];
% phillips_dir_r_exponent2 = PhillipsSpectrumDirectionalTerm(k, knormalised, 2, windr);
% phillips_dir_r_exponent4 = PhillipsSpectrumDirectionalTerm(k, knormalised, 4, windr);
% 
% windur = [50 50.0];
% phillips_dir_ur_exponent2 = PhillipsSpectrumDirectionalTerm(k, knormalised, 2, windur);
% phillips_dir_ur_exponent4 = PhillipsSpectrumDirectionalTerm(k, knormalised, 4, windur);
% 
% figure
% imshow(phillips_dir_r_exponent2,[]);
% figure
% imshow(phillips_dir_r_exponent4,[]);
% figure
% imshow(phillips_dir_ur_exponent2,[]);
% figure
% imshow(phillips_dir_ur_exponent4,[]);


% pmspectrum = PiersonMoskovitzSpectrum(k, knorm, knormalised, wind, [], []);
[jspectrum_k jspectrum_o_t] = JONSWAPSpectrum(k, knorm, wind, 100000);
%phspectrum = PhillipsSpectrum(k, knorm, knormalised, wind, 0.0081, 0);
%uspectrum = UnifiedSpectrum(k, knorm, knormalised, wind, [], []);

% figure;
% mesh(k(:,:,1),k(:,:,2),pmspectrum);
% figure;
% mesh(k(:,:,1),k(:,:,2),jspectrum_k);


resolution = size(k);
gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
gaussrand = complex(gaussrandr, gaussrandi);

sigma = sqrt(2 .* jspectrum_k .* deltakx .* deltaky);

hf = figure;

axis equal
hold on

time = 0;
onedivsqrt2 = 1 / sqrt(2);
expomega = exp(1i.*jspectrum_o_t(:,:,1).*time);
completespectrum = onedivsqrt2 .* gaussrand .* sigma .* expomega;
completespectrum = ifftshift(completespectrum);
heights = ifft2(completespectrum);
heights = real(heights) .* (resolution(1) * resolution(2));
hm = mesh(x, y, heights);
set(hm, 'XDataSource', 'x');
set(hm, 'YDataSource', 'y');
set(hm, 'ZDataSource', 'heights');

while time < 10
    time = time + 1/30;
    
    expomega = exp(1i.*jspectrum_o_t(:,:,1).*time);
    completespectrum = onedivsqrt2 .* gaussrand .* sigma .* expomega;
    completespectrum = ifftshift(completespectrum);
    heights = ifft2(completespectrum);
    heights = real(heights) .* (resolution(1) * resolution(2));
    refreshdata(hm, 'caller');
    drawnow
    pause(1/30);
end

hold off

% xrow = jspectrum_o_t(find(kx==0),:,1);
% xrow = xrow(find(xrow==0):end);
% xgrid = repmat(xrow,size(ky,2),1);
% 
% ycolumn = pi/2:-pi/(size(ky,2)-1):-pi/2;
% ycolumn = ycolumn';
% ygrid = repmat(ycolumn,1,size(xrow,2));
% 
% [i j] = find(jspectrum_o_t(:,:,3)==0);
% jsp = jspectrum_o_t(:,j:end,3);
% 
% xcolumn = xgrid(:,1);
% ycolumn = ygrid(:,1);
% dlmwrite('3dtest.txt', [xcolumn, ycolumn, jsp(:,1)], 'newline', 'pc', 'delimiter',',');
% 
% for i = 2:size(xgrid,1)
%     xcolumn = xgrid(:,i);
%     ycolumn = ygrid(:,i);
%     dlmwrite('3dtest.txt',[], '-append', 'roffset', 1, 'newline', 'pc');
%     dlmwrite('3dtest.txt', [xcolumn, ycolumn, jsp(:,i)], '-append', 'newline', 'pc', 'delimiter',',');
% end