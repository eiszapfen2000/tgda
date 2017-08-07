filename_prefix = '31-07-2017_10-47-08';
filename_complete = [ filename_prefix '_complete' ];
filename_ross = [ filename_prefix '_ross' ];
filename_sea = [ filename_prefix '_sea' ];
filename_sky = [ filename_prefix '_sky' ];
filename_whitecaps = [ filename_prefix '_whitecaps' ];

lsRGB_complete = readPFM([filename_complete '.pfm']);
lsRGB_ross = readPFM([filename_ross '.pfm']);
lsRGB_sea = readPFM([filename_sea '.pfm']);
lsRGB_sky = readPFM([filename_sky '.pfm']);
lsRGB_whitecaps = readPFM([filename_whitecaps '.pfm']);

xyY_complete = XYZ2xyY(lsRGB2XYZ(lsRGB_complete));
xyY_ross = XYZ2xyY(lsRGB2XYZ(lsRGB_ross));
xyY_sea = XYZ2xyY(lsRGB2XYZ(lsRGB_sea));
xyY_sky = XYZ2xyY(lsRGB2XYZ(lsRGB_sky));
xyY_whitecaps = XYZ2xyY(lsRGB2XYZ(lsRGB_whitecaps));

xyY_tonemapped_complete = tonemapReinhard(xyY_complete, 0.18, -1);
xyY_tonemapped_ross = tonemapReinhard(xyY_ross, 0.18, -1);
xyY_tonemapped_sea = tonemapReinhard(xyY_sea, 0.18, -1);
xyY_tonemapped_sky = tonemapReinhard(xyY_sky, 0.18, -1);
xyY_tonemapped_whitecaps = tonemapReinhard(xyY_whitecaps, 0.18, -1);

sRGB_tonemapped_complete = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_tonemapped_complete)));
sRGB_tonemapped_ross = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_tonemapped_ross)));
sRGB_tonemapped_sea = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_tonemapped_sea)));
sRGB_tonemapped_sky = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_tonemapped_sky)));
sRGB_tonemapped_whitecaps = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_tonemapped_whitecaps)));

imwrite(sRGB_tonemapped_complete,[filename_complete '.png']);
imwrite(sRGB_tonemapped_ross,[filename_ross '.png']);
imwrite(sRGB_tonemapped_sea,[filename_sea '.png']);
imwrite(sRGB_tonemapped_sky,[filename_sky '.png']);
imwrite(sRGB_tonemapped_whitecaps,[filename_whitecaps '.png']);