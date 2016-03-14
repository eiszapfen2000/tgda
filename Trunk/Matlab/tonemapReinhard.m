function [xyY_out, Lw_average] = tonemapReinhard(xyY_in, a, Lwhite, varargin)

Lw_average = -1;
if nargin > 3
    Lw_average = varargin{1};
end

dimensions = size(xyY_in);
numberOfElements = dimensions(1) * dimensions(2);
Lw = xyY_in(:,:,3);

mask = true(size(Lw));
if nargin > 4
    mask = varargin{2};
end

% compute log average luminance
if Lw_average == -1
    logarithms = max(log(Lw(mask) + eps), 0.0);
    sumOfLogarithms = sum(sum(logarithms));
    Lw_average = exp(sumOfLogarithms / numberOfElements);
end

if Lwhite < 0
    Lwhite = max(max(Lw));
end

invLwhite = 1.0 / (Lwhite * Lwhite);

% compute relative luminance
L = (a / Lw_average) * Lw;

% adapt luminance
Ld = (L .* ((L .* invLwhite) + 1)) ./ (L + 1);

% write adapted luminance back into xyY data
xyY_out(:,:,1:2) = xyY_in(:,:,1:2);
xyY_out(:,:,3) = Ld;

end