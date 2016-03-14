function [xyY, varargout] = preethamSky(resolution, phiSun, thetaSun, turbidity)

mAY = [  0.1787 -1.4630; -0.3554 0.4275; -0.0227 5.3251;  0.1206 -2.5771; -0.0670 0.3703 ];
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

% zenith color
xz = T * mxz * Theta;
yz = T * myz * Theta;
Yz = (4.0453 * turbidity - 4.9710) * tan(chi) - 0.2155 * turbidity + 2.4192;

% convert kcd/m² to cd/m²
Yz = Yz * 1000.0;

xyY = ones(resolution, resolution, 3);

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

% create zero centered pixel coordinates
[a,b] = meshgrid(rangeStart:rangeEnd, rangeEnd:-1:rangeStart);

% compute distance from center for each pixel coordinate pair
radius = sqrt((abs(a).^2)+(abs(b).^2));

% http://en.wikipedia.org/wiki/Stereographic_projection
% we use the south pole (0, 0, -1) as projection point
% because we want to project the upper hemisphere onto
% a circle
% X Y represent coordinates after stereographic projection
X = a ./ radiusInPixel;
Y = b ./ radiusInPixel;
l = 1 + X.^2 + Y.^2;

% convert X Y to coordinates on the unit sphere
x = 2.*X ./ l;
y = 2.*Y ./ l;
z = (1 - X.^2 - Y.^2) ./ l;

v(:,:,1) = x;
v(:,:,2) = y;
v(:,:,3) = z;

% http://de.wikipedia.org/wiki/Kugelkoordinaten
% We use the same coordinate system as shown at the site above
% coordinate axes of said coordinate system and the one for
% stereographic projection match

% compute spherical coordinates
xy_norm = sqrt((abs(x).^2)+(abs(y).^2));
phiAngle = atan2(y, x);
thetaAngle = (pi / 2) - atan(z ./ xy_norm);

% compute angle between direction to sun and coordinates
% on hemisphere
ss = repmat(reshape(s,[1 1 3]),resolution,resolution);
rotAxes = cross(v, ss, 3);
normRotAxes = sqrt(sum(abs(rotAxes).^2,3));
gammaAngle = atan2(normRotAxes, dot(ss, v, 3));

% compute preetham model for coordinates on hemisphere
v_x = xz .* (digamma(thetaAngle, gammaAngle, Ax) ./ denominator_x);
v_y = yz .* (digamma(thetaAngle, gammaAngle, Ay) ./ denominator_y);
v_Y = Yz .* (digamma(thetaAngle, gammaAngle, AY) ./ denominator_Y);

% pixels outside of the projected hemisphere are set to 0
mask = radius > radiusInPixel;
v_x(mask) = 0;
v_y(mask) = 0;
v_Y(mask) = 0;

% preetham gives results in xyY space
xyY(:,:,1) = v_x;
xyY(:,:,2) = v_y;
xyY(:,:,3) = v_Y;

% sun disk
sunApparentDiameter = 9.35 * 10^-3; % radians
sunHalfApparentAngle = 0.5 * sunApparentDiameter;
sunDiskRadius = tan(sunHalfApparentAngle);

if abs(s(1)) > abs(s(2))
    ilen = 1.0 / norm([s(1) s(3)]);
    pv1 = ilen .* [-s(3) 0 s(1)];
else
    ilen = 1.0 / norm(s(2:3));
    pv1 = ilen .* [0 s(3) -s(2)];
end
pv2 = cross(s,pv1,2);
directionOnDisk = s + sunDiskRadius .* pv1 + sunDiskRadius .* pv2;
directionOnDiskN = directionOnDisk ./ norm(directionOnDisk);

rotAxes = cross(directionOnDiskN, s, 2);
normRotAxes = sqrt(sum(abs(rotAxes).^2,2));
sunHalfApparentAngle = atan2(normRotAxes, dot(s, directionOnDiskN, 2));


if nargout > 1
    varargout{1} = mask;
end

if nargout > 2
    zenith_xyY = [xz yz Yz];
    denominator =  [denominator_x, denominator_y, denominator_Y];
    irradiance = irradianceXYZ(s, zenith_xyY, denominator, [Ax Ay AY]);
    varargout{2} = XYZ2xyY(irradiance);
end

if nargout > 3
    % compute preetham model at sun position
    nominatorSun_x = digamma(thetaSun, 0, Ax);
    nominatorSun_y = digamma(thetaSun, 0, Ay);
    nominatorSun_Y = digamma(thetaSun, 0, AY);

    sun_xyY = zeros(3,1);
    sun_xyY(1) = xz * (nominatorSun_x / denominator_x);
    sun_xyY(2) = yz * (nominatorSun_y / denominator_y);
    sun_xyY(3) = Yz * (nominatorSun_Y / denominator_Y);
    
    varargout{3} = sun_xyY;
