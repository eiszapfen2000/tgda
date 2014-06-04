function y = JONSWAP1Dk(k, wind, fetch)

g = 9.81;
omega = sqrt(k * g);

scale = [];
scale.alphaScale = 1;
scale.wpScale = 1;
scale.sigma = 0;
scale.gamma = 0;

Theta = JONSWAP1D(omega, wind, fetch, scale);
Theta_k = Theta .* 0.5 .* (g ./ omega);

y = Theta_k;

end