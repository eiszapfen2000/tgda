clear all
close all

XYZ2sRGBD50 = [3.1338561 -1.6168667 -0.4906146; -0.9787684  1.9161415  0.0334540; 0.0719453 -0.2289914  1.4052427];

turbidity = 4.0;

thetaSun = pi / 4;
phiSun = pi;

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

resolution = 1025;
xyY = ones(resolution, resolution, 3);
XYZ = zeros(resolution, resolution, 3);
sRGB = zeros(resolution, resolution, 3);
start = floor(resolution / 2);
remainder = rem(resolution, 2);

radiusForMaxTheta = start;

s = [ radiusForMaxTheta * sin(thetaSun) * cos(phiSun), radiusForMaxTheta * sin(thetaSun) * sin(phiSun), radiusForMaxTheta * cos(thetaSun) ];
s_n = s / norm(s);
denominator_x = digamma(0, thetaSun, Ax);
denominator_y = digamma(0, thetaSun, Ay);
denominator_Y = digamma(0, thetaSun, AY);

for y = -start:start
    for x = -start:start
        phiAngle = atan2(y,x);
        
        radius = sqrt(x*x + y*y);
        radiusNormalised = radius / radiusForMaxTheta;
        
        % only compute if we are inside circle
        if ( radiusNormalised <= 1.0 )
            thetaAngle = pi * 0.5 * radiusNormalised;
            
            v = [ x y radiusForMaxTheta * cos(thetaAngle) ];            
            v_n = v / norm(v);
            
            cosGamma = s_n * v_n';
            gammaAngle = acos(cosGamma);
            
            v_x = xz * (digamma(thetaAngle, gammaAngle, Ax) / denominator_x);
            v_y = yz * (digamma(thetaAngle, gammaAngle, Ay) / denominator_y);
            v_Y = Yz * (digamma(thetaAngle, gammaAngle, AY) / denominator_Y);
            
            xyY(x+start+1,y+start+1,1) = v_x;
            xyY(x+start+1,y+start+1,2) = v_y;
            xyY(x+start+1,y+start+1,3) = v_Y;
            
            lXYZ = zeros(1,3);
            lXYZ(1) = (v_x / v_y) * v_Y;
            lXYZ(2) = v_Y;
            lXYZ(3) = ((1.0 - v_x - v_y) / v_y) * v_Y;
            
            XYZ(x+start+1,y+start+1,1) = lXYZ(1);
            XYZ(x+start+1,y+start+1,2) = lXYZ(2);
            XYZ(x+start+1,y+start+1,3) = lXYZ(3);
            
            lsRGB = XYZ2sRGBD50 * lXYZ';
            sRGB(x+start+1,y+start+1,1) = lsRGB(1);
            sRGB(x+start+1,y+start+1,2) = lsRGB(2);
            sRGB(x+start+1,y+start+1,3) = lsRGB(3);
        end
    end
end

dimensions = size(xyY);
numberOfElements = dimensions(1) * dimensions(2);
Lw = xyY(:,:,3);

logarithms = max(log(Lw), 0);
sumOfLogarithms = sum(sum(logarithms));
Lw_average = exp(sumOfLogarithms / numberOfElements);

% between 0 and 1
a = 0.05;

%Lwhite = max(max(Lw));
Lwhite = 1;
invLwhite = 1.0 / (Lwhite * Lwhite);

L = (a / Lw_average) * Lw;

%Ld = L ./ (L + 1);
Ld = (L .* ((L .* invLwhite) + 1)) ./ (L + 1);

xyY(:,:,3) = Ld;

for y = 1:resolution
    for x = 1:resolution
        v_x = xyY(y,x,1);
        v_y = xyY(y,x,2);
        v_Y = xyY(y,x,3);

        lXYZ = zeros(1,3);
        lXYZ(1) = (v_x / v_y) * v_Y;
        lXYZ(2) = v_Y;
        lXYZ(3) = ((1.0 - v_x - v_y) / v_y) * v_Y;

        XYZ(y,x,1) = lXYZ(1);
        XYZ(y,x,2) = lXYZ(2);
        XYZ(y,x,3) = lXYZ(3);

        lsRGB = XYZ2sRGBD50 * lXYZ';
        sRGB(y,x,1) = lsRGB(1);
        sRGB(y,x,2) = lsRGB(2);
        sRGB(y,x,3) = lsRGB(3);
    end
end

imshow(power(sRGB, 1/2.2));

% lresult = tonemap(sRGB);
% figure
% imshow(lresult);
% 
% mask = (sRGB > 0.0031308);
% sRGB(mask) = ((1.055 * sRGB(mask)) .^ (1 / 2.4)) - 0.055;
% sRGB(~mask) = 12.92 * sRGB(~mask);
% 
% result = tonemap(sRGB);
% figure
% imshow(result);

