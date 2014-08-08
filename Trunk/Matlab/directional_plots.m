clear all;
close all;

resolution = [ 8 8 ];
area = [ 150 150 ];
wind = [ 2 0];
fetch = 100000; %10km

deltax = area(1) / resolution(1);
deltay = area(2) / resolution(2);
deltakx = 2*pi / area(1);
deltaky = 2*pi / area(2);

alphas = -resolution(1)/2:1:resolution(1)/2-1;
betas  =  resolution(2)/2:-1:-(resolution(2)/2)+1;

% spatial domain
x = zeros(resolution(1), resolution(2), 2);
[ x(:,:,1) x(:,:,2) ] = meshgrid(alphas.*deltax, betas.*deltay);

% wave vector domain
k = zeros(resolution(1), resolution(2), 2);
[ k(:,:,1) k(:,:,2) ] = meshgrid(alphas.*deltakx, betas.*deltaky);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);

[s d] = PiersonMoskovitzSpectrum(k, knorm, wind);


[a b] = DonelanSpectrum(k, knorm, wind, fetch);

imshow(b,[]);