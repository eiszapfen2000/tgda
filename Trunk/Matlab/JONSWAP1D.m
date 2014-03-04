function y = JONSWAP1D(omega, wind, fetch)

g = 9.81;
U = norm(wind);

alpha = 0.076 * power((U^2) / (fetch*g), 0.22);
omega_p = 22 * power((g*g) / (U*fetch), 1/3);

sigma = zeros(size(omega));
sigma(omega <= omega_p) = 0.07;
sigma(omega > omega_p) = 0.09;

r_exponent = ((omega-omega_p).^2)./(2.*(sigma.^2).*(omega_p^2));
r = exp(-r_exponent);
gamma_r = 3.3 .^ r;

omega(omega==0) = Inf;
exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent) .* gamma_r;

y = Theta;

end