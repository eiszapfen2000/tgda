function sRGB = lsRGB2sRGB(lsRGB)

% convert to non-linear sRGB 
sRGB = lsRGB;
mask = (sRGB > 0.0031308);
sRGB(mask) = 1.055 * (sRGB(mask) .^ (1 / 2.4)) - 0.055;
sRGB(~mask) = 12.92 * sRGB(~mask);

if max(max(max(lsRGB))) > 1
    error('Linear RGB values not in range [0,1]');
end

end