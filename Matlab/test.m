clear

resolution = [128 128];
area1 = [10 10];
area2 = [1000 1000];
wind1 = [1.5 2.8];
wind2 = [10.5 20.8];
phillipsconstant = 0.0081;

gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
gaussrand = complex(gaussrandr, gaussrandi);

h0_a1_w1 = h0_x(resolution, area1, gaussrand, wind1, phillipsconstant, 0);
h0_a1_w2 = h0_x(resolution, area1, gaussrand, wind2, phillipsconstant, 0);
h0_a2_w1 = h0_x(resolution, area2, gaussrand, wind1, phillipsconstant, 0);
h0_a2_w2 = h0_x(resolution, area2, gaussrand, wind2, phillipsconstant, 0);

[htilde_a1_w1 x_a1_w1 y_a1_w1] = htilde_x(resolution, area1, h0_a1_w1, 1);
[htilde_a1_w2 x_a1_w2 y_a1_w2] = htilde_x(resolution, area1, h0_a1_w2, 1);
[htilde_a2_w1 x_a2_w1 y_a2_w1] = htilde_x(resolution, area2, h0_a2_w1, 1);
[htilde_a2_w2 x_a2_w2 y_a2_w2] = htilde_x(resolution, area2, h0_a2_w2, 1);

htilde_a1_w1_shifted = ifftshift(htilde_a1_w1);
htilde_a1_w2_shifted = ifftshift(htilde_a1_w2);
htilde_a2_w1_shifted = ifftshift(htilde_a2_w1);
htilde_a2_w2_shifted = ifftshift(htilde_a2_w2);

h_a1_w1 = ifft2(htilde_a1_w1_shifted);
h_a1_w2 = ifft2(htilde_a1_w2_shifted);
h_a2_w1 = ifft2(htilde_a2_w1_shifted);
h_a2_w2 = ifft2(htilde_a2_w2_shifted);

h_a1_w1 = h_a1_w1 .* (resolution(1) * resolution(2));
h_a1_w2 = h_a1_w2 .* (resolution(1) * resolution(2));
h_a2_w1 = h_a2_w1 .* (resolution(1) * resolution(2));
h_a2_w2 = h_a2_w2 .* (resolution(1) * resolution(2));

% [x y z dispx dispy gradx grady] = h([8 8], [10 10], [25.5 24.8], 1, 5);
% 
close all
figure
surf(x_a1_w1, y_a1_w1, h_a1_w1);
axis equal
figure
surf(x_a1_w2, y_a1_w2, h_a1_w2);
axis equal
figure
surf(x_a2_w1, y_a2_w1, h_a2_w1);
axis equal
figure
surf(x_a2_w2, y_a2_w2, h_a2_w2);
axis equal


% %h2 = surf(x - dispx, y - dispy , z);
% h2 = surf(x - dispx, y - dispy , z);
% axis equal
% max(max(z))
