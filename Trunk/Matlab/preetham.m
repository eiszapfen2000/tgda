clear all
%close all

turbidity = 2.0;
thetaSun = 0 * (pi / 180);
phiSun = -pi/2;

resolution = 255;
[xyY, mask, irradiancexyY, s_xyY, nix] = preethamSky(resolution, phiSun, thetaSun, turbidity);

x_c = xyY(:,:,1);
y_c = xyY(:,:,2);
Y_c = xyY(:,:,3);

irradianceXYZ = xyY2XYZ(irradiancexyY);
irradianceXYZ(1) = 0.17 * (irradianceXYZ(1) / pi);
irradianceXYZ(2) = 0.17 * (irradianceXYZ(2) / pi);
irradianceXYZ(3) = 0.17 * (irradianceXYZ(3) / pi);
irradiancexyY = XYZ2xyY(irradianceXYZ);

x_c(mask) = s_xyY(1);
y_c(mask) = s_xyY(2);
Y_c(mask) = s_xyY(3);

xyYirr(:,:,1) = x_c;
xyYirr(:,:,2) = y_c;
xyYirr(:,:,3) = Y_c;

% tonemapping
a = 0.18;
Lwhite = 2;
[xyY, Lw_average] = tonemapReinhard(xyY, a, Lwhite);
[xyYirr, Lw_average] = tonemapReinhard(xyYirr, a, Lwhite);

% convert xyY to XYZ
XYZ = xyY2XYZ(xyY);
XYZirr = xyY2XYZ(xyYirr);

% convert XYZ to linear sRGB
sRGB = XYZ2lsRGB(XYZ);
sRGBirr = XYZ2lsRGB(XYZirr);

% convert from linear sRGB to sRGB
sRGB = lsRGB2sRGB(sRGB);
sRGBirr = lsRGB2sRGB(sRGBirr);

figure
imshow(sRGB);

figure
imshow(sRGBirr);

