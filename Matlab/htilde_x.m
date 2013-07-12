function [z x y] = htilde_x(resolution, area, hzero, time)

tmpm  = -resolution(1)/2:1:resolution(1)/2-1;
tmpn  =  resolution(2)/2-1:-1:-resolution(2)/2;
tmpms =  tmpm.*(2*pi)./area(1);
tmpns =  tmpn.*(2*pi)./area(2);

k = zeros(resolution(1), resolution(2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(tmpms, tmpns);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);

omega = sqrt(knorm.*9.81);
expomega = exp(1i.*omega.*time);
expminusomega = exp(-1i.*omega.*time);

z = zeros(resolution(1), resolution(2));

for x=1:resolution(1)
    for y=1:resolution(2)
        index1 = mod(resolution(1)-x+1,resolution(1))+1;
        index2 = mod(resolution(2)-y+1,resolution(2))+1;
        z(x,y) = hzero(x,y)*expomega(x,y) + conj(hzero(index1, index2))*expminusomega(index1, index2);
    end
end

tmpx = tmpm .* area(1);
tmpx = tmpx ./ resolution(1);
x = repmat(tmpx, resolution(2), 1);

tmpy = tmpn .* area(2);
tmpy = tmpy ./ resolution(2);
y = repmat(tmpy', 1, resolution(1));

