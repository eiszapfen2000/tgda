function [x, z, deltax, deltay] = generate_xz(resolution, area)

alphas = ceil(-resolution/2): 1:ceil( resolution/2)-1;
betas  = floor( resolution/2):-1:floor(-resolution/2)+1;
deltax = area / resolution;
deltay = area / resolution;

% spatial domain
[ x, z ] = meshgrid(alphas.*deltax, betas.*deltay);

end