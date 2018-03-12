function sRGB = lsRGB2sRGB(lsRGB)

% input may be outside the nominal range [0...1]
mask = (lsRGB < 0);

% clamp negative values to zero
if any(mask)
	lsRGB(mask) = 0;
end

% if values are larger than 1, rescale
max_lsRGB = max(max(max(lsRGB)));

if (max_lsRGB > 1)
	lsRGB = lsRGB ./ max_lsRGB;
end

% convert to non-linear sRGB 
sRGB = lsRGB;
mask = (sRGB > 0.0031308);
sRGB(mask) = 1.055 * (sRGB(mask) .^ (1 / 2.4)) - 0.055;
sRGB(~mask) = 12.92 * sRGB(~mask);

% convert to uint8 0...255
sRGB = uint8(sRGB .* 255);
end