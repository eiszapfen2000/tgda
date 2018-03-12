function result = ocean_transform(ocean)

for i=1:numel(ocean.lods)
    
    resolution = ocean.lods{i}.resolution;
    
    ocean.lods{i}.gradient_x = 1i .* ocean.lods{i}.k(:,:,1) .* ocean.lods{i}.spectrum;
    ocean.lods{i}.gradient_z = 1i .* ocean.lods{i}.k(:,:,2) .* ocean.lods{i}.spectrum;
    ocean.lods{i}.gradient_x(:,1) = 0;
    ocean.lods{i}.gradient_z(1,:) = 0;
    
    dxTerm = -1i .* ocean.lods{i}.k(:,:,1) ./ ocean.lods{i}.kn;
    dzTerm = -1i .* ocean.lods{i}.k(:,:,2) ./ ocean.lods{i}.kn;
    dxTerm(isnan(dxTerm)) = 0;
    dzTerm(isnan(dzTerm)) = 0;

    ocean.lods{i}.displacement_x = dxTerm .* ocean.lods{i}.spectrum;
    ocean.lods{i}.displacement_z = dzTerm .* ocean.lods{i}.spectrum;
    ocean.lods{i}.displacement_x(:,1) = 0;
    ocean.lods{i}.displacement_z(1,:) = 0;
    
    ocean.lods{i}.displacement_x_x = 1i .* ocean.lods{i}.k(:,:,1) .* ocean.lods{i}.displacement_x;
    ocean.lods{i}.displacement_x_z = 1i .* ocean.lods{i}.k(:,:,2) .* ocean.lods{i}.displacement_x;
    ocean.lods{i}.displacement_z_x = 1i .* ocean.lods{i}.k(:,:,1) .* ocean.lods{i}.displacement_z;
    ocean.lods{i}.displacement_z_z = 1i .* ocean.lods{i}.k(:,:,2) .* ocean.lods{i}.displacement_z;
    ocean.lods{i}.displacement_x_x(:,1) = 0;
    ocean.lods{i}.displacement_x_z(1,:) = 0;
    ocean.lods{i}.displacement_z_x(:,1) = 0;
    ocean.lods{i}.displacement_z_z(1,:) = 0;
    
    ocean.lods{i}.heights = real(ifft2(ifftshift(ocean.lods{i}.spectrum))) .* (resolution^2);
    ocean.lods{i}.gx = real(ifft2(ifftshift(ocean.lods{i}.gradient_x))) .* (resolution^2);
    ocean.lods{i}.gz = real(ifft2(ifftshift(ocean.lods{i}.gradient_z))) .* (resolution^2);
    ocean.lods{i}.dx = real(ifft2(ifftshift(ocean.lods{i}.displacement_x))) .* (resolution^2);
    ocean.lods{i}.dz = real(ifft2(ifftshift(ocean.lods{i}.displacement_z))) .* (resolution^2);
    ocean.lods{i}.dx_x = real(ifft2(ifftshift(ocean.lods{i}.displacement_x_x))) .* (resolution^2);
    ocean.lods{i}.dx_z = real(ifft2(ifftshift(ocean.lods{i}.displacement_x_z))) .* (resolution^2);
    ocean.lods{i}.dz_x = real(ifft2(ifftshift(ocean.lods{i}.displacement_z_x))) .* (resolution^2);
    ocean.lods{i}.dz_z = real(ifft2(ifftshift(ocean.lods{i}.displacement_z_z))) .* (resolution^2);

    
%     gradient_x = 1i .* ocean.lods(i).k(:,:,1) .* ocean.lods(i).h_tilde;
%     gradient_z = 1i .* ocean.lods(i).k(:,:,2) .* ocean.lods(i).h_tilde;
%     gradient_x(:,1) = 0;
%     gradient_z(1,:) = 0;
%     gradient_xz = gradient_x + (1i.*gradient_z);
%     
%     gradient_x
%     gradient_z
%     gradient_xz
%     
%     gx = ifft2(ifftshift(gradient_x)) .* (resolution^2);
%     gz = ifft2(ifftshift(gradient_z)) .* (resolution^2);
%     
%     gxz = ifft2(ifftshift(gradient_xz)) .* (resolution^2);
%     
%     gx
%     gz
%     gxz
%     
%     lolz = ocean.lods(i).gx;
%     lalz = ocean.lods(i).gz;
%     
%     lolz
%     lalz
end

result = ocean;

end

function y = derivative_x(resolution, area, kx, spectrum)
k_to_zero = (resolution/2) * 2 * pi / area;
correction = ~(kx == k_to_zero);
spectrum_x = 1i .* kx .* spectrum;
y = correction .* spectrum_x;
end