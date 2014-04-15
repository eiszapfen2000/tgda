function y = JONSWAP1Dk(k, wind, fetch)

g = 9.81;
omega = sqrt(k * g);

Theta = JONSWAP1D(omega, wind, fetch);
Theta_k = Theta .* 0.5 .* (g ./ omega);

y = Theta_k;

end