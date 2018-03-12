clear variables
%close all

XYZ2sRGBD50 = [...
    3.1338561 -1.6168667 -0.4906146;...
    -0.9787684  1.9161415  0.0334540;...
    0.0719453 -0.2289914  1.4052427...
    ];

XYZ2sRGBD65 = [...
    3.2404542 -1.5371385 -0.4985314;...
    -0.9692660  1.8760108  0.0415560;...
    0.0556434 -0.2040259  1.0572252;...
    ];

turbidity = 2.0;
thetaSun = 0 * (pi / 180);
phiSun = -pi/2;

resolution = 1025;
preetham_xyY_turbidity_2_thetaSun_0  = preethamSky(resolution, phiSun,  0 * (pi / 180), 2.0);
preetham_xyY_turbidity_2_thetaSun_30 = preethamSky(resolution, phiSun, 30 * (pi / 180), 2.0);
preetham_xyY_turbidity_2_thetaSun_60 = preethamSky(resolution, phiSun, 60 * (pi / 180), 2.0);
preetham_xyY_turbidity_2_thetaSun_90 = preethamSky(resolution, phiSun, 90 * (pi / 180), 2.0);
preetham_xyY_turbidity_4_thetaSun_0  = preethamSky(resolution, phiSun,  0 * (pi / 180), 4.0);
preetham_xyY_turbidity_4_thetaSun_30 = preethamSky(resolution, phiSun, 30 * (pi / 180), 4.0);
preetham_xyY_turbidity_4_thetaSun_60 = preethamSky(resolution, phiSun, 60 * (pi / 180), 4.0);
preetham_xyY_turbidity_4_thetaSun_90 = preethamSky(resolution, phiSun, 90 * (pi / 180), 4.0);
preetham_xyY_turbidity_6_thetaSun_0  = preethamSky(resolution, phiSun,  0 * (pi / 180), 6.0);
preetham_xyY_turbidity_6_thetaSun_30 = preethamSky(resolution, phiSun, 30 * (pi / 180), 6.0);
preetham_xyY_turbidity_6_thetaSun_60 = preethamSky(resolution, phiSun, 60 * (pi / 180), 6.0);
preetham_xyY_turbidity_6_thetaSun_90 = preethamSky(resolution, phiSun, 90 * (pi / 180), 6.0);

preetham_sRGB_D65_turbidity_2_thetaSun_0  = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_0,  0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_2_thetaSun_30 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_30, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_2_thetaSun_60 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_60, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_2_thetaSun_90 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_90, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D50_turbidity_2_thetaSun_0  = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_0,  0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_2_thetaSun_30 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_30, 0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_2_thetaSun_60 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_60, 0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_2_thetaSun_90 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_2_thetaSun_90, 0.18, -1)),XYZ2sRGBD50));

preetham_sRGB_D65_turbidity_4_thetaSun_0  = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_0,  0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_4_thetaSun_30 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_30, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_4_thetaSun_60 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_60, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_4_thetaSun_90 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_90, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D50_turbidity_4_thetaSun_0  = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_0,  0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_4_thetaSun_30 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_30, 0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_4_thetaSun_60 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_60, 0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_4_thetaSun_90 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_4_thetaSun_90, 0.18, -1)),XYZ2sRGBD50));

preetham_sRGB_D65_turbidity_6_thetaSun_0  = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_0,  0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_6_thetaSun_30 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_30, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_6_thetaSun_60 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_60, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D65_turbidity_6_thetaSun_90 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_90, 0.18, -1)),XYZ2sRGBD65));
preetham_sRGB_D50_turbidity_6_thetaSun_0  = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_0,  0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_6_thetaSun_30 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_30, 0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_6_thetaSun_60 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_60, 0.18, -1)),XYZ2sRGBD50));
preetham_sRGB_D50_turbidity_6_thetaSun_90 = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(preetham_xyY_turbidity_6_thetaSun_90, 0.18, -1)),XYZ2sRGBD50));

