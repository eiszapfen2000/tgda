close all

k = 0:0.001:1000;
% k = 0:0.01:25;
% 
pm_10_k = PiersonMoskovitz1Dk(k, 10.0, []);
% j_10_5km_k = JONSWAP1Dk(k, 10.0, 5000, []);
% j_10_500km_k = JONSWAP1Dk(k, 10.0, 500000, []);
% d_10_5km_k = Donelan19851Dk(k, 10.0, 5000, []);
% d_10_500km_k = Donelan19851Dk(k, 10.0, 500000, []);
% u_10_5km_k = UnifiedSpectrum1Dk(k, 10.0, 5000, []);
% u_10_500km_k = UnifiedSpectrum1Dk(k, 10.0, 500000, []);
% 
k_prev = [0 k(1:end-1)];
diff_k = k - k_prev;
% 
mss_pm_10_k = sum((k.^2).*pm_10_k.*diff_k)
% mss_j_10_5km_k = sum((k.^2).*j_10_5km_k.*diff_k)
% mss_j_10_500km_k = sum((k.^2).*j_10_500km_k.*diff_k)
% mss_d_10_5km_k = sum((k.^2).*d_10_5km_k.*diff_k)
% mss_d_10_500km_k = sum((k.^2).*d_10_500km_k.*diff_k)
% mss_u_10_5km_k = sum((k.^2).*u_10_5km_k.*diff_k)
% mss_u_10_500km_k = sum((k.^2).*u_10_500km_k.*diff_k)

delta_k = 0.3;
k_x = -1000: delta_k: 1000;
k_y =  1000:-delta_k:-1000;

k = zeros(numel(k_y), numel(k_x), 2);
[k(:,:,1), k(:,:,2)] = meshgrid(k_x,k_y);

kn = sqrt(sum(abs(k).^2, 3));

pm_2d = PiersonMoskovitzSpectrum(k,kn,[5 0]);
% j_2d = JONSWAPSpectrum(k,kn,[5 0],500000);
% d_2d = DonelanSpectrum(k,kn,[5 0],500000);
% u_2d = UnifiedSpectrum(k,kn,[5 0],500000);

% nix = (k(:,:,1).^2 + k(:,:,2).^2).*pm_2d.*(0.01^2);
mss_x = sum(sum((k(:,:,1).^2).*pm_2d.*(delta_k^2)))
mss_y = sum(sum((k(:,:,2).^2).*pm_2d.*(delta_k^2)))
mss = sum(sum((k(:,:,1).^2 + k(:,:,2).^2).*pm_2d.*(delta_k^2)))

% sum(sum((k(:,:,1).^2).*j_2d.*(0.01^2)))
% sum(sum((k(:,:,2).^2).*j_2d.*(0.01^2)))
% sum(sum(((k(:,:,1).^2) + (k(:,:,2).^2))).*j_2d.*(0.01^2))
% 
% sum(sum((k(:,:,1).^2).*d_2d.*(0.01^2)))
% sum(sum((k(:,:,2).^2).*d_2d.*(0.01^2)))
% sum(sum(((k(:,:,1).^2) + (k(:,:,2).^2))).*d_2d.*(0.01^2))
% 
% sum(sum((k(:,:,1).^2).*u_2d.*(0.01^2)))
% sum(sum((k(:,:,2).^2).*u_2d.*(0.01^2)))
% sum(sum(((k(:,:,1).^2) + (k(:,:,2).^2))).*u_2d.*(0.01^2))


% figure
% hold on
% plot(k,j_10_5km_k);
% plot(k,j_10_10km_k);
% plot(k,j_10_25km_k);
% plot(k,j_10_50km_k);
% plot(k,j_10_75km_k);
% plot(k,j_10_100km_k);
% plot(k,j_10_200km_k);
% plot(k,j_10_300km_k);
% plot(k,j_10_400km_k);
% plot(k,j_10_500km_k);
% plot(k,j_10_1000km_k);
% plot(k,j_10_1500km_k);
% plot(k,j_10_2000km_k);
% hold off