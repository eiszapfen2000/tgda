clear all
%close all

turbidity = 2.0;
thetaSun = 45 * (pi / 180);
phiSun = -pi/2;

resolution = 1024;
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
sRGB = XYZ2lsRGB(XYZ);

% convert from linear sRGB to sRGB
sRGB = lsRGB2sRGB(sRGB);

figure
imshow(sRGB);

