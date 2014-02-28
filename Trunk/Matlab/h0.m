function y = h0(k, knorm, knormalised, randomnumbers, wind, A, l)

%phillipsspectrum = PhillipsSpectrum(k, knorm, knormalised, wind, A, l);
%brakdibrak = UnifiedSpectrum(k, knorm, knormalised, wind, A, l);
%brakdibrak(isnan(brakdibrak)) = 0.0;

pmspectrum = PiersonMoskovitzSpectrum(k, knorm, knormalised, wind, A, l);

%tmp = complex((1/sqrt(2)));
%tmp = tmp.*randomnumbers;
%tmp = tmp.*complex(sqrt(phillipsspectrum));
%tmp = tmp.*complex(sqrt(brakdibrak));
%y = tmp;

y = randomnumbers .* complex(sqrt(pmspectrum));

end

