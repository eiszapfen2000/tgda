clear
close all

g = 9.81;

resolution = [ 8 8 ];
area = [ 10 10 ];
wind = [ 10 0 ];
fetch = 100000;
time = 1;

geometry = [];
geometry.geometryRes = 4;
geometry.gradientRes = 4;
geometry.lodAreas = [ 100 ];

settings = [];
settings.generatorName = 'Donelan';
settings.wind = [ 100 0 ];
settings.fetch = 100000;

lolz = ocean_init(geometry, settings);
lolz = ocean_animate(lolz, time);
lolz = ocean_transform(lolz);

figure
surf(lolz.lods(1).x, lolz.lods(1).z, lolz.lods(1).heights);
axis equal

% gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
% gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
% gaussrand = complex(gaussrandr, gaussrandi);
% gaussrand = lolz.lods(1).randomNumbers;
% 
% deltakx = 2*pi / area(1);
% deltaky = 2*pi / area(2);
% [k kn xz ] = build_wave_vectors(resolution, area);
% 
% omega = sqrt(kn * g);
% expomega = exp(1i.*omega.*time);
% expminusomega = exp(-1i.*omega.*time);
% 
% generator = 'PM';
% 
% Theta = [];
% 
% switch lower(generator)
%     case 'pm'
%         Theta = PiersonMoskovitzSpectrum(k, kn, wind);
%     case 'jonswap'
%         Theta = JONSWAPSpectrum(k, kn, wind, fetch);
%     case 'donelan'
%         Theta = DonelanSpectrum(k, kn, wind, fetch);
%     case 'unified'
%         Theta = UnifiedSpectrum(k, kn, wind, fetch);
% end

% energy Theta(k)
% Theta = PiersonMoskovitzSpectrum(k, kn, wind);
% Theta = UnifiedSpectrum(k, kn, wind, 100000);
% amplitude B(k)
% amplitude = sqrt(2.*Theta.*deltakx.*deltaky);

% 1/sqrt(2) * complex(grng_r, grng_i)
% randomFactor = 1/sqrt(2) .* gaussrand;
% 
% h_zero = randomFactor .* complex(amplitude ./ 2);
% h_tilde = zeros(resolution(1), resolution(2));
% for x=1:resolution(1)
%     for y=1:resolution(2)
%         index1 = mod(resolution(1)-x+1,resolution(1))+1;
%         index2 = mod(resolution(2)-y+1,resolution(2))+1;
%         h_tilde(x,y) = h_zero(x,y)*expminusomega(x,y) + conj(h_zero(index1, index2))*expomega(index1, index2);
%     end
% end
% 
% spectrum = randomFactor .* complex(amplitude) .* expminusomega;
% 
% spectrum_shifted = ifftshift(spectrum);
% h_tilde_shifted = ifftshift(h_tilde);
% 
% z1 = real(ifft2(spectrum_shifted));
% z2 = real(ifft2(h_tilde_shifted));
% z1 = z1 .* (resolution(1) * resolution(2));
% z2 = z2 .* (resolution(1) * resolution(2));
% 
% close all

% figure
% surf(xz(:,:,1), xz(:,:,2), z1);
% axis equal
% 
% figure
% surf(xz(:,:,1), xz(:,:,2), z2);
% axis equal

% resolution = [128 128];
% area1 = [10 10];
% area2 = [100 100];
% wind1 = [1.5  2.8];
% wind2 = [10.5 2.8];
% phillipsconstant = 0.81;
% A1 = phillipsconstant / (area1(1) * area1(2));
% A2 = phillipsconstant / (area2(1) * area2(2));
% 
% gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
% gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
% gaussrand = complex(gaussrandr, gaussrandi);

% h0_a1_w1 = h0_x(resolution, area1, gaussrand, wind1, A1, 0);
% h0_a1_w2 = h0_x(resolution, area1, gaussrand, wind2, A1, 0);
% h0_a2_w1 = h0_x(resolution, area1, gaussrand, wind1, A1, 0);
% h0_a2_w2 = h0_x(resolution, area1, gaussrand, wind2, A1, 0);
% 
% [htilde_a1_w1 x_a1_w1 y_a1_w1] = htilde_x(resolution, area1, h0_a1_w1, 1);
% [htilde_a1_w2 x_a1_w2 y_a1_w2] = htilde_x(resolution, area1, h0_a1_w2, 1);
% [htilde_a2_w1 x_a2_w1 y_a2_w1] = htilde_x(resolution, area2, h0_a2_w1, 1);
% [htilde_a2_w2 x_a2_w2 y_a2_w2] = htilde_x(resolution, area2, h0_a2_w2, 1);