writeimage(preetham_sRGB_D65_turbidity_2_thetaSun_0);
writeimage(preetham_sRGB_D65_turbidity_2_thetaSun_30);
writeimage(preetham_sRGB_D65_turbidity_2_thetaSun_60);
writeimage(preetham_sRGB_D65_turbidity_2_thetaSun_90);
writeimage(preetham_sRGB_D50_turbidity_2_thetaSun_0);
writeimage(preetham_sRGB_D50_turbidity_2_thetaSun_30);
writeimage(preetham_sRGB_D50_turbidity_2_thetaSun_60);
writeimage(preetham_sRGB_D50_turbidity_2_thetaSun_90);

writeimage(preetham_sRGB_D65_turbidity_4_thetaSun_0);
writeimage(preetham_sRGB_D65_turbidity_4_thetaSun_30);
writeimage(preetham_sRGB_D65_turbidity_4_thetaSun_60);
writeimage(preetham_sRGB_D65_turbidity_4_thetaSun_90);
writeimage(preetham_sRGB_D50_turbidity_4_thetaSun_0);
writeimage(preetham_sRGB_D50_turbidity_4_thetaSun_30);
writeimage(preetham_sRGB_D50_turbidity_4_thetaSun_60);
writeimage(preetham_sRGB_D50_turbidity_4_thetaSun_90);

writeimage(preetham_sRGB_D65_turbidity_6_thetaSun_0);
writeimage(preetham_sRGB_D65_turbidity_6_thetaSun_30);
writeimage(preetham_sRGB_D65_turbidity_6_thetaSun_60);
writeimage(preetham_sRGB_D65_turbidity_6_thetaSun_90);
writeimage(preetham_sRGB_D50_turbidity_6_thetaSun_0);
writeimage(preetham_sRGB_D50_turbidity_6_thetaSun_30);
writeimage(preetham_sRGB_D50_turbidity_6_thetaSun_60);
writeimage(preetham_sRGB_D50_turbidity_6_thetaSun_90);

% imwrite(tonemapped_preetham_xyY_thetaSun_90, 'brak.png');
% blub = imread('brak.png');
% figure
% imshow(blub);
% % [xyY, mask, irradiancexyY, s_xyY, nix, nux] = preethamSky(resolution, phiSun, thetaSun, turbidity);
% blub = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(tonemapReinhard(xyY, 0.18, -1))));
% figure;
% imshow(blub);

% x_c = xyY(:,:,1);
% y_c = xyY(:,:,2);
% Y_c = xyY(:,:,3);
% 
% irradianceXYZ = xyY2XYZ(irradiancexyY);
% irradianceXYZ(1) = 0.17 * (irradianceXYZ(1) / pi);
% irradianceXYZ(2) = 0.17 * (irradianceXYZ(2) / pi);
% irradianceXYZ(3) = 0.17 * (irradianceXYZ(3) / pi);
% irradiancexyY = XYZ2xyY(irradianceXYZ);
% 
% x_c(mask) = s_xyY(1);
% y_c(mask) = s_xyY(2);
% Y_c(mask) = s_xyY(3);
% 
% xyYirr(:,:,1) = x_c;
% xyYirr(:,:,2) = y_c;
% xyYirr(:,:,3) = Y_c;
% 
% % tonemapping
% a = 0.18;
% Lwhite = 2;
% [xyY, Lw_average] = tonemapReinhard(xyY, a, Lwhite);
% [xyYirr, Lw_average] = tonemapReinhard(xyYirr, a, Lwhite);
% 
% % convert xyY to XYZ
% XYZ = xyY2XYZ(xyY);
% XYZirr = xyY2XYZ(xyYirr);
% 
% % convert XYZ to linear sRGB
% sRGB = XYZ2lsRGB(XYZ);
% sRGBirr = XYZ2lsRGB(XYZirr);
% 
% % convert from linear sRGB to sRGB
% sRGB = lsRGB2sRGB(sRGB);
% sRGBirr = lsRGB2sRGB(sRGBirr);
% 
% figure
% imshow(sRGB);
% 
% figure
% imshow(sRGBirr);

