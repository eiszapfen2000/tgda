function y = h0(k,knorm,knormalised,randomnumbers,wind)

phillipsspectrum = PhillipsSpectrum(k,knorm,knormalised,wind);

tmp = complex((1/sqrt(2)));
tmp = tmp.*randomnumbers;
tmp = tmp.*randomnumbers.*complex(sqrt(phillipsspectrum));
y = tmp;