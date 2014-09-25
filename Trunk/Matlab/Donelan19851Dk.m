function [y kp] = Donelan19851Dk(k, wind, fetch, parameters)

g = 9.81;
omega = sqrt(k * g);

fixed_k_p = 0;

if isfield(parameters, 'kp') && isnumeric(parameters.kp)
    fixed_k_p = parameters.kp;
end

if fixed_k_p ~= 0
    parameters.wp = sqrt(fixed_k_p * g);
end

[Theta wp] = Donelan19851D(omega, wind, fetch, parameters);

omega(omega==0) = Inf;
Theta_k = Theta .* 0.5 .* (g ./ omega);

y = Theta_k;
kp = (wp * wp) / g;

end