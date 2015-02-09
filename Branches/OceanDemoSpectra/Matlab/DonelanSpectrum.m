function [s d] = DonelanSpectrum(k, knorm, wind, fetch)

g = 9.81;
omega = sqrt(knorm * 9.81);
theta = atan2(k(:,:,2), k(:,:,1));
theta_w = atan2(wind(2), wind(1));

[Theta omega_p] = Donelan19851D(omega, wind, fetch, []);

df = DonelanDirectionalFilter(omega, omega_p, theta, theta_w);

kn = knorm;
kn(kn==0) = Inf;
omega(omega==0) = Inf;

Theta_k = Theta .* 0.5 .* (g ./ omega) ./ kn;

s = Theta_k .*df;
d = df;

end
