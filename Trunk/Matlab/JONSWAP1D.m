function y = JONSWAP1D(omega, wind, fetch, scale)

g = 9.81;
U10 = norm(wind);

X = g * fetch / (U10^2);
alpha = 0.076 * (X^(-0.22));
Omega_c = 22 * (X^(-0.33));
omega_p = Omega_c * g / U10;

alpha = alpha .* scale.alphaScale;
omega_p = omega_p .* scale.wpScale;

sigma = zeros(size(omega));
sigma(omega <= omega_p) = 0.07;
sigma(omega > omega_p) = 0.09;

if scale.sigma ~= 0
    sigma = scale.sigma;
end

r_exponent = ((omega-omega_p).^2)./(2.*(sigma.^2).*(omega_p^2));
r = exp(-r_exponent);
gamma_r = 3.3 .^ r;

if scale.gamma ~= 0
    gamma_r = scale.gamma;
end

omega(omega==0) = Inf;
exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent) .* gamma_r;

y = Theta;

end