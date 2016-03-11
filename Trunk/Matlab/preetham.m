clear all
%close all

turbidity = 2.0;
thetaSun = 45 * (pi / 180);
phiSun = -pi/2;

mAY = [ 0.1787 -1.4630; -0.3554 0.4275; -0.0227 5.3251; 0.1206 -2.5771; -0.0670 0.3703 ];
mAx = [ -0.0193 -0.2592; -0.0665 0.0008; -0.0004 0.2125; -0.0641 -0.8989; -0.0033 0.0452 ];
mAy = [ -0.0167 -0.2608; -0.0950 0.0092; -0.0079 0.2102; -0.0441 -1.6537; -0.0109 0.0529 ];

AY = mAY * [turbidity 1]';
Ax = mAx * [turbidity 1]';
Ay = mAy * [turbidity 1]';

mxz = [ 0.00166 -0.00375 0.00209 0; -0.02903 0.06377 -0.03202 0.00394; 0.11693 -0.21196 0.06052 0.25886 ];
myz = [ 0.00275 -0.00610 0.00317 0; -0.04214 0.08970 -0.04153 0.00516; 0.15346 -0.26756 0.06670 0.26688 ];

chi = ((4.0 / 9.0) - (turbidity / 120.0)) * (pi - (2.0 * thetaSun));

T = [(turbidity * turbidity) turbidity 1 ];
Theta = [(thetaSun^3) (thetaSun^2) thetaSun 1]';

xz = T * mxz * Theta;
yz = T * myz * Theta;
Yz = (4.0453 * turbidity - 4.9710) * tan(chi) - 0.2155 * turbidity + 2.4192;

% convert kcd/m² to cd/m²
Yz = Yz * 1000.0;

resolution = 1024;
xyY = ones(resolution, resolution, 3);
XYZ = zeros(resolution, resolution, 3);
sRGB = zeros(resolution, resolution, 3);

radiusInPixel = resolution / 2;
rangeStart = -radiusInPixel + 0.5;
rangeEnd = radiusInPixel - 0.5;

% direction to sun
s = [ sin(thetaSun) * cos(phiSun), sin(thetaSun) * sin(phiSun), cos(thetaSun) ];

% precompute denominator which stays constant for each
% point on the hemisphere
denominator_x = digamma(0, thetaSun, Ax);
denominator_y = digamma(0, thetaSun, Ay);
denominator_Y = digamma(0, thetaSun, AY);

% compute preetham model at sun position
nominatorSun_x = digamma(thetaSun, 0, Ax);
nominatorSun_y = digamma(thetaSun, 0, Ay);
nominatorSun_Y = digamma(thetaSun, 0, AY);

sun_xyY = zeros(1,1,3);
sun_xyY(1,1,1) = xz * (nominatorSun_x / denominator_x);
sun_xyY(1,1,2) = yz * (nominatorSun_y / denominator_y);
sun_xyY(1,1,3) = Yz * (nominatorSun_Y / denominator_Y);

% compute sky model irradiance
degreeToRadians = pi / 180;

phiStep = 1 * degreeToRadians;
thetaStep = 1 * degreeToRadians;

[irrPhi irrTheta] = meshgrid(0:phiStep:2*pi,0:thetaStep:pi/2);

irrSinPhi = sin(irrPhi);
irrCosPhi = cos(irrPhi);
irrSinTheta = sin(irrTheta);
irrCosTheta = cos(irrTheta);

irrv(:,:,1) = irrSinTheta .* irrCosPhi;
irrv(:,:,2) = irrSinTheta .* irrSinPhi;
irrv(:,:,3) = irrCosTheta;

n = repmat(reshape([0 0 1],[1 1 3]),size(irrPhi,1),size(irrPhi,2));
nDotv = dot(n,irrv,3);

ss = repmat(reshape(s,[1 1 3]),size(irrPhi,1),size(irrPhi,2));
rotAxes = cross(irrv, ss, 3);
normRotAxes = sqrt(sum(abs(rotAxes).^2,3));
gammaAngle = atan2(normRotAxes, dot(ss, irrv, 3));

irrxyY(:,:,1) = xz .* (digamma(irrTheta, gammaAngle, Ax) ./ denominator_x);
irrxyY(:,:,2) = yz .* (digamma(irrTheta, gammaAngle, Ay) ./ denominator_y);
irrxyY(:,:,3) = Yz .* (digamma(irrTheta, gammaAngle, AY) ./ denominator_Y);

irrXYZ = xyY2XYZ(irrxyY);

% integraion over the hemisphere
% Documentation/Radiometry.pdf
irrXYZ = irrXYZ .* repmat(irrSinTheta,[1 1 3]) .* repmat(nDotv,[1 1 3]) .* phiStep .* thetaStep;
irradiance = sum(sum(irrXYZ));

bla = reshape(irradiance,[3,1,1]);
blu = reshape(irradiance,[1,3,1]);

irradiancexyY = XYZ2xyY(irradiance);
blaxyY = XYZ2xyY(bla);
bluxyY = XYZ2xyY(blu);

[xyY mask] = preethamSky(resolution, phiSun, thetaSun, turbidity);

x_c = xyY(:,:,1);
y_c = xyY(:,:,2);
Y_c = xyY(:,:,3);

x_c(mask) = irradiancexyY(1,1,1);
y_c(mask) = irradiancexyY(1,1,2);
Y_c(mask) = irradiancexyY(1,1,3);

xyY(:,:,1) = x_c;
xyY(:,:,2) = y_c;
xyY(:,:,3) = Y_c;

% tonemapping
a = 0.18;
Lwhite = 200;
xyY = tonemapReinhard(xyY, a, Lwhite);

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

