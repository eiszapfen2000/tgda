clear all
%close all

turbidity = 2.0;
thetaSun = 45 * (pi / 180);
phiSun = -pi/2;

resolution = 1024;
xyY = ones(resolution, resolution, 3);
XYZ = zeros(resolution, resolution, 3);
sRGB = zeros(resolution, resolution, 3);

[xyY, mask, irradiancexyY, s_xyY] = preethamSky(resolution, phiSun, thetaSun, turbidity);

x_c = xyY(:,:,1);
y_c = xyY(:,:,2);
Y_c = xyY(:,:,3);

x_c(mask) = irradiancexyY(1);
y_c(mask) = irradiancexyY(2);
Y_c(mask) = irradiancexyY(3);

xyY(:,:,1) = x_c;
xyY(:,:,2) = y_c;
xyY(:,:,3) = Y_c;

% tonemapping
a = 0.18;
Lwhite = 200;
[xyY, Lw_average] = tonemapReinhard(xyY, a, Lwhite);

% convert xyY to XYZ
XYZ = xyY2XYZ(xyY);

% convert XYZ to linear sRGB
XYZ2sRGBD50 = [3.1338561 -1.6168667 -0.4906146; -0.9787684  1.9161415  0.0334540; 0.0719453 -0.2289914  1.4052427];

XYZ_vectors(1,:) = reshape(XYZ(:,:,1), 1, numel(XYZ(:,:,1)));
XYZ_vectors(2,:) = reshape(XYZ(:,:,2), 1, numel(XYZ(:,:,2)));
XYZ_vectors(3,:) = reshape(XYZ(:,:,3), 1, numel(XYZ(:,:,3)));

sRGB_vectors = XYZ2sRGBD50 * XYZ_vectors;

sRGB(:,:,1) = reshape(sRGB_vectors(1,:), size(XYZ,1), []);
sRGB(:,:,2) = reshape(sRGB_vectors(2,:), size(XYZ,1), []);
sRGB(:,:,3) = reshape(sRGB_vectors(3,:), size(XYZ,1), []);

% convert to non-linear sRGB 
mask = (sRGB > 0.0031308);
sRGB(mask) = ((1.055 * sRGB(mask)) .^ (1 / 2.4)) - 0.055;
sRGB(~mask) = 12.92 * sRGB(~mask);

figure
imshow(sRGB);

