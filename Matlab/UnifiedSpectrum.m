function y = UnifiedSpectrum(k, knorm, knormalised, wind, A, l)

resolution = size(k);

g = 9.81;

U10 = 12; % wind speed
Omega = 2.0; % inverse wave age

a_0 = log(2) / 4; %eq 59
a_p = 4;          %eq 59
c_m = 0.23;       %eq 59
k_m = 370.0;      %eq 24

kappa = 0.41; % von Karman constant

%eq 24, angular frequency
omega = sqrt(g .* knorm .* (1.0 + (knorm./k_m).*(knorm./k_m)));
% phase velocity, http://en.wikipedia.org/wiki/Phase_velocity
c = omega ./ knorm;
c(isinf(c)) = 0;
c(isnan(c)) = 0;

% spectral peak
% right after eq 3
k_p = g * (Omega / U10) * (Omega / U10);
omega_p = sqrt(g * k_p * (1.0 + (k_p/k_m)*(k_p/k_m)));
c_p = omega_p / k_p;

% friction velocity
% eq 66
z_0 = 3.7e-5 * ((U10*U10)/g) * realpow(U10/c_p, 0.9);
% eq 61, solve for u*
u_star = U10 * kappa / log(10.0/z_0);

% eq 2
L_pm = exp((-5/4).*((k_m ./ knorm).^2));
L_pm(knorm == 0.0) = 0;
% after eq 3
gamma = zeros(resolution(1), resolution(2));
if Omega < 1.0
    gamma(:,:) = 1.7;
else
    gamma(:,:) = 1.7 + 6.0 * log(Omega);
end
% after eq 3
sigma = 0.08 * ( 1.0 + (4.0/(Omega*Omega*Omega)));
% after eq 3
Gamma = exp(((sqrt(knorm ./ k_p) - 1).^2)./(-2*sigma*sigma));
% eq 3
J_p = realpow(gamma, Gamma);
%eq 32
F_p = L_pm .* J_p .* exp((sqrt(knorm ./ k_p) - 1) .* (-Omega/sqrt(10.0)));
% eq 34
alpha_p = 0.006 * sqrt(Omega);
% eq 31
B_l = (0.5 * alpha_p) .* (c_p ./ c) .* F_p;

y = zeros(resolution(1), resolution(2));

end