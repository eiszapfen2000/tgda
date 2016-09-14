function y = PhillipsSpectrumDirectionalTerm(k, knormalised, exponent, wind)

resolution = size(k);

windnorm = norm(wind,2);
windnormalised = wind./windnorm;

wtmp = zeros(resolution(1), resolution(2),2);
wtmp(:,:,1) = windnormalised(1);
wtmp(:,:,2) = windnormalised(2);
kdotw = dot(knormalised, wtmp, 3);
kdotw = realpow(abs(kdotw), exponent);

y = kdotw;