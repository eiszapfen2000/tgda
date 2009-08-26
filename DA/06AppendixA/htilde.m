function y = htilde(k, knorm, knormalised, wind, time)

g = 9.81;

resolution = size(knorm);
gaussrandr = normrnd(0, 1, resolution(1), resolution(2));
gaussrandi = normrnd(0, 1, resolution(1), resolution(2));
gaussrand = complex(gaussrandr, gaussrandi);

omega = sqrt(knorm.*g);
expomega = exp(i.*omega.*time);
expminusomega = exp(-i.*omega.*time);

hzero = h0(k, knorm, knormalised, gaussrand, wind);
result = zeros(resolution(1), resolution(2));

for x=1:resolution(1)
    for y=1:resolution(2)
        index1 = mod(resolution(1)-x+1,resolution(1))+1;
        index2 = mod(resolution(2)-y+1,resolution(2))+1;
        result(x,y) = hzero(x,y)*expomega(x,y) + conj(hzero(index1, index2))*expminusomega(index1, index2);
    end
end

y = result;
