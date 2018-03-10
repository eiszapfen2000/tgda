function [k, knorm, x] = build_wave_vectors(resolution, area)

x = zeros(resolution(1), resolution(2), 2);
k = zeros(resolution(1), resolution(2), 2);
alphas = -resolution(1)/2:1:resolution(1)/2-1;
betas  =  resolution(2)/2:-1:-(resolution(2)/2)+1;

deltax = area(1) / resolution(1);
deltay = area(2) / resolution(2);
deltakx = 2*pi / area(1);
deltaky = 2*pi / area(2);

% spatial domain
[ x(:,:,1), x(:,:,2) ] = meshgrid(alphas.*deltax, betas.*deltay);
% wave vector domain
[ k(:,:,1), k(:,:,2) ] = meshgrid(alphas.*deltakx, betas.*deltaky);

knorm = sqrt(sum(abs(k).^2, 3));

end