function result = ocean_animate(ocean, time)

g = 9.81;

for i=1:numel(ocean.lods)
    omega = sqrt(ocean.lods{i}.kn * g);
    expomega = exp(1i.*omega.*time);
    expminusomega = exp(-1i.*omega.*time);
    
    ocean.lods{i}.spectrum = ...
        1/sqrt(2) .* ocean.lods{i}.randomNumbers .* ...
        complex(ocean.lods{i}.amplitudes) .* expminusomega;
    
    ocean.lods{i}.h_zero = ...
        1/sqrt(2) .* ocean.lods{i}.randomNumbers .* ...
        complex(ocean.lods{i}.amplitudes ./ 2);
    
    resolution = ocean.lods{i}.resolution;
    ocean.lods{i}.h_tilde = zeros(resolution, resolution);
    
    for x=1:resolution
        for y=1:resolution
            index1 = mod(resolution-x+1,resolution)+1;
            index2 = mod(resolution-y+1,resolution)+1;
            ocean.lods{i}.h_tilde(x,y) = ...
                (ocean.lods{i}.h_zero(x,y)*expminusomega(x,y)) ...
                + (conj(ocean.lods{i}.h_zero(index1, index2)) ...
                * expomega(index1, index2));
        end
    end

end

result = ocean;

end