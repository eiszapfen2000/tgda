function [y kp] = PiersonMoskovitz1Dk(k, wind, parameters)

g = 9.81;
omega = sqrt(k * g);

fixed_k_p = 0;

if isfield(parameters, 'kp') && isnumeric(parameters.kp)
    fixed_k_p = parameters.kp;
end

if fixed_k_p ~= 0
    parameters.wp = sqrt(fixed_k_p * g);
end

[Theta wp] = PiersonMoskovitz1D(omega, wind, parameters);

omega(omega==0) = Inf;
Theta_k = Theta .* 0.5 .* (g ./ omega);

y = Theta_k;
kp = (wp * wp) / g;

end