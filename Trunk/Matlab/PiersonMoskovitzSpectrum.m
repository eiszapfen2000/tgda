function [s d] = PiersonMoskovitzSpectrum(k, knorm, wind)

g = 9.81;

omega = sqrt(knorm * 9.81);
theta = atan2(k(:,:,2), k(:,:,1));
theta_w = atan2(wind(2), wind(1));

[Theta omega_p] = PiersonMoskovitz1D(omega, wind, []);
df = DirectionalFilter(omega, omega_p, theta, theta_w);

kn = knorm;
kn(kn==0) = Inf;
omega(omega==0) = Inf;

Theta_k = Theta .* 0.5 .* (g ./ omega) ./ kn;

s = Theta_k .* df;
d = df;

end