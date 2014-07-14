function y = Donelan19851D(omega, wind, fetch, parameters)

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

% non dimensional fetch X = g * fetch / (U10*U10)
% non dimensional peak frequency v = f_p * U10 / g
% f_p = v * g / U10
% w_p = 2 * pi * f_p

% Omega_c = U10 / C_p = 11.6 * X^-0.23
% v = 1.85 * X^-0.23
% U10 / C_p = 2 *pi * v

alpha = 0;
Omega_c = 0;
omega_p = 0;

if fixed_omega_p == 0 && fixed_omega_c == 0
    U10 = norm(wind);
    X = g * fetch / (U10^2);
    Omega_c = 11.6 * (X^(-0.23));
    % Omega_c = max(min(Omega_c, 5), 0.83);
    alpha = 0.006 * (Omega_c^(0.55));
    omega_p = Omega_c * g / U10;
    alpha = alpha .* alphaScale;
    omega_p = omega_p .* wpScale;
else
    U10 = fixed_omega_c * g / fixed_omega_p;
    X = nthroot(fixed_omega_c / 11.6, -0.23);
    alpha = 0.006 * (fixed_omega_c^(0.55));
    Omega_c = fixed_omega_c;
    omega_p = fixed_omega_p;
end

sigma = 0.08 * (1 + (4/(Omega_c^3)));

if fixed_sigma ~= 0
    sigma = fixed_sigma;
end

gamma_base = 0.0;
if Omega_c < 1 
    gamma_base = 1.7;
else
    gamma_base = 1.7 + 6 * log10(Omega_c);
end

r_exponent = ((omega-omega_p).^2)./(2*(sigma^2)*(omega_p^2));
r = exp(-r_exponent);
gamma_r = gamma_base .^ r;

if fixed_gamma_r ~= 0
    gamma_r = fixed_gamma_r;
end

omega(omega==0) = Inf;
exponent = -power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ (power(omega, 4.0) .* omega_p)) .* exp(exponent) .* gamma_r;

y = Theta;

end