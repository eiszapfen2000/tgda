clear
close all

time = 1;

geometry = [];
geometry.geometryRes = 512;
geometry.gradientRes = 512;
geometry.lodAreas = [ 100 ];

settings = [];
settings.generatorName = 'unified';
settings.wind = [ 30 0];
settings.fetch = 500000;

lolz = ocean_init(geometry, settings);
lolz = ocean_animate(lolz, time);
lolz = ocean_transform(lolz);

x = lolz.lods(1).x(256,:);
h = lolz.lods(1).heights(256,:);
dx = lolz.lods(1).dx(256,:);
dx_x = lolz.lods(1).dx_x(256,:);
dx_z = lolz.lods(1).dx_z(256,:);
dz_x = lolz.lods(1).dz_x(256,:);
dz_z = lolz.lods(1).dz_z(256,:);

%output = [x', dx', h'];
%csvwrite('u_30_500km_x_dx_h.dat', output);

df = -7.5;
jdet = ((1+df.*dx_x) .* (1+df.*dz_z)) - ((df.*dx_z) .* (df.*dz_x));

output = [x', dx', h', dx_x', dx_z', dz_x', dz_z' ];
csvwrite('d_25_500km_x_dx_h_dxx_dxz_dzx_dzz.dat', output);

figure
hold on
plot(x,h);
plot(x, zeros(1, size(x,2)), 'black');
plot(x+df.*dx, jdet, 'green');
plot(x+df.*dx, h, 'r');
%axis equal
hold off

% nplots = 1;
% lolz = ocean_init(geometry, settings);
% figure
% 
% for i=1:nplots
%     time = i * 0.5;
%     lolz = ocean_animate(lolz, time);
%     lolz = ocean_transform(lolz);
% 
%     x = lolz.lods(1).x(256,:);
%     h = lolz.lods(1).heights(256,:);
%     dx = lolz.lods(1).dx(256,:);
%     
%     minX = min(x);
%     maxX = max(x);
%     x = [ x (x + (maxX - minX)) ];
%     h = [ h h ];
%     dx = [ dx dx ];
%     
%     subplot(nplots, 1, i);
%     hold on
%     plot(x, h)
%     %axis off
%     plot(x-5.*dx,h,'r')
%     hold off
% end

% writelodimages('u_30_500km_', lolz.lods(1));
% figure
% subplot(3, 4, 1);
% imshow(brok{1});
% subplot(3, 4, 2);
% imshow(brok{2});
% 
% brak = {lolz.lods(1).gx, lalz.lods(1).gx};
% brok = imrelnormalize(brak);
% 
% subplot(3, 4, 5);
% imshow(brok{1});
% subplot(3, 4, 6);
% imshow(brok{2});
% 
% brak = {lolz.lods(1).gz, lalz.lods(1).gz};
% brok = imrelnormalize(brak);
% 
% subplot(3, 4, 7);
% imshow(brok{1});
% subplot(3, 4, 8);
% imshow(brok{2});
% 
% brak = {lolz.lods(1).dx, lalz.lods(1).dx};
% brok = imrelnormalize(brak);
% 
% subplot(3, 4, 9);
% imshow(brok{1});
% subplot(3, 4, 10);
% imshow(brok{2});
% 
% brak = {lolz.lods(1).dz, lalz.lods(1).dz};
% brok = imrelnormalize(brak);
% 
% subplot(3, 4, 11);
% imshow(brok{1});
% subplot(3, 4, 12);
% imshow(brok{2});