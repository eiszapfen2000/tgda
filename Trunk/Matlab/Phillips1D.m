function y = Phillips1D(k, wind, A, l)

g = 9.81;
L = dot(wind, wind)/g;
ll = l*L;

k4 = realpow(k,4);
kLsquare = realpow(k.*L,2);
klsquare = realpow(k.*ll,2);

expargument = -1 ./ kLsquare;
expargument(isinf(expargument))=0;
expargument = expargument - klsquare;

Theta = exp(expargument) ./ k4;
Theta(isinf(Theta))=0;
Theta(isnan(Theta))=0;

y = A .* Theta;

end
