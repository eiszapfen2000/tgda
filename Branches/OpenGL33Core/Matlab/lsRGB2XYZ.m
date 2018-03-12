function XYZ = lsRGB2XYZ(lsRGB, varargin)

%
% http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
%
XYZ2sRGBD65 = [...
    3.2404542 -1.5371385 -0.4985314;...
    -0.9692660  1.8760108  0.0415560;...
    0.0556434 -0.2040259  1.0572252;...
    ];

sRGBD652XYZ = inv(XYZ2sRGBD65);

if nargin > 1
    conversionMatrix = varargin{1};
else
    conversionMatrix = sRGBD652XYZ;
end

if size(lsRGB,3) == 3
    lsRGB_vectors(1,:) = reshape(lsRGB(:,:,1), 1, numel(lsRGB(:,:,1)));
    lsRGB_vectors(2,:) = reshape(lsRGB(:,:,2), 1, numel(lsRGB(:,:,2)));
    lsRGB_vectors(3,:) = reshape(lsRGB(:,:,3), 1, numel(lsRGB(:,:,3)));

    XYZ_vectors = conversionMatrix * lsRGB_vectors;

    XYZ(:,:,1) = reshape(XYZ_vectors(1,:), size(lsRGB,1), []);
    XYZ(:,:,2) = reshape(XYZ_vectors(2,:), size(lsRGB,1), []);
    XYZ(:,:,3) = reshape(XYZ_vectors(3,:), size(lsRGB,1), []);
else
	if size(lsRGB,2) == 3
		lsRGB_vectors(1,:) = reshape(lsRGB(:,1), 1, numel(lsRGB(:,1)));
		lsRGB_vectors(2,:) = reshape(lsRGB(:,2), 1, numel(lsRGB(:,2)));
		lsRGB_vectors(3,:) = reshape(lsRGB(:,3), 1, numel(lsRGB(:,3)));
		
		XYZ_vectors = conversionMatrix * lsRGB_vectors;
		
		XYZ(:,1) = reshape(XYZ_vectors(1,:), size(lsRGB,1), []);
		XYZ(:,2) = reshape(XYZ_vectors(2,:), size(lsRGB,1), []);
		XYZ(:,3) = reshape(XYZ_vectors(3,:), size(lsRGB,1), []);
	else
		if size(lsRGB,1) == 3
			XYZ = conversionMatrix * lsRGB;
		else
			error('Problem?');
		end
	end
end
end
