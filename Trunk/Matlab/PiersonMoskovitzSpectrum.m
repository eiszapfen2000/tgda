function y = PiersonMoskovitzSpectrum(k, knorm, knormalised, wind, A, l)

g = 9.81;
alpha = 0.0081;
U = norm(wind);

omega_p = 0.877 * g / U;
omega = sqrt(knorm * 9.81);
theta = atan2(k(:,:,2), k(:,:,1));
theta_w = atan2(wind(2), wind(1));

kn = knorm;

kn(kn==0) = Inf;
omega(omega==0) = Inf;

d = DirectionalFilter(omega, omega_p, theta, theta_w);

exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent);

Theta_k = Theta .* 0.5 .* (g ./ omega) ./ kn;

y = Theta_k .* d;

end