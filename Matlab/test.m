clear

resolution = [128 128];
area1 = [10 10];
area2 = [1000 1000];

gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
gaussrand = complex(gaussrandr, gaussrandi);

phillipsconstant = 0.0081;
h0_1 = h0_x(resolution, area1, gaussrand, [1.5 2.8], phillipsconstant, 0);
h0_2 = h0_x(resolution, area2, gaussrand, [10.5 20.8], phillipsconstant, 0);

[htilde_1 x1 y1] = htilde_x(resolution, area1, h0_1, 1);
[htilde_2 x2 y2] = htilde_x(resolution, area2, h0_2, 1);

htilde_1_shifted = ifftshift(htilde_1);
htilde_2_shifted = ifftshift(htilde_2);

h_1 = ifft2(htilde_1_shifted);
h_2 = ifft2(htilde_2_shifted);

h_1 = h_1 .* (resolution(1) * resolution(2));
h_2 = h_2 .* (resolution(1) * resolution(2));

% [x y z dispx dispy gradx grady] = h([8 8], [10 10], [25.5 24.8], 1, 5);
% 
close all
figure
h1 = surf(x1,y1,h_1);
axis equal
figure
h2 = surf(x2,y2,h_2 / 100);
axis equal
% %h2 = surf(x - dispx, y - dispy , z);
% h2 = surf(x - dispx, y - dispy , z);
% axis equal
% max(max(z))
