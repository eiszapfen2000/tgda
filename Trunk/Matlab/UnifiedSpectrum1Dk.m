function y = UnifiedSpectrum1Dk(k, wind, fetch)

g = 9.81;

U10 = norm(wind); % wind speed

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
omega = sqrt(g .* k .* (1.0 + (k./k_m).*(k./k_m)));
% phase velocity, http://en.wikipedia.org/wiki/Phase_velocity
c = omega ./ k;
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
L_pm = exp((-5/4).*((k_p ./ k).^2));
L_pm(k == 0.0) = 0;
% after eq 3
gamma = zeros(size(k));
if Omega_c < 1.0
    gamma(:,:) = 1.7;
else
    gamma(:,:) = 1.7 + 6.0 * log10(Omega_c);
end
% after eq 3
sigma = 0.08 * (1.0 + (4.0/(Omega_c^3)));
% after eq 3
Gamma = exp(((sqrt(k ./ k_p) - 1).^2)./(-2*sigma*sigma));
% eq 3
J_p = realpow(gamma, Gamma);
%eq 32
F_p = L_pm .* J_p .* exp((sqrt(k ./ k_p) - 1) .* (-Omega_c/sqrt(10.0)));
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
% eq 41
F_m = exp(-0.25 .* (((k./k_m) - 1).^2));
% eq 40
B_h = zeros(size(k));
B_h = (0.5 * alpha_m) .* (c_m ./ c) .* F_m;
%B_h(k <= 0.01) = 0;
B_h(isinf(B_h)) = 0;
B_h(isnan(B_h)) = 0;
% ADD TERMS MISSING IN PAPER
B_h = B_h .* L_pm .* J_p;

ik = (k.^(-3));
ik(isinf(ik)) = 0;
ik(isnan(ik)) = 0;

y = ik.*(B_l + B_h);

end