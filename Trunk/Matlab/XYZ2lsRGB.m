function lsRGB = XYZ2lsRGB(XYZ, varargin)

lsRGB = [];
conversionMatrix = [];
XYZ2sRGBD50 = [3.1338561 -1.6168667 -0.4906146; -0.9787684  1.9161415  0.0334540; 0.0719453 -0.2289914  1.4052427];

if nargin > 1
    conversionMatrix = varargin{1};
else
    conversionMatrix = XYZ2sRGBD50;
end

if size(XYZ,3) == 3
    XYZ_vectors(1,:) = reshape(XYZ(:,:,1), 1, numel(XYZ(:,:,1)));
    XYZ_vectors(2,:) = reshape(XYZ(:,:,2), 1, numel(XYZ(:,:,2)));
    XYZ_vectors(3,:) = reshape(XYZ(:,:,3), 1, numel(XYZ(:,:,3)));

    lsRGB_vectors = conversionMatrix * XYZ_vectors;

    lsRGB(:,:,1) = reshape(lsRGB_vectors(1,:), size(XYZ,1), []);
    lsRGB(:,:,2) = reshape(lsRGB_vectors(2,:), size(XYZ,1), []);
    lsRGB(:,:,3) = reshape(lsRGB_vectors(3,:), size(XYZ,1), []);
else
    error('Problem?');
end
end