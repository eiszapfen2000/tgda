function y = PiersonMoskovitzSpectrum(k, knorm, knormalised, wind, A, l)

g = 9.81;
alpha = 0.0081;
U = norm(wind);

omega_p = 0.877 * g / U;
omega = sqrt(knorm * 9.81);
theta = atan2(k(:,:,2), k(:,:,1));

d = DirectionalFilter(omega, omega_p, theta);

% s_p = zeros(size(omega));
% s_p(omega >= omega_p) = 9.77;
% s_p(omega < omega_p) = 6.97;
% 
% g_p = power(omega ./ omega_p, -2.5);
% l_p = power(omega ./ omega_p, 5);
% g_p(isinf(g_p))=0;
% l_p(isinf(l_p))=0;
% 
% s_g_p = g_p .* s_p;
% s_l_p = l_p .* s_p;
% 
% s = zeros(size(omega));
% s(omega >= omega_p) = s_g_p(omega >= omega_p);
% s(omega < omega_p) = s_l_p(omega < omega_p);
% 
% theta_half = theta ./ 2;
% cos_theta_half = abs(cos(theta_half));
% pow_cos = power(cos_theta_half, 2 .* s);
% 
% gamma_num = gamma(s + 1) .^ 2;
% gamma_den = gamma(2.*s + 1);
% 
% g_n_d = gamma_num ./ gamma_den;
% g_n_d(isinf(g_n_d))=0;
% g_n_d(isnan(g_n_d))=0;
% 
% exponent_s = 2.*s - 1;
% brak = power(2, exponent_s) ./ pi;
% 
% d = brak .* g_n_d .* pow_cos;

exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
exponent(isinf(exponent))=0;

Theta = (alpha*g*g) ./ power(omega, 5.0) .* exp(exponent);
Theta(isinf(Theta))=0;

Theta_k = Theta .* 0.5 .* (g ./ omega) ./ knorm;
Theta_k(isinf(Theta_k))=0;
Theta_k(isnan(Theta_k))=0;

y = Theta_k .* d;

end