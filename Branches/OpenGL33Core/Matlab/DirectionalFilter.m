function y = DirectionalFilter(omega, omega_p, theta, theta_w)

s_p = zeros(size(omega));
s_p(omega >= omega_p) = 9.77;
s_p(omega < omega_p) = 6.97;

g_p = power(omega ./ omega_p, -2.5);
l_p = power(omega ./ omega_p, 5);

s_g_p = g_p .* s_p;
s_l_p = l_p .* s_p;

s = zeros(size(omega));
s(omega >= omega_p) = s_g_p(omega >= omega_p);
s(omega < omega_p) = s_l_p(omega < omega_p);

cos_theta_half = abs(cos((theta - theta_w)./ 2));
term_three = power(cos_theta_half, 2 .* s);

gamma_num = gamma(s + 1) .^ 2;
gamma_den = gamma(2.*s + 1);

term_two = gamma_num ./ gamma_den;

exponent_s = 2.*s - 1;
term_one = power(2, exponent_s) ./ pi;

d = term_one .* term_two .* term_three;

y = d;

end