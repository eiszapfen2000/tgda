function y = h0(k, knorm, knormalised, randomnumbers, wind, A, l)

phillipsspectrum = PhillipsSpectrum(k, knorm, knormalised, wind, A, l);

tmp = complex((1/sqrt(2)));
tmp = tmp.*randomnumbers;
tmp = tmp.*complex(sqrt(phillipsspectrum));
y = tmp;
