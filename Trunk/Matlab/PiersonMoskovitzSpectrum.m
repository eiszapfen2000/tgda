function [s d] = PiersonMoskovitzSpectrum(k, knorm, wind)

g = 9.81;
alpha = 0.0081;
U = norm(wind);

omega_p = 0.877 * g / U;
omega = sqrt(knorm * 9.81);
theta = atan2(k(:,:,2), k(:,:,1));
theta_w = atan2(wind(2), wind(1));

df = DirectionalFilter(omega, omega_p, theta, theta_w);

kn = knorm;
kn(kn==0) = Inf;
omega(omega==0) = Inf;

exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent);

Theta_k = Theta .* 0.5 .* (g ./ omega) ./ kn;

s = Theta_k .* df;
d = df;

end