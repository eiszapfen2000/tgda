function xyY = XYZ2xyY(XYZ)

if size(XYZ,3) == 3
    xyY(:,:,1) = XYZ(:,:,1) ./ sum(XYZ,3);
    xyY(:,:,2) = XYZ(:,:,2) ./ sum(XYZ,3);
    xyY(:,:,3) = XYZ(:,:,2);
else
    if size(XYZ,2) == 3
        xyY(:,1) = XYZ(:,1) ./ sum(XYZ,2);
        xyY(:,2) = XYZ(:,2) ./ sum(XYZ,2);
        xyY(:,3) = XYZ(:,2);
    else
        if size(XYZ,1) == 3
            xyY(1,:) = XYZ(1,:) ./ sum(XYZ,1);
            xyY(2,:) = XYZ(2,:) ./ sum(XYZ,1);
            xyY(3,:) = XYZ(2,:);
        else
            error('Problem?');
        end
    end
end

end