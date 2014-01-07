function y = UnifiedSpectrum(k, knorm, knormalised, wind, A, l)

resolution = size(k);

g = 9.81;

U10 = 10; % wind speed
Omega = 12.0; % inverse wave age

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
% eq 61, solve for u* with z=10.0
u_star = U10 * kappa / log(10.0/z_0);

% eq 2
L_pm = exp((-5/4).*((k_p ./ knorm).^2));
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
B_l(isinf(B_l)) = 0;
B_l(isnan(B_l)) = 0;

% eq 44
alpha_m = 0;
if u_star < c_m
    alpha_m = 0.01 * (1.0 + max(-1.0, log(u_star/c_m)));
else
    alpha_m = 0.01 * (1.0 + max(-1.0, 3.0 * log(u_star/c_m)));
end
% eq 41
F_m = exp(-0.25 .* (((knorm./k_m) - 1).^2));
% eq 40
B_h = (0.5 * alpha_m) .* (c_m ./ c) .* F_m;
B_h(isinf(B_h)) = 0;
B_h(isnan(B_h)) = 0;

% eq 59
a_m = 0.13 .* (u_star ./ c_m);
% eq 57
delta_k = tanh(a_0 + a_p.*realpow((c./c_p), 2.5) + a_m.*realpow((c_m./c), 2.5));
% eq 67
phi = atan2(k(:,:,2), k(:,:,1));
Psi = (1/(2*pi)) .* (1./(knorm.^4)) .* (B_l + B_h) .* (1 + delta_k .* cos(2.*phi));
Psi(isinf(Psi)) = 0;
Psi(isnan(Psi)) = 0;

y = Psi;

end