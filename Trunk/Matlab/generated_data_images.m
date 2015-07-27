clear
close all

time = 1;

geometry = [];
geometry.geometryRes = 512;
geometry.gradientRes = 512;
geometry.lodAreas = [ 50 ];

settings = [];
settings.generatorName = 'Unified';
settings.wind = [ 30 0 ];
settings.fetch = 500000;

lolz = ocean_init(geometry, settings);
lolz = ocean_animate(lolz, time);
lolz = ocean_transform(lolz);

writelodimages('u_30_500km_', lolz.lods(1));
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