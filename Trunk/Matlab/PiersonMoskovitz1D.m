function y = PiersonMoskovitz1D(omega, wind, parameters)

g = 9.81;

alphaScale = 1;
wpScale = 1;
wp = 0;

if isfield(parameters, 'alphaScale') && isnumeric(parameters.alphaScale)
alphaScale = parameters.alphaScale;
end

if isfield(parameters, 'wpScale') && isnumeric(parameters.wpScale)
wpScale = parameters.wpScale;
end

if isfield(parameters, 'wp') && isnumeric(parameters.wp)
wp = parameters.wp;
end

alpha = 0.0081 * alphaScale;
U = norm(wind);
omega_p = (0.855 * g / U) * wpScale;

if wp ~= 0
    omega_p = wp;
end

omega(omega==0) = Inf;

exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent);

y = Theta;

end