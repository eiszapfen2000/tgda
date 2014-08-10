clear all;
close all;

resolution = [ 512 512 ];
x = zeros(resolution(1), resolution(2), 2);
k = zeros(resolution(1), resolution(2), 2);
alphas = -resolution(1)/2:1:resolution(1)/2-1;
betas  =  resolution(2)/2:-1:-(resolution(2)/2)+1;


area = [ 40 40 ];
deltax = area(1) / resolution(1);
deltay = area(2) / resolution(2);
deltakx = 2*pi / area(1);
deltaky = 2*pi / area(2);

% spatial domain
[ x(:,:,1) x(:,:,2) ] = meshgrid(alphas.*deltax, betas.*deltay);
% wave vector domain
[ k(:,:,1) k(:,:,2) ] = meshgrid(alphas.*deltakx, betas.*deltaky);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);

[s m1] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(2) 0]);
[s m2] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(8) 0]);
[s m3] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(50) 0]);
[s m4] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(200) 0]);

[s m5] = PiersonMoskovitzSpectrum(k, knorm, [1 1]);
[s m6] = PiersonMoskovitzSpectrum(k, knorm, [2 2]);
[s m7] = PiersonMoskovitzSpectrum(k, knorm, [5 5]);
[s m8] = PiersonMoskovitzSpectrum(k, knorm, [10 10]);


fetch = 100000;
area = [ 15 15 ];
deltax = area(1) / resolution(1);
deltay = area(2) / resolution(2);
deltakx = 2*pi / area(1);
deltaky = 2*pi / area(2);

% spatial domain
[ x(:,:,1) x(:,:,2) ] = meshgrid(alphas.*deltax, betas.*deltay);
% wave vector domain
[ k(:,:,1) k(:,:,2) ] = meshgrid(alphas.*deltakx, betas.*deltaky);

kx2tmp = realpow(k(:,:,1), 2);
ky2tmp = realpow(k(:,:,2), 2);
kx2y2tmp = kx2tmp + ky2tmp;
knorm = realsqrt(kx2y2tmp);

[a d1] = DonelanSpectrum(k, knorm, [sqrt(2) 0], fetch);
[a d2] = DonelanSpectrum(k, knorm, [sqrt(8) 0], fetch);
[a d3] = DonelanSpectrum(k, knorm, [sqrt(50) 0], fetch);
[a d4] = DonelanSpectrum(k, knorm, [sqrt(200) 0], fetch);

[a d5] = DonelanSpectrum(k, knorm, [1 1], fetch);
[a d6] = DonelanSpectrum(k, knorm, [2 2], fetch);
[a d7] = DonelanSpectrum(k, knorm, [5 5], fetch);
[a d8] = DonelanSpectrum(k, knorm, [10 10], fetch);

figure
imshow(d5,[]);
figure
imshow(d6,[]);
figure
imshow(d7,[]);
figure
imshow(d8,[]);
