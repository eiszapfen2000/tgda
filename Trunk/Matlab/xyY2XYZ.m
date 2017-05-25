function XYZ = xyY2XYZ(xyY)

if size(xyY,3) == 3
    x = xyY(:,:,1); y = xyY(:,:,2);
    X = zeros(size(x)); Y = xyY(:,:,3); Z = zeros(size(x));
    nzero = y > 0;
    
    X(nzero) = (x(nzero) ./ y(nzero)) .* Y(nzero);
    Z(nzero) = ((1.0 - (x(nzero) + y(nzero))) ./ y(nzero)) .* Y(nzero);
    
    XYZ(:,:,1) = X; XYZ(:,:,2) = Y; XYZ(:,:,3) = Z;
else
    if size(xyY,2) == 3
        x = xyY(:,1); y = xyY(:,2);
        X = zeros(size(x)); Y = xyY(:,3); Z = zeros(size(x));
        nzero = y > 0;
        
        X(nzero) = (x(nzero) ./ y(nzero)) .* Y(nzero);
        Z(nzero) = ((1.0 - (x(nzero) + y(nzero))) ./ y(nzero)) .* Y(nzero);
        
        XYZ(:,1) = X; XYZ(:,2) = Y; XYZ(:,3) = Z;
    else
        if size(xyY,1) == 3
            x = xyY(1,:); y = xyY(2,:);
            X = zeros(size(x)); Y = xyY(3,:); Z = zeros(size(x));
            nzero = y > 0;

            X(nzero) = (x(nzero) ./ y(nzero)) .* Y(nzero);
            Z(nzero) = ((1.0 - (x(nzero) + y(nzero))) ./ y(nzero)) .* Y(nzero);
            
            XYZ(1,:) = X; XYZ(2,:) = Y; XYZ(3,:) = Z;
        else
            error('Problem?');
        end
    end
end

end