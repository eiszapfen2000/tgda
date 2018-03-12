function x = digamma(thetaAngle, gammaAngle, coefficients)

cosTheta = cos(thetaAngle);
cosGamma = cos(gammaAngle);

term_one = 1.0 + coefficients(1).*exp(coefficients(2)./cosTheta);
term_two = 1.0 + coefficients(3).*exp(coefficients(4).*gammaAngle) + coefficients(5).*(cosGamma.^2);

x = term_one .* term_two;

end