end

if nargout > 4
    
sun_spectral_radiance = [ ...
%in W.cm^{-2}.um^{-1}.sr^{-1}
1655.9,  1623.37, 2112.75, 2588.82, 2582.91, 2423.23, 2676.05, 2965.83, 3054.54, 3005.75, ...
3066.37, 2883.04, 2871.21, 2782.5,  2710.06, 2723.36, 2636.13, 2550.38, 2506.02, 2531.16, ...
2535.59, 2513.42, 2463.15, 2417.32, 2368.53, 2321.21, 2282.77, 2233.98, 2197.02, 2152.67, ...
2109.79, 2072.83, 2024.04, 1987.08, 1942.72, 1907.24, 1862.89, 1825.92,     0.0,     0.0, ...
0.0 ...
];

sun_spectral_k_o = [ ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.003, 0.006, 0.009, ...
0.014, 0.021, 0.03, 0.04, 0.048, 0.063, 0.075, 0.085, 0.103, 0.12, ...
0.12, 0.115, 0.125, 0.12, 0.105, 0.09, 0.079, 0.067, 0.057, 0.048, ...
0.036, 0.028, 0.023, 0.018, 0.014, 0.011, 0.01, 0.009, 0.007, 0.004, ...
0.0 ...
];

sun_spectral_k_wa = [ ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.016, 0.024, 0.0125, 1.0, 0.87, 0.061, 0.001, 1e-05, 1e-05, ...
0.0006 ...
];

sun_spectral_k_g = [ ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0.21, ...
0.0 ...
];

lambda_micrometer = [ ...
0.380, 0.390, 0.400, 0.410, 0.420, 0.430, 0.440, 0.450, 0.460, 0.470, ...
0.480, 0.490, 0.500, 0.510, 0.520, 0.530, 0.540, 0.550, 0.560, 0.570, ...
0.580, 0.590, 0.600, 0.610, 0.620, 0.630, 0.640, 0.650, 0.660, 0.670, ...
0.680, 0.690, 0.700, 0.710, 0.720, 0.730, 0.740, 0.750, 0.760, 0.770, ...
0.780 ...
];

xyz_matching_functions = [...
0.000159952,0.0023616,0.0191097,0.084736,0.204492,0.314679,0.383734,0.370702,0.302273,0.195618,0.080507,0.016172,0.003816,0.037465,0.117749,0.236491,0.376772,0.529826,0.705224,0.878655,1.01416,1.11852,1.12399,1.03048,0.856297,0.647467,0.431567,0.268329,0.152568,0.0812606,0.0408508,0.0199413,0.00957688,0.00455263,0.00217496,0.00104476,0.000508258,0.000250969,0.00012639,6.45258E-05,3.34117E-05; ...
1.7364e-05,0.0002534,0.0020044,0.008756,0.021391,0.038676,0.062077,0.089456,0.128201,0.18519,0.253589,0.339133,0.460777,0.606741,0.761757,0.875211,0.961988,0.991761,0.99734,0.955552,0.868934,0.777405,0.658341,0.527963,0.398057,0.283493,0.179828,0.107633,0.060281,0.0318004,0.0159051,0.0077488,0.00371774,0.00176847,0.00084619,0.00040741,0.00019873,9.8428e-05,4.9737e-05,2.5486e-05,1.3249e-05; ...
0.000704776,0.0104822,0.0860109,0.389366,0.972542,1.55348,1.96728,1.9948,1.74537,1.31756,0.772125,0.415254,0.218502,0.112044,0.060709,0.030451,0.013676,0.003988,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ...
];

radiansToDegree = 180 / pi;
thetaSunDegrees = thetaSun * radiansToDegree;
m = 1.0 / (cos(thetaSun) + 0.15 * power(93.885 - thetaSunDegrees, -1.253));
beta = 0.04608 * turbidity - 0.04586;
l = 0.35;
alpha = 1.3;
w = 2.0;

exponent = zeros(size(lambda_micrometer));
spectralRadiance = zeros(size(lambda_micrometer));
exponent = exponent + (-0.008735 * power(lambda_micrometer, -4.08 * m));
exponent = exponent + (-beta * power(lambda_micrometer, -alpha * m));
exponent = exponent + (-sun_spectral_k_o .* l .* m);
exponent = exponent + ((-1.41 .* sun_spectral_k_g .* m) ./ power(1.0 + 118.93 .* sun_spectral_k_g .* m, 0.45));
exponent = exponent + ((-0.2385 .* sun_spectral_k_wa .* w .* m) ./ power(1.0 + 20.07 .* sun_spectral_k_wa .* w .* m, 0.45));
spectralRadiance = sun_spectral_radiance .* exp(exponent);

