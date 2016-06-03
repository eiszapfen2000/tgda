function writeimage(image)

ppi2meters = ceil((96 / 2.54) * 100);
outputFilename = strcat(inputname(1), '.png');
imwrite(image, outputFilename, 'ResolutionUnit', 'meter',...
    'XResolution', ppi2meters, 'YResolution', ppi2meters);

end