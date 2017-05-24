function writePFM(image, fileName, varargin)
%WRITEPFM Write array to Portable Float Map (PFM).
%	WRITEPFM(IMAGE, FILENAME) takes array provided in IMAGE and writes it
%	to FILENAME in PFM format.
%
%	If IMAGE array is (N x M x 3), the image is considered RGB.
%	If IMAGE array is (N x M), the image is considered grayscale.
%
%	WRITEPFM(..,'PropertyName',PropertyValue) manipulates function
%	characteristics. The different properties are described next:
%
%       Endian
%           {little} | big
%           Defines ordering of the bytes composing each 32-bit floating
%           point value. Windows systems use little-endian ordering, and
%           most UNIX systems use big-endian ordering, for both bytes and
%           bits.
%
%       Comments
%           List of comments, cell array containig in each position one
%           string or comment. Each comment will be placed in the header in
%           consecutive lines.
%
%   More info about PFM can be found on:
%   http://gl.ict.usc.edu/HDRShop/PFM/PFM_Image_File_Format.html
%
%   See also READPFM.

if nargin<2
    error('At least two input arguments expected!');
end

funOpts = setDefaultOpts;
if nargin>2
    funOpts = checkInputArguments(varargin);
end

switch funOpts.Endian
    case 'L'
        byteOrder = -1.0;
        endian = 'ieee-le.l64'; 
    case 'B'
        byteOrder = 1.0;
        endian = 'ieee-be.l64';
    otherwise
        error('Problem?');
end

[imageHeight, imageWidth, nChanels] = size(image);

switch nChanels
    case 3
        % Color Header
        magicValue = 'PF';
        fid = fopen(fileName, 'wb');
        fprintf(fid, '%s\n', magicValue);
        
        for i = 1:numel(funOpts.Comments)
            fprintf(fid, '# %s\n', funOpts.Comments{i});
        end
        
        fprintf(fid, '%d %d\n', imageWidth, imageHeight);
        fprintf(fid, '%f\n', byteOrder);
        
		tmp = zeros(imageHeight, imageWidth*3);
		tmp(:,1:3:end) = image(:,:,1);
		tmp(:,2:3:end) = image(:,:,2);
		tmp(:,3:3:end) = image(:,:,3);
        
        fwrite(fid, flipdim(tmp,1)', 'float32', 0, endian);
        fclose(fid);
        
    case 1
        % Greyscale Header
        magicValue = 'Pf';
        fid = fopen(fileName, 'wb');
        fprintf(fid, '%s\n', magicValue);
        
        for i = 1:numel(funOpts.Comments)
            fprintf(fid, '# %s\n', funOpts.Comments{i});
        end
        
        fprintf(fid, '%d %d\n', imageWidth, imageHeight);
        fprintf(fid, '%f\n', byteOrder);
        fwrite(fid, flipdim(image,1)', 'float32', 0, endian);
        fclose(fid);
        
    otherwise
        error('Image must be RGB (N x M x 3) or Grayscale (N x M)!');
end
return
% =========================================================================
function funOpts = setDefaultOpts
funOpts.Comments = {};
[~,~,funOpts.Endian] = computer;
return
% =========================================================================
function funOpts = checkInputArguments(inputArg)
funOpts = setDefaultOpts;

% propertyName must be followed by propertyValue
if mod(numel(inputArg),2)
    error('Error in property argument.');
end

% function options list: name/class/value
propertyList = {};
propertyList{end+1}.name = 'Comments';
propertyList{end}.valueClass = 'cell';

propertyList{end+1}.name = 'Endian';
propertyList{end}.valueClass = 'char';
propertyList{end}.valueList{1} = 'little';
propertyList{end}.valueList{2} = 'big';

% check for valid property names
propertyFoundIndexList = [];
for ia = 1:2:numel(inputArg)
    propertyFound = false;
    propertyName = inputArg{ia};
    propertyValue = inputArg{ia+1};
    
    for prop_idx = 1:numel(propertyList)
        if isequal(propertyName, propertyList{prop_idx}.name)
            funOpts.(propertyList{prop_idx}.name) = propertyValue;
            propertyFound = true;
            propertyFoundIndexList(end+1) = prop_idx; %#ok
            break;
        end
    end
    if ~propertyFound
        err_txt1 = 'Invalid property found.\n';
        err_txt2 = sprintf('Property Name : ''%s''.', propertyName);
        error(sprintf([err_txt1 err_txt2])); %#ok
    end
end

% check for valid property values
for prop_idx = 1:numel(propertyFoundIndexList)
    
    % ad-hoc : only check valueList for property-name Endian
    if propertyFoundIndexList(prop_idx) ~= 2; continue; end
    
    property = propertyList{propertyFoundIndexList(prop_idx)};
    propertyName = property.name;
    propertyValue = funOpts.(propertyName);
    
    % first check value class, then check if value exists
    valueFound = false;
    if isequal(class(propertyValue), property.valueClass)
        for val_idx = 1:numel(property.valueList)
            if isequal(propertyValue, property.valueList{val_idx})
                valueFound = true;
                break;
            end
        end
    end
    
    if ~valueFound
        err_txt1 = 'Bad property value found.\n';
        err_txt2 = sprintf('Property Name : ''%s''.', propertyName);
        error(sprintf([err_txt1 err_txt2])); %#ok
    end
end

return