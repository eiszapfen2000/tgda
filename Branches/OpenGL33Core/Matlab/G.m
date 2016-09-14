function x = G(P, n, deltaQ)

G0 = G_zero(n, deltaQ);

kernelSize = 2 * P + 1;
result = zeros(kernelSize);

q = deltaQ:deltaQ:n*deltaQ;
qSquare = q.*q;

for l=-P:1:P
    for k=-P:1:P
        r = sqrt(l.*l + k.*k);
        b = besselj(0, r.*q);
        powers = exp(-1 * qSquare);
        scalars = qSquare .* powers .* b;
        result(l + P + 1, k + P + 1) = sum(scalars) / G0;
    end
end

x = result;

end