% [gradx_a1_w1 grady_a1_w1] = freq_spec_grad(resolution, area1, htilde_a1_w1);
% [gradx_a1_w2 grady_a1_w2] = freq_spec_grad(resolution, area1, htilde_a1_w2);
% [gradx_a2_w1 grady_a2_w1] = freq_spec_grad(resolution, area2, htilde_a2_w1);
% [gradx_a2_w2 grady_a2_w2] = freq_spec_grad(resolution, area2, htilde_a2_w2);
% 
% [dispx_a1_w1 dispy_a1_w1] = freq_spec_disp(resolution, area1, htilde_a1_w1);
% [dispx_a1_w2 dispy_a1_w2] = freq_spec_disp(resolution, area1, htilde_a1_w2);
% [dispx_a2_w1 dispy_a2_w1] = freq_spec_disp(resolution, area2, htilde_a2_w1);
% [dispx_a2_w2 dispy_a2_w2] = freq_spec_disp(resolution, area2, htilde_a2_w2);

% htilde_a1_w1_shifted = ifftshift(htilde_a1_w1);
% htilde_a1_w2_shifted = ifftshift(htilde_a1_w2);
% htilde_a2_w1_shifted = ifftshift(htilde_a2_w1);
% htilde_a2_w2_shifted = ifftshift(htilde_a2_w2);
% 
% h_a1_w1 = ifft2(htilde_a1_w1_shifted);
% h_a1_w2 = ifft2(htilde_a1_w2_shifted);
% h_a2_w1 = ifft2(htilde_a2_w1_shifted);
% h_a2_w2 = ifft2(htilde_a2_w2_shifted);
% 
% h_a1_w1 = h_a1_w1 .* (resolution(1) * resolution(2));
% h_a1_w2 = h_a1_w2 .* (resolution(1) * resolution(2));
% h_a2_w1 = h_a2_w1 .* (resolution(1) * resolution(2));
% h_a2_w2 = h_a2_w2 .* (resolution(1) * resolution(2));

% resolution = [4 4];
% tmpm1 = -resolution(1)/2:1:resolution(1)/2-1;
% tmpn1 = resolution(2)/2-1:-1:-resolution(2)/2;
% tmpms1 = tmpm1.*(2*pi)./10.0
% tmpns1 = tmpn1.*(2*pi)./10.0
% k1 = zeros(resolution(1), resolution(2), 2);
% [ k1(:,:,1) k1(:,:,2) ] = meshgrid(tmpms1, tmpns1);
% 
% resolution = [8 8];
% tmpm2 = -resolution(1)/2:1:resolution(1)/2-1;
% tmpn2 = resolution(2)/2-1:-1:-resolution(2)/2;
% tmpms2 = tmpm2.*(2*pi)./10.0;
% tmpns2 = tmpn2.*(2*pi)./10.0;
% k2 = zeros(resolution(1), resolution(2), 2);
% [ k2(:,:,1) k2(:,:,2) ] = meshgrid(tmpms2, tmpns2);

% [ z1 x1 y1 dispx1 dispy1 gradx1 grady1] = heightfield(resolution, resolution, area1, area1, gaussrand, wind2, A1, 0, 1);
% [ z2 x2 y2 dispx2 dispy2 gradx2 grady2] = heightfield(resolution, resolution, area2, area2, gaussrand, wind2, A2, 0, 1);

% gr = normrnd(0, 1, 128, 128);
% gi = normrnd(0, 1, 128, 128);
% gd = complex(gr, gi);
% 
% [ z1 x1 y1 dispx1 dispy1 gradx1 grady1] = heightfield([64 64], [128 128], area1, area1, gd, wind2, A1, 0, 1);


% close all
% figure
% surf(x1, y1, z1);
% axis equal
% 
% figure
% surf(x2, y2, z2);
% axis equal

% [x y z dispx dispy gradx grady] = h([8 8], [10 10], [25.5 24.8], 1, 5);
% 
% close all
% figure
% surf(x, y, z);
% axis equal
% 
% figure
% surf(x_a1_w1, y_a1_w1, h_a1_w1);
% axis equal

% figure
% surf(x_a1_w1, y_a1_w1, h_a1_w1);
% axis equal
% figure
% surf(x_a1_w2, y_a1_w2, h_a1_w2);
% axis equal
% figure
% surf(x_a2_w1, y_a2_w1, h_a2_w1);
% axis equal
% figure
% surf(x_a2_w2, y_a2_w2, h_a2_w2);
% axis equal
%get(gcf,'CurrentAxes')

% %h2 = surf(x - dispx, y - dispy , z);
% h2 = surf(x - dispx, y - dispy , z);
% axis equal
% max(max(z))
