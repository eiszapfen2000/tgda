function write2dcsv(xaxis, yaxis)

fprintf('%s %s', inputname(1), inputname(2));

output = [xaxis', yaxis'];
outputFilename = strcat(inputname(2), '.dat');

csvwrite(outputFilename, output);

end