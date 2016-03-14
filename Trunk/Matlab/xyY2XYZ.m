function XYZ = xyY2XYZ(xyY)

if size(xyY,3) == 3
    XYZ(:,:,1) = (xyY(:,:,1) ./ xyY(:,:,2)) .* xyY(:,:,3);
    XYZ(:,:,2) = xyY(:,:,3);
    XYZ(:,:,3) = ((1.0 - xyY(:,:,1) - xyY(:,:,2)) ./ xyY(:,:,2)) .* xyY(:,:,3);
else
    if size(xyY,2) == 3
        XYZ(:,1) = (xyY(:,1) ./ xyY(:,2)) .* xyY(:,3);
        XYZ(:,2) = xyY(:,3);
        XYZ(:,3) = ((1.0 - xyY(:,1) - xyY(:,2)) ./ xyY(:,2)) .* xyY(:,3);
    else
        if size(xyY,1) == 3
            XYZ(1,:) = (xyY(1,:) ./ xyY(2,:)) .* xyY(3,:);
            XYZ(2,:) = xyY(3,:);
            XYZ(3,:) = ((1.0 - xyY(1,:) - xyY(2,:)) ./ xyY(2,:)) .* xyY(3,:);
        else
            error('Problem?');
        end
    end
end

end