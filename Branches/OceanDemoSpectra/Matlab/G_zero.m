function x = G_zero(n, deltaQ)

q = deltaQ:deltaQ:n*deltaQ;
qSquare = q.*q;
powers = exp(-1 * qSquare);
scalars = qSquare .* powers;
x = sum(scalars);

end