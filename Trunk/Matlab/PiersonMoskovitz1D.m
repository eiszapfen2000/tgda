function y = PiersonMoskovitz1D(omega, wind)

g = 9.81;
alpha = 0.0081;
U = norm(wind);
omega_p = 0.855 * g / U;

omega(omega==0) = Inf;

exponent = (-5/4) .* power(omega_p ./ omega, 4.0);
Theta = ((alpha*g*g) ./ power(omega, 5.0)) .* exp(exponent);

y = Theta;

end