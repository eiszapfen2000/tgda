function y = PiersonMoskovitz1Dk(k, wind)

g = 9.81;
omega = sqrt(k * g);

Theta = PiersonMoskovitz1D(omega, wind, []);
Theta_k = Theta .* 0.5 .* (g ./ omega);

y = Theta_k;

end