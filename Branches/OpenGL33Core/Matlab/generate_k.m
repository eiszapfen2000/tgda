function [k, kn, deltakx, deltaky] = generate_k(resolution, area)

k = zeros(resolution, resolution, 2);

alphas = ceil(-resolution/2): 1:ceil( resolution/2)-1;
betas  = floor( resolution/2):-1:floor(-resolution/2)+1;
deltakx = 2*pi / area;
deltaky = 2*pi / area;

% wave vector domain
[ k(:,:,1), k(:,:,2) ] = meshgrid(alphas.*deltakx, betas.*deltaky);

kn = sqrt(sum(abs(k).^2, 3));

end