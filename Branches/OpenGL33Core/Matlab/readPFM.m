function [image, comments] = readPFM(filename)
%READPFM Read array from Portable Float Map (PFM).
%	IMAGE = READPFM(FILENAME) reads PFM format file specified in FILENAME
%	and ouputs it to array IMAGE.
%
%   [IMAGE, COMMENTS] = READPFM(FILENAME) returns all comments found in
%   the PFM header as a cell array in output variable COMMENTS.
%
%   More info about PFM can be found on:
%   http://gl.ict.usc.edu/HDRShop/PFM/PFM_Image_File_Format.html
%
%   See also WRITEPFM.

magicValueColor = 'PF';
magicValueGrey = 'Pf';

fid = fopen(filename);

% read header
magicValue = fgetl(fid);
if ~isequal(magicValue, magicValueColor) && ...
        ~isequal(magicValue, magicValueGrey)
    error('Wrong PFM format! Invalid MagicValue found!');
end

% look for comments
comments = {};
commentsSeekFinished = false;
line = fgetl(fid);
while ~commentsSeekFinished
    hashPosition = strfind(line,'# ');
    if hashPosition == 1
        % comment exists, grab the line
        comments{end+1} = line(3:end); %#ok
        % read the next line
        line = fgetl(fid);
    else
        % no more comments, finish search
        commentsSeekFinished = true;
    end
end

% read image size
try
    % note : the line we already have from the comments loop
    [imageWidth imageHeight] = strread(line, '%d %d');
catch %#ok
    error('Wrong PFM format! Invalid image size found!');
end

% read the byteOrder
try
    byteOrder = strread(fgetl(fid), '%f'); 
catch %#ok
    error('Wrong PFM format! Invalid byteOrder found!');
end


% provide machine format

if byteOrder <= 0
    endian = 'ieee-le.l64';
else
    endian = 'ieee-be.l64';
end

% grab the image and close file handle
data = fread(fid, inf, 'float32', 0, endian);
fclose(fid);

switch magicValue
    case magicValueColor
        
        % check size
        if size(data,1) == 3 * (imageWidth * imageHeight),
            
            redIndices = 1 : 3 : size(data, 1);
            red = data(redIndices);
            green = data(redIndices + 1);
            blue = data(redIndices + 2);
            
            % transpose image
            image = zeros(imageHeight, imageWidth, 3);
            image(:,:,1) = reshape(red, imageWidth, imageHeight)';
            image(:,:,2) = reshape(green, imageWidth, imageHeight)';
            image(:,:,3) = reshape(blue, imageWidth, imageHeight)';
			% flip bottom to top
			image = flipdim(image, 1);
        else
            error('File size and image dimensions mismatched!');
        end
        
    case magicValueGrey
        
        % check size
        if size(data,1) == (imageWidth * imageHeight)
            image(:,:) = flipdim(reshape(data, imageWidth, imageHeight)',1);
        else
            error('File size and image dimensions mismatched!');
        end
        
    otherwise
        error('Invalid file header!');
end
