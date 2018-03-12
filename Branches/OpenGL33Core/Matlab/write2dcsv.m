function write2dcsv(xaxis, yaxis, varargin)

optargin = size(varargin,2);

output = [xaxis', yaxis'];

outputFilename = strcat(inputname(2), '.dat');
if optargin > 0
    outputFilename = varargin{1};
end

csvwrite(outputFilename, output);

end