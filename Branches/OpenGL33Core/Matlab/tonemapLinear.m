function [xyY_out, Lw_max] = tonemapLinear(xyY_in, varargin)

Lw_max = -1;
if nargin > 1
    Lw_max = varargin{1};
end

Lw = xyY_in(:,:,3);

mask = true(size(Lw));
if nargin > 2
    mask = varargin{2};
end

% compute max luminance
if Lw_max == -1
    Lw_max = max(max(Lw(mask)));
end

% adapt luminance
Ld = Lw ./ Lw_max;

% write adapted luminance back into xyY data
xyY_out(:,:,1:2) = xyY_in(:,:,1:2);
xyY_out(:,:,3) = Ld;

end