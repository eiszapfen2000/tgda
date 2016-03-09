function xyY_out = tonemapReinhard(xyY_in, a, Lwhite)

dimensions = size(xyY_in);
numberOfElements = dimensions(1) * dimensions(2);
Lw = xyY_in(:,:,3);

% compute log average luminance
logarithms = max(log(Lw + eps), 0.0);
sumOfLogarithms = sum(sum(logarithms));
Lw_average = exp(sumOfLogarithms / numberOfElements);

invLwhite = 1.0 / (Lwhite * Lwhite);

% compute relative luminance
L = (a / Lw_average) * Lw;

% adapt luminance
Ld = (L .* ((L .* invLwhite) + 1)) ./ (L + 1);

% write adapted luminance back into xyY data
xyY_out(:,:,1:2) = xyY_in(:,:,1:2);
xyY_out(:,:,3) = Ld;

end