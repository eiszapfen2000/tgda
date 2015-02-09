function y = UnifiedDirectionalFilter(k, k, theta, theta_w)

g = 9.81;

a_0 = log(2) / 4; %eq 59
a_p = 4;          %eq 59
c_m = 0.23;       %eq 59
k_m = 370.0;      %eq 24

kappa = 0.41; % von Karman constant

% phase velocity, http://en.wikipedia.org/wiki/Phase_velocity
c = omega ./ k;
c(isinf(c)) = 0;
c(isnan(c)) = 0;

omega_p = sqrt(g * k_p * (1.0 + (k_p/k_m)*(k_p/k_m)));
c_p = omega_p / k_p;

% friction velocity
% eq 66
z_0 = 3.7e-5 * ((U10*U10)/g) * realpow(U10/c_p, 0.9);
% eq 61, solve for u* with z=10.0
u_star = U10 * kappa / log(10.0/z_0);

% eq 59
a_m = 0.13 .* (u_star ./ c_m);
% eq 57
delta_k = tanh(a_0 + a_p.*realpow((c./c_p), 2.5) + a_m.*realpow((c_m./c), 2.5));
y = (1/(2*pi)) .* (1 + delta_k .* cos(2.*phi));
end