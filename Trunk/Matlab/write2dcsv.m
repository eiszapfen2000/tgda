function write2dcsv(xaxis, yaxis)

output = [xaxis', yaxis'];
outputFilename = strcat(inputname(2), '.dat');

csvwrite(outputFilename, output);

end