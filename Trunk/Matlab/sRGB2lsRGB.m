function lsRGB = sRGB2lsRGB(sRGB)

lsRGB = sRGB ./ 255;

mask = (lsRGB > 0.04045);
lsRGB(mask) = ((lsRGB(mask) + 0.055)./1.055) .^ 2.4;
lsRGB(~mask) = lsRGB(~mask) ./ 12.92;

end