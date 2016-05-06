clear all

% noise_res = 4;
% gradients = -1 + (1 - (-1)) .* rand(noise_res, noise_res, 2);
% gn = sqrt(sum(abs(gradients).^2, 3));
% gradients(:,:,1) = gradients(:,:,1) ./ gn;
% gradients(:,:,2) = gradients(:,:,2) ./ gn;
% 
% p = randperm(noise_res);

% noise_res = 256;
% G = -1 + (1 - (-1)) .* rand(noise_res, 1);
% P = randperm(noise_res);

G2 = -1 + (1 - (-1)) .* rand(2, 6);
    
% normalise gradient vectors
gn = sqrt(sum(abs(G2).^2, 1));
G2(1,:) = G2(1,:) ./ gn;
G2(2,:) = G2(2,:) ./ gn;

% x = [1:0.05:3];
% y = [2:-0.05:1];
% [xm, ym] = meshgrid(x,y);
width = 32;
height = 32;
image = zeros(height,width*2-1);

for ys=1:height
    y = 1 + (ys - 1) ./ (height - 1);
    for xs=1:width
        x = 1 + (xs - 1) ./ (width - 1);
        n = noise2d_test(G2(:,1),G2(:,2),G2(:,3),G2(:,4),[1,1]',[1,2]',[2,1]',[2,2]',[x,y]');
        image(ys,xs) = n;
    end
    for xs=2:width
        x = 2 + (xs - 1) ./ (width - 1)
        n = noise2d_test(G2(:,3),G2(:,4),G2(:,5),G2(:,6),[2,1]',[2,2]',[3,1]',[3,2]',[x,y]');
        image(ys,xs+width-1) = n;
    end
end

imshow(image,[]);