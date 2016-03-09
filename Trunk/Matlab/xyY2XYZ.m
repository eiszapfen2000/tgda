function XYZ = xyY2XYZ(xyY)

XYZ = zeros(size(xyY));
XYZ(:,:,1) = (xyY(:,:,1) ./ xyY(:,:,2)) .* xyY(:,:,3);
XYZ(:,:,2) = xyY(:,:,3);
XYZ(:,:,3) = ((1.0 - xyY(:,:,1) - xyY(:,:,2)) ./ xyY(:,:,2)) .* xyY(:,:,3);

end