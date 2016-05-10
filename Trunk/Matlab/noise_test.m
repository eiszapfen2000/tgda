close all

res = 256;
pnoise = [];

startOctave = 4;
nOctaves = 6;
persistence = 1/2;
[n1, o1, ~] = perlinNoise2d(pnoise, res, [startOctave nOctaves], persistence);
[n2, o2, ~] = perlinNoise2d(pnoise, res, [startOctave nOctaves], persistence);

% figure
% imshow(n1,[]);
% figure
% imshow(n2,[]);
% 
figure
for i=1:nOctaves
    subplot(2,ceil(nOctaves/2),i); imshow(o1(:,:,i),[]);
end
figure
for i=1:nOctaves
    subplot(2,ceil(nOctaves/2),i); imshow(o2(:,:,i),[]);
end

% nc = o1(:,:,4)+o1(:,:,5)+o1(:,:,6)+o1(:,:,7);
nc = n1;
n1Min = min(min(nc));
n1Max = max(max(nc));
n1Range = n1Max - n1Min;
np1 = (nc - n1Min) ./ n1Range;

figure
imshow(np1,[]);

c1 = np1 - 0.475;
c1(c1 < 0) = 0;
cd1 = 1.0 - 0.01.^c1;

figure
imshow(cd1,[]);

imf = fspecial('gaussian',[7 7]);
figure;
imshow(imfilter(cd1,imf),[]);


% n1Min = min(min(n1));
% n1Max = max(max(n1));
% n1Range = n1Max - n1Min;
% np1 = (n1 - n1Min) ./ n1Range;
% 
% n2Min = min(min(n2));
% n2Max = max(max(n2));
% n2Range = n2Max - n2Min;
% np2 = (n2 - n2Min) ./ n2Range;
% 
% c1 = np1 - 0.5;
% c1(c1 < 0) = 0;
% cd1 = 1.0 - 0.15.^c1;
% 
% c2 = np2 - 0.5;
% c2(c2 < 0) = 0;
% cd2 = 1.0 - 0.15.^c2;
% 
% figure
% imshow(cd1,[]);
% figure
% imshow(cd2,[]);
% 
% figure
% hold on
% 
% for t= 0:0.05:1
% c = c1 .* (1-t) + c2 .* t;
% imshow(c,[]);
% pause(0.5);
% end
% hold off


% x = [1:1/(res-1):2];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n1,pnoise]=noise2d(pnoise,xm,ym);
% 
% x = [1:(1/(res-1))*2:3];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n2,pnoise]=noise2d(pnoise,xm,ym);
% 
% x = [1:(1/(res-1))*4:5];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n3,pnoise]=noise2d(pnoise,xm,ym);
% 
% x = [1:(1/(res-1))*8:9];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n4,pnoise]=noise2d(pnoise,xm,ym);
% 
% x = [1:(1/(res-1))*16:17];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n5,pnoise]=noise2d(pnoise,xm,ym);
% 
% x = [1:(1/(res-1))*32:33];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n6,pnoise]=noise2d(pnoise,xm,ym);
% 
% x = [1:(1/(res-1))*64:65];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n7,pnoise]=noise2d(pnoise,xm,ym);
% 
% figure
% subplot(1,8,1); imshow(n1,[]);
% subplot(1,8,2); imshow(n2,[]);
% subplot(1,8,3); imshow(n3,[]);
% subplot(1,8,4); imshow(n4,[]);
% subplot(1,8,5); imshow(n5,[]);
% subplot(1,8,6); imshow(n6,[]);
% subplot(1,8,7); imshow(n7,[]);
% subplot(1,8,8); imshow(128.*n1+64.*n2+32.*n3+16.*n4+8.*n5+4.*n6+2.*n7,[]);

% x = [1.5:1:256.5];
% y = x(end:-1:1);
% [xm,ym]=meshgrid(x,y);
% [n1,pnoise]=noise2d(pnoise,xm,ym);
% 
% imshow(n1,[]);