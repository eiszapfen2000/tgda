clear all;
close all;

deltaTime = 0.03;
halfDeltaTime = deltaTime / 2;
%deltaAlpha = 0.3;

gravity = 9.81;
%gravitydtdt = 9.81 * deltaTime * deltaTime;
%onealphat = 1 + deltaAlpha * deltaTime;

g_n = 10000;
g_deltaQ = 0.001;

resolution = 256;

heights     = zeros(resolution);
phi         = zeros(resolution);
dphi        = zeros(resolution);
sources     = zeros(resolution);
obstruction = ones(resolution);

sources(20:40, 80:100) = 0.5;
sources(25:35, 85:95) = 0.75;
sources(30, 90) = 1;

obstruction(60:100, 80:100) = 0;
%obstruction = obstruction - 1;

gkernel = G(10, g_n, g_deltaQ);

endTime = 5;
startTime = 0;

while startTime < endTime
    
    phi = phi - (gravity * halfDeltaTime) .* heights + halfDeltaTime .* sources;
    dphi = conv2(phi, gkernel, 'same');
    heights = heights + deltaTime .* dphi; %ignore T for now
    phi = phi - (gravity * halfDeltaTime) .* heights + halfDeltaTime .* sources;
    
    phi = phi .* obstruction;
    heights = heights .* obstruction;
    
    startTime = startTime + deltaTime;

    %waitforbuttonpress;
end

imshow(heights,[]);

