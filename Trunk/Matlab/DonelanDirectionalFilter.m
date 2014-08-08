function y = DonelanDirectionalFilter(omega, omega_p, theta, theta_w)

ratio = omega ./ omega_p;

p_p = 2.61 .* power(ratio,  1.3);
n_p = 2.28 .* power(ratio, -1.3);

betas = zeros(size(omega));
betas = betas + 1.24;
betas(ratio > 0.56 & ratio < 0.95) = p_p(ratio > 0.56 & ratio < 0.95);
betas(ratio > 0.95 & ratio < 1.6)  = n_p(ratio > 0.95 & ratio < 1.6);

df = sech(betas .* (theta-theta_w));
df = 0.5 .* betas .* (df.^2);

y = df;

end