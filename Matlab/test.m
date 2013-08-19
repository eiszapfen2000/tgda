clear

resolution = [128 128];
area1 = [10 10];
area2 = [100 100];
wind1 = [1.5  2.8];
wind2 = [10.5 2.8];
phillipsconstant = 0.81;
A1 = phillipsconstant / (area1(1) * area1(2));
A2 = phillipsconstant / (area2(1) * area2(2));

gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
gaussrand = complex(gaussrandr, gaussrandi);

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

[ z1 x1 y1 dispx1 dispy1 gradx1 grady1] = heightfield(resolution, resolution, area1, area1, gaussrand, wind2, A1, 0, 1);
[ z2 x2 y2 dispx2 dispy2 gradx2 grady2] = heightfield(resolution, resolution, area2, area2, gaussrand, wind2, A2, 0, 1);

close all
figure
surf(x1, y1, z1);
axis equal

figure
surf(x2, y2, z2);
axis equal

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
