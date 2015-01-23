function result = ocean_transform(ocean)

for i=1:numel(ocean.lods)
    
    resolution = ocean.lods(i).resolution;
    
    spectrum_shifted = ifftshift(ocean.lods(i).spectrum);
    h_tilde_shifted = ifftshift(ocean.lods(i).h_tilde);

    z1 = real(ifft2(spectrum_shifted));
    z2 = real(ifft2(h_tilde_shifted));
    z1 = z1 .* (resolution * resolution);
    z2 = z2 .* (resolution * resolution);

end

result = ocean;

end