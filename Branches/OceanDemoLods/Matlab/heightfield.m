function [z x y dispx dispy gradx grady] = heightfield(geometryRes, gradientRes, h0area, htildearea, randomnumbers, wind, A, l, time)

geometryResLog2 = log2(geometryRes);
gradientResLog2 = log2(gradientRes);

[ ige fge ] = modf(geometryResLog2);
[ igr fgr ] = modf(gradientResLog2);

if ~isequal(fge, zeros(1,2)) || ~isequal(fgr, zeros(1,2))
    error('Resolution not power of 2');
end

rnRes = size(randomnumbers);
if ~isequal(gradientRes, rnRes)
    error('Res mismatch');
end

deltaRes = gradientRes - geometryRes;
halfDeltaRes = deltaRes ./ 2;

geometryRN = randomnumbers(1+halfDeltaRes(2):end-halfDeltaRes(2),1+halfDeltaRes(1):end-halfDeltaRes(1));
gradientRN = randomnumbers;

h0_geometry = h0_x(geometryRes, h0area, geometryRN, wind, A, l);
h0_gradient = h0_x(gradientRes, h0area, gradientRN, wind, A, l);

[htilde_geometry x y] = htilde_x(geometryRes, htildearea, h0_geometry, time);
htilde_gradient = htilde_x(gradientRes, htildearea, h0_gradient, time);

[dispxf dispyf] = freq_spec_disp(geometryRes, htildearea, htilde_geometry);
[gradxf gradyf] = freq_spec_grad(gradientRes, htildearea, htilde_gradient);

htilde_geometry = ifftshift(htilde_geometry);
dispxf = ifftshift(dispxf);
dispyf = ifftshift(dispyf);
gradxf = ifftshift(gradxf);
gradyf = ifftshift(gradyf);

z = real(ifft2(htilde_geometry));
dispx = real(ifft2(dispxf));
dispy = real(ifft2(dispyf));
gradx = real(ifft2(gradxf));
grady = real(ifft2(gradyf));

z = z .* (geometryRes(1) * geometryRes(2));
dispx = dispx .* (geometryRes(1) * geometryRes(2));
dispy = dispy .* (geometryRes(1) * geometryRes(2));
gradx = gradx .* (gradientRes(1) * gradientRes(2));
grady = grady .* (gradientRes(1) * gradientRes(2));

end