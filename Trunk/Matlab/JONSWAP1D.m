function y = JONSWAP1D(omega, wind, fetch, parameters)

g = 9.81;

alphaScale = 1;
wpScale = 1;
fixed_gamma_r = 0;
fixed_sigma = 0;
fixed_omega_p = 0;
fixed_omega_c = 0;

if isfield(parameters, 'alphaScale') && isnumeric(parameters.alphaScale)
    alphaScale = parameters.alphaScale;
end

if isfield(parameters, 'wpScale') && isnumeric(parameters.wpScale)
    wpScale = parameters.wpScale;
end

if isfield(parameters, 'gamma_r') && isnumeric(parameters.gamma_r)
    fixed_gamma_r = parameters.gamma_r;
end

if isfield(parameters, 'sigma') && isnumeric(parameters.sigma)
    fixed_sigma = parameters.sigma;
end

if isfield(parameters, 'wp') && isnumeric(parameters.wp)...
   && isfield(parameters, 'wc') && isnumeric(parameters.wc)
    fixed_omega_p = parameters.wp;
    fixed_omega_c = parameters.wc;
end

alpha = 0;
omega_p = 0;

if fixed_omega_p == 0 && fixed_omega_c == 0
    U10 = norm(wind);
    X = g * fetch / (U10^2);
    alpha = 0.076 * (X^(-0.22));
    Omega_c = 22 * (X^(-0.33));
    omega_p = Omega_c * g / U10;
    alpha = alpha .* alphaScale;
    omega_p = omega_p .* wpScale;
else
    U10 = fixed_omega_c * g / fixed_omega_p;
    X = nthroot(fixed_omega_c / 22, -0.33);
    alpha = 0.076 * (X^(-0.22));
    Omega_c = fixed_omega_c;
    omega_p = fixed_omega_p;
end

sigma = zeros(size(omega));
sigma(omega <= omega_p) = 0.07;
sigma(omega > omega_p) = 0.09;

if fixed_sigma ~= 0
    sigma = fixed_sigma;
end

r_exponent = ((omega-omega_p).^2)./(2.*(sigma.^2).*(omega_p^2));
r = exp(-r_exponent);
gamma_r = 3.3 .^ r;

if fixed_gamma_r ~= 0
    gamma_r = fixed_gamma_r;
end

omega(omega==0) = Inf;
exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent) .* gamma_r;

y = Theta;

end