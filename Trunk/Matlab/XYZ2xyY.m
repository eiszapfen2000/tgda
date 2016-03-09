function xyY = XYZ2xyY(XYZ)

xyY(:,:,1) = XYZ(:,:,1) ./ sum(XYZ,3);
xyY(:,:,2) = XYZ(:,:,2) ./ sum(XYZ,3);
xyY(:,:,3) = XYZ(:,:,2);

end