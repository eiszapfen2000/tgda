function y = JONSWAPSpectrum(k, knorm, knormalised, wind, A, l)

g = 9.81;
U = norm(wind);
fetch = 100000;

alpha = 0.076 * power((U^2) / (fetch*g), 0.22);
omega_p = 22 * power((g*g) / (U*fetch), 1/3);

omega = sqrt(knorm * 9.81);
theta = atan2(k(:,:,2), k(:,:,1));
theta_w = atan2(wind(2), wind(1));

sigma = zeros(size(omega));
sigma(omega <= omega_p) = 0.07;
sigma(omega > omega_p) = 0.09;

r_exponent = ((omega-omega_p).^2)./(2.*(sigma.^2).*(omega_p^2));
r = exp(-r_exponent);
gamma_r = 3.3 .^ r;

kn = knorm;
kn(kn==0) = Inf;
omega(omega==0) = Inf;

d = DirectionalFilter(omega, omega_p, theta, theta_w);

exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent) .* gamma_r;

Theta_k = Theta .* (1./(2.*kn)) .* (g./omega);
%Theta_k = Theta .* 0.5 .* (g ./ omega) ./ kn;

y = Theta_k .* d;

end