function [ outimages ] = imrelnormalize( inimages )

if ~iscell(inimages)
    outimages = imnormalize(inimages);
    return;
end

globalMin =  realmax();
globalMax = -realmax();
outimages = cell(size(inimages));

for i=1:numel(inimages)
    localMin = min(min(inimages{i}));
    localMax = max(max(inimages{i}));
    globalMin = min([globalMin localMin]);
    globalMax = max([globalMax localMax]);
    
    outimages{i} = double(inimages{i}) - localMin;
end

for i=1:numel(outimages)
    outimages{i} = outimages{i} ./ (globalMax - globalMin);
end

end

