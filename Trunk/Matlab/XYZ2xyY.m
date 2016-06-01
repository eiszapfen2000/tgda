function xyY = XYZ2xyY(XYZ, varargin)

if nargin > 1
    wp_XYZ = varargin{1};
else
    wp_XYZ = whitepoint('D65');
end

wp_x = wp_XYZ(1) / sum(wp_XYZ);
wp_y = wp_XYZ(2) / sum(wp_XYZ);

if size(XYZ,3) == 3
    X = XYZ(:,:,1); Y = XYZ(:,:,2); % Z = XYZ(:,:,3);
    x = ones(size(X)).*wp_x; y = ones(size(X)).*wp_y;
    s = sum(XYZ,3);
    nz = s > 0;
    
    x(nz) = X(nz) ./ s(nz);
    y(nz) = Y(nz) ./ s(nz);
    
    xyY(:,:,1) = x; xyY(:,:,2) = y; xyY(:,:,3) = Y;    
else
    if size(XYZ,2) == 3
        X = XYZ(:,1); Y = XYZ(:,2); % Z = XYZ(:,3);
        x = ones(size(X)).*wp_x; y = ones(size(X)).*wp_y;
        s = sum(XYZ,2);
        nz = s > 0;

        x(nz) = X(nz) ./ s(nz);
        y(nz) = Y(nz) ./ s(nz);

        xyY(:,1) = x; xyY(:,2) = y; xyY(:,3) = Y; 
    else
        if size(XYZ,1) == 3
            X = XYZ(1,:); Y = XYZ(2,:); % Z = XYZ(3,:);
            x = ones(size(X)).*wp_x; y = ones(size(X)).*wp_y;
            s = sum(XYZ,1);
            nz = s > 0;

            x(nz) = X(nz) ./ s(nz);
            y(nz) = Y(nz) ./ s(nz);

            xyY(1,:) = x; xyY(2,:) = y; xyY(3,:) = Y; 
        else
            error('Problem?');
        end
    end
end

end