scaling = (100^2) * (1/10^3);
deltanm = 10.0;
combined = scaling * deltanm;

transmittance = [0 0 0];
transmittance(1) = (spectralRadiance * xyz_matching_functions(1,:)') .* combined;
transmittance(2) = (spectralRadiance * xyz_matching_functions(2,:)') .* combined;
transmittance(3) = (spectralRadiance * xyz_matching_functions(3,:)') .* combined;

varargout{4} = XYZ2xyY(transmittance);

bla = sunRadiance(thetaSun, turbidity);
blu = XYZ2xyY(transmittance);

end

end

function r = irradianceXYZ(s, zenith_xyY, denominator_xyY, A)
    degreeToRadians = pi / 180;

    phiStep = 1 * degreeToRadians;
    thetaStep = 1 * degreeToRadians;

    [irrPhi, irrTheta] = meshgrid(0:phiStep:2*pi,0:thetaStep:pi/2);

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

    irrxyY(:,:,1) = zenith_xyY(1) .* (digamma(irrTheta, gammaAngle, A(:,1)) ./ denominator_xyY(1));
    irrxyY(:,:,2) = zenith_xyY(2) .* (digamma(irrTheta, gammaAngle, A(:,2)) ./ denominator_xyY(2));
    irrxyY(:,:,3) = zenith_xyY(3) .* (digamma(irrTheta, gammaAngle, A(:,3)) ./ denominator_xyY(3));

    % integraion over the hemisphere
    % Documentation/Radiometry.pdf
    irrXYZ = xyY2XYZ(irrxyY);
    irrXYZ = irrXYZ .* repmat(irrSinTheta,[1 1 3]) .* repmat(nDotv,[1 1 3]) .* phiStep .* thetaStep;
    r = reshape(sum(sum(irrXYZ)),[3 1 1]);
end

%% Old implementation
% MATLAB memory layout, image coordinate (1,1) is at top left
% start j at top
% for j = rangeEnd:-1:rangeStart
%     % start i at left
%     for i = rangeStart:rangeEnd
%         radius = norm([i j]);
%         
%         % if we are inside circle the hemisphere is projected onto
%         if ( radius <= radiusInPixel )
%             % indices into result array
%             ix = i - rangeStart + 1;
%             iy = rangeEnd - j + 1;
%             
%             % http://en.wikipedia.org/wiki/Stereographic_projection
%             % we use the south pole (0, 0, -1) as projection point
%             % because we want to project the upper hemisphere onto
%             % a circle
%             
%             % X Y represent coordinates after stereographic projection
%             radiusNormalised = radius / radiusInPixel;
%             X = i / radiusInPixel;
%             Y = j / radiusInPixel;
%             
%             l = 1 + X*X + Y*Y;
%             
%             % convert X Y to coordinates on the unit sphere
%             x = 2*X / l;
%             y = 2*Y / l;
%             z = (1 - X*X - Y*Y) / l;
%             
%             % http://de.wikipedia.org/wiki/Kugelkoordinaten
%             % We use the same coordinate system as shown at the site above
%             % coordinate axes of said coordinate system and the one for
%             % stereographic projection match
%             
%             % compute spherical coordinates
%             phiAngle   = atan2(y, x);
%             thetaAngle = (pi / 2) - atan(z/norm([x y]));
%             
%             % compute angle between direction to sun and current coordinate
%             % on hemisphere
%             v = [x y z];
%             cosGamma = s * v';
%             gammaAngle = acos(cosGamma);
%             
%             % compute preetham model for current coordinate on hemisphere
%             v_x = xz * (digamma(thetaAngle, gammaAngle, Ax) / denominator_x);
%             v_y = yz * (digamma(thetaAngle, gammaAngle, Ay) / denominator_y);
%             v_Y = Yz * (digamma(thetaAngle, gammaAngle, AY) / denominator_Y);
%             
%             % preetham gives results in xyY space
%             xyY(iy,ix,1) = v_x;
%             xyY(iy,ix,2) = v_y;
%             xyY(iy,ix,3) = v_Y;
%             
%             % convert xyY to XYZ
%             lXYZ = zeros(1,3);
%             lXYZ(1) = (v_x / v_y) * v_Y;
%             lXYZ(2) = v_Y;
%             lXYZ(3) = ((1.0 - v_x - v_y) / v_y) * v_Y;
%             
%             XYZ(iy,ix,:) = lXYZ;
%             
%             % convert XYZ to linear sRGB
%             lsRGB = XYZ2sRGBD50 * lXYZ';
%             sRGB(iy,ix,:) = lsRGB;
%         end
%     end
% end
