function [xyY_out, Lw_average] = tonemapExp(xyY_in, varargin)

Lw_average = -1;
if nargin > 1
    Lw_average = varargin{1};
end

dimensions = size(xyY_in);
numberOfElements = dimensions(1) * dimensions(2);
Lw = xyY_in(:,:,3);

mask = true(size(Lw));
if nargin > 2
    mask = varargin{2};
end

% compute log average luminance
if Lw_average == -1
    logarithms = max(log(Lw(mask) + eps), 0.0);
    sumOfLogarithms = sum(sum(logarithms));
    Lw_average = exp(sumOfLogarithms / numberOfElements);
end

% adapt luminance
Ld = 1 - exp(-Lw./Lw_average);

% write adapted luminance back into xyY data
xyY_out(:,:,1:2) = xyY_in(:,:,1:2);
xyY_out(:,:,3) = Ld;

end