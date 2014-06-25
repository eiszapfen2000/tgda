function y = Donelan19851D(omega, wind, fetch, scale)

g = 9.81;
U10 = norm(wind);

% non dimensional fetch X = g * fetch / (U10*U10)
% non dimensional peak frequency v = f_p * U10 / g
% f_p = v * g / U10
% w_p = 2 * pi * f_p

% Omega_c = U10 / C_p = 11.6 * X^-0.23
% v = 1.85 * X^-0.23
% U10 / C_p = 2 *pi * v

X = g * fetch / (U10^2);
Omega_c = 11.6 * (X^(-0.23));
Omega_c = max(min(Omega_c, 5), 0.83);

alpha = 0.006 * (Omega_c^(0.55));
omega_p = Omega_c * g / U10;

alpha = alpha .* scale.alphaScale;
omega_p = omega_p .* scale.wpScale;

sigma = 0.08 * (1 + (4/(Omega_c^3)));

if scale.sigma ~= 0
    sigma = scale.sigma;
end

gamma_base = 0.0;
if Omega_c < 1 
    gamma_base = 1.7;
else
    gamma_base = 1.7 + 6 * log(Omega_c);
end

r_exponent = -((omega-omega_p).^2)./(2.*(sigma.^2).*(omega_p^2));
r = exp(r_exponent);
gamma_r = gamma_base .^ r;

if scale.gamma ~= 0
    gamma_r = scale.gamma;
end

omega(omega==0) = Inf;
exponent = -power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ (power(omega, 4.0) .* omega_p)) .* exp(exponent) .* gamma_r;

y = Theta;

end