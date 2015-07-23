function [ outimage ] = imnormalize( inimage )

d = double(inimage);
minU = min(min(d));
maxU = max(max(d));

outimage = ( d - minU ) ./ (maxU - minU);

end

