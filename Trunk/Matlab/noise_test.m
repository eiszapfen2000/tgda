clear all
close all

pnoise = [];
res = 256;

nO = 7;
persistence = 1/2;

n = zeros(res,res);
octaves = zeros([res,res,nO]);


for i=1:nO
    f = 2^(i-1);
    amplitude = persistence^(i-1);
    
    x = [1:(1/(res-1))*f:1+f];
    y = x(end:-1:1);
    [xm,ym]=meshgrid(x,y);
    
    [pn,pnoise]=noise2d(pnoise,xm,ym);
    subplot(1,nO,i); imshow(pn,[]);
    
    n = n + pn .* amplitude;
end

figure
imshow(n,[]);

c = n - 0.02;
c(c < 0) = 0;
cd = 1.0 - 0.25.^c;

figure
imshow(cd,[]);

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