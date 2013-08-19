function [z x y dispx dispy gradx grady] = heightfield(geometryRes, gradientRes, h0area, htildearea, randomnumbers, wind, A, l, time)

h0 = h0_x(geometryRes, h0area, randomnumbers, wind, A, l);
[htilde x y] = htilde_x(geometryRes, htildearea, h0, time);

[dispxf dispyf] = freq_spec_disp(geometryRes, htildearea, htilde);
[gradxf gradyf] = freq_spec_grad(geometryRes, htildearea, htilde);

htilde = ifftshift(htilde);
dispxf = ifftshift(dispxf);
dispyf = ifftshift(dispyf);
gradxf = ifftshift(gradxf);
gradyf = ifftshift(gradyf);

z = real(ifft2(htilde));
dispx = real(ifft2(dispxf));
dispy = real(ifft2(dispyf));
gradx = real(ifft2(gradxf));
grady = real(ifft2(gradyf));

z = z .* (geometryRes(1) * geometryRes(2));
dispx = dispx .* (geometryRes(1) * geometryRes(2));
dispy = dispy .* (geometryRes(1) * geometryRes(2));
gradx = gradx .* (geometryRes(1) * geometryRes(2));
grady = grady .* (geometryRes(1) * geometryRes(2));

end