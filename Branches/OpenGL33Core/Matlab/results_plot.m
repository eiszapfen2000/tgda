function results_plot()
%%
filename_prefix = fullfile('N:', 'TG', '28-05-2018_10-56-10');
results_tonemap(filename_prefix);
end

function results_tonemap(filename_prefix)
%%
filename_complete = [ filename_prefix '_complete' ];
filename_grid = [ filename_prefix '_grid' ];
filename_ross = [ filename_prefix '_ross' ];
filename_sea = [ filename_prefix '_sea' ];
filename_sky = [ filename_prefix '_sky' ];
filename_whitecaps = [ filename_prefix '_whitecaps' ];

result_tonemap(filename_complete);
result_tonemap(filename_grid);
result_tonemap(filename_ross);
result_tonemap(filename_sea);
result_tonemap(filename_sky);
result_tonemap(filename_whitecaps);

end

function result_tonemap(basename)
%%
lsRGB_im = readPFM([basename '.pfm']);
xyY_im = XYZ2xyY(lsRGB2XYZ(lsRGB_im));
xyY_im_tonemapped = tonemapReinhard(xyY_im, 0.18, -1);
sRGB_im_tonemapped = lsRGB2sRGB(XYZ2lsRGB(xyY2XYZ(xyY_im_tonemapped)));
imwrite(sRGB_im_tonemapped,[basename '.png']);
end