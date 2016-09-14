function [x z deltax deltay] = generate_xz(resolution, area)

x = zeros(resolution, resolution);
z = zeros(resolution, resolution);

alphas = -resolution/2:1:resolution/2-1;
betas  =  resolution/2:-1:-(resolution/2)+1;
deltax = area / resolution;
deltay = area / resolution;

% spatial domain
[ x z ] = meshgrid(alphas.*deltax, betas.*deltay);

end