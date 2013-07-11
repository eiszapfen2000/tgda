function y = PhillipsSpectrum(k, knorm, knormalised, wind, l)

resolution = size(k);

g = 9.81;
L = dot(wind, wind)/g;

windnorm = norm(wind,2);
windnormalised = wind./windnorm;

phillipsconstant = 0.0081;

wtmp = zeros(resolution(1), resolution(2),2);
wtmp(:,:,1) = windnormalised(1);
wtmp(:,:,2) = windnormalised(2);
kdotw = dot(knormalised, wtmp, 3);
kdotw = realpow(abs(kdotw),2);

knorm4 = realpow(knorm,4);
tmpknorm4 = zeros(resolution(1), resolution(2));
tmpknorm4 = tmpknorm4 + knorm4;

Ltmp = zeros(resolution(1), resolution(2));
Ltmp = Ltmp + L;
kLsquare = realpow(knorm.*Ltmp,2);
klsquare = realpow(knorm.*l, 2);
minusone = zeros(resolution(1), resolution(2));
minusone = minusone - 1;
expargument = minusone./kLsquare;
expargument(find(isinf(expargument)))=0;
expargument = expargument - klsquare;
expargument = exp(expargument);
expargument = expargument./tmpknorm4;
expargument(find(isinf(expargument)))=0;

y = zeros(resolution(1), resolution(2));
y = y + phillipsconstant;
y = y.*expargument;
y = y.*kdotw;
