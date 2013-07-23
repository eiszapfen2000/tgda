clear all;
close all;

deltaTime = 0.03;
deltaAlpha = 0.3;

gravity = 9.81;
gravitydtdt = 9.81 * deltaTime * deltaTime;
onealphat = 1 + deltaAlpha * deltaTime;

g_n = 10000;
g_deltaQ = 0.001;

resolution = 256;

heights     = zeros(resolution);
prevHeights = zeros(resolution);
derivative  = zeros(resolution);
sources     = zeros(resolution);
obstruction = ones(resolution);

sources(20:40, 80:100) = 0.75;
sources(25:35, 85:95) = 1.5;
sources(30, 90) = 2;

obstruction(60:100, 80:100) = 0;
%obstruction = obstruction - 1;

gkernel = G(10, g_n, g_deltaQ);

subplot(2,2,1);
imshow(sources,[]);
subplot(2,2,2);
imshow(obstruction,[]);
subplot(2,2,3);
imshow(heights,[]);

endTime = 5;
startTime = 0;

while true
    
    heights = heights + sources;
    heights = heights .* obstruction;
    
    derivative = conv2(heights, gkernel, 'same');
    
    temp = heights;
    
    heights = heights .* ((2 - deltaAlpha * deltaTime) / onealphat);
    heights = heights - prevHeights .* (1 / onealphat);
    heights = heights - derivative .* (gravitydtdt / onealphat);
    
    prevHeights = temp;
    
    startTime = startTime + deltaTime;

    imshow(heights,[]);
    waitforbuttonpress;
    
end

