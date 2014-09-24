function y = Donelan19851Dk(k, wind, fetch)

g = 9.81;
omega = sqrt(k * g);

Theta = Donelan19851D(omega, wind, fetch, []);

omega(omega==0) = Inf;
Theta_k = Theta .* 0.5 .* (g ./ omega);

y = Theta_k;

end