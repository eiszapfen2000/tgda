
ross = {};
% ross{end+1} = '07-02-2018_15-45-22_ross.pfm'; %PM
% ross{end+1} = '07-02-2018_15-45-27_ross.pfm'; %JONSWAP
% ross{end+1} = '07-02-2018_15-45-34_ross.pfm'; %DONELAN
% ross{end+1} = '07-02-2018_15-45-39_ross.pfm'; %UNIFIED

ross{end+1} = '07-02-2018_15-45-22_complete.pfm'; %PM
ross{end+1} = '07-02-2018_15-45-27_complete.pfm'; %JONSWAP
ross{end+1} = '07-02-2018_15-45-34_complete.pfm'; %DONELAN
ross{end+1} = '07-02-2018_15-45-39_complete.pfm'; %UNIFIED

% lsRGB_ross = readPFM(ross{1});
% xyY_ross = XYZ2xyY(lsRGB2XYZ(lsRGB_ross));
% [~, Lw_average] = tonemapReinhard(xyY_ross, 0.18, -1);


for r=1:numel(ross)
    filename = ross{r};
    lsRGB_ross = readPFM(filename);
    xyY_ross = XYZ2xyY(lsRGB2XYZ(lsRGB_ross));
    xyY_tonemapped_ross = tonemapReinhard(xyY_ross, 0.18, 10);
    sRGB_tonemapped_ross = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_tonemapped_ross)));
    
    [~,base] = fileparts(filename);
    imwrite(sRGB_tonemapped_ross,[base '.png']);
end