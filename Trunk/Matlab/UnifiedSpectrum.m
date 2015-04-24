function [y du] = UnifiedSpectrum(k, knorm, wind, fetch)

g = 9.81;

resolution = size(k);

U10 = norm(wind); % wind speed

a_0 = log(2) / 4; %eq 59
a_p = 4;          %eq 59
c_m = 0.23;       %eq 59
k_0 = g/(U10^2);  %between eq 3 and 4
k_m = 370.0;      %eq 24
X_0 = 2.2 * 10^4; %eq 37

kappa = 0.41; % von Karman constant

%eq 4, dimensionless fetch
X = k_0 * fetch;
%eq 37, inverse wave age
Omega_c = 0.84 * tanh((X/X_0)^0.4)^(-0.75);

%eq 24, angular frequency
omega = sqrt(g .* knorm .* (1.0 + (knorm./k_m).*(knorm./k_m)));
% phase velocity, http://en.wikipedia.org/wiki/Phase_velocity
c = omega ./ knorm;
c(isinf(c)) = 0;
c(isnan(c)) = 0;

% spectral peak
% right after eq 3
k_p = k_0 * (Omega_c ^ 2);
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
gamma = 0;
if Omega_c < 1.0
    gamma = 1.7;
else
    gamma = 1.7 + 6.0 * log10(Omega_c);
end
% after eq 3
sigma = 0.08 * (1.0 + (4.0/(Omega_c^3)));
% after eq 3
Gamma = exp(((sqrt(knorm ./ k_p) - 1).^2)./(-2*sigma*sigma));
% eq 3
J_p = realpow(gamma, Gamma);
%eq 32
F_p = L_pm .* J_p .* exp((sqrt(knorm ./ k_p) - 1) .* (-Omega_c/sqrt(10.0)));
% eq 34
alpha_p = 0.006 * sqrt(Omega_c);
% eq 31
B_l = (0.5 * alpha_p) .* (c_p ./ c) .* F_p;
B_l(isinf(B_l)) = 0;
B_l(isnan(B_l)) = 0;

% eq 44
alpha_m = 0;
if u_star < c_m
    alpha_m = 0.01 * (1.0 + log(u_star/c_m));
else
    alpha_m = 0.01 * (1.0 + 3.0 * log(u_star/c_m));
end
% eq 41, ADD TERMS MISSING IN PAPER
F_m = L_pm .* J_p .* exp(-0.25 .* (((knorm./k_m) - 1).^2));
% eq 40
B_h = (0.5 * alpha_m) .* (c_m ./ c) .* F_m;
B_h(isinf(B_h)) = 0;
B_h(isnan(B_h)) = 0;

% eq 59
a_m = 0.13 * (u_star ./ c_m);
% eq 57
delta_k = tanh(a_0 + a_p.*realpow((c./c_p), 2.5) + a_m.*realpow((c_m./c), 2.5));

% compute angle relative to the wind
theta_w = atan2(wind(2), wind(1));
theta = atan2(k(:,:,2), k(:,:,1));
phi = theta - theta_w;

% eq 67
Psi = (1/(2*pi)) .* (1./(knorm.^4)) .* (B_l + B_h) .* (1 + delta_k .* cos(2.*phi));
Psi(isinf(Psi)) = 0;
Psi(isnan(Psi)) = 0;

du = (1/(2*pi)) .* (1 + delta_k .* cos(2.*phi));
du(isinf(du)) = 0;
du(isnan(du)) = 0;

y = Psi;

end