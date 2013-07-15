function [z x y dispx dispy gradx grady] = heightfield(resolution, h0area, htildearea, randomnumbers, wind, A, l, time)

h0 = h0_x(resolution, h0area, randomnumbers, wind, A, l);
[htilde x y] = htilde_x(resolution, htildearea, h0, time);

[dispxf dispyf] = freq_spec_disp(resolution, htildearea, htilde);
[gradxf gradyf] = freq_spec_grad(resolution, htildearea, htilde);

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

z = z .* (resolution(1) * resolution(2));
dispx = dispx .* (resolution(1) * resolution(2));
dispy = dispy .* (resolution(1) * resolution(2));
gradx = gradx .* (resolution(1) * resolution(2));
grady = grady .* (resolution(1) * resolution(2));

end