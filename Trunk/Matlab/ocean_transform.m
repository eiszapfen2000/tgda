function result = ocean_transform(ocean)

for i=1:numel(ocean.lods)
    
    resolution = ocean.lods(i).resolution;
    
    ocean.lods(i).gradient_x = 1i .* ocean.lods(i).k(:,:,1) .* ocean.lods(i).spectrum;
    ocean.lods(i).gradient_z = 1i .* ocean.lods(i).k(:,:,2) .* ocean.lods(i).spectrum;
    ocean.lods(i).gradient_x(:,1) = 0;
    ocean.lods(i).gradient_z(1,:) = 0;
    
    dxTerm = -1i .* ocean.lods(i).k(:,:,1) ./ ocean.lods(i).kn;
    dzTerm = -1i .* ocean.lods(i).k(:,:,2) ./ ocean.lods(i).kn;
    dxTerm(isnan(dxTerm)) = 0;
    dzTerm(isnan(dzTerm)) = 0;

    ocean.lods(i).displacement_x = dxTerm .* ocean.lods(i).spectrum;
    ocean.lods(i).displacement_z = dzTerm .* ocean.lods(i).spectrum;
    ocean.lods(i).displacement_x(:,1) = 0;
    ocean.lods(i).displacement_z(1,:) = 0;
    
    ocean.lods(i).displacement_x_x = 1i .* ocean.lods(i).k(:,:,1) .* ocean.lods(i).displacement_x;
    ocean.lods(i).displacement_x_z = 1i .* ocean.lods(i).k(:,:,2) .* ocean.lods(i).displacement_x;
    ocean.lods(i).displacement_z_x = 1i .* ocean.lods(i).k(:,:,1) .* ocean.lods(i).displacement_z;
    ocean.lods(i).displacement_z_z = 1i .* ocean.lods(i).k(:,:,2) .* ocean.lods(i).displacement_z;
    ocean.lods(i).displacement_x_x(:,1) = 0;
    ocean.lods(i).displacement_x_z(1,:) = 0;
    ocean.lods(i).displacement_z_x(:,1) = 0;
    ocean.lods(i).displacement_z_z(1,:) = 0;
    
    ocean.lods(i).heights = real(ifft2(ifftshift(ocean.lods(i).spectrum))) .* (resolution^2);
    ocean.lods(i).gx = real(ifft2(ifftshift(ocean.lods(i).gradient_x))) .* (resolution^2);
    ocean.lods(i).gz = real(ifft2(ifftshift(ocean.lods(i).gradient_z))) .* (resolution^2);
    ocean.lods(i).dx = real(ifft2(ifftshift(ocean.lods(i).displacement_x))) .* (resolution^2);
    ocean.lods(i).dz = real(ifft2(ifftshift(ocean.lods(i).displacement_z))) .* (resolution^2);
    
end

result = ocean;

end