function mss_plots
% close all

k = 0:0.005:1000;
k_prev = [0 k(1:end-1)];
diff_k = k - k_prev;

% wind = 0:0.5:30;
wind = unique([0:0.25:30]);
wind(1) = eps;
mss_pm = zeros(1,numel(wind));
mss_j = zeros(1,numel(wind));
mss_d = zeros(1,numel(wind));
mss_u = zeros(1,numel(wind));

fetch = 100000;

for i=1:numel(wind)
    pm_i_k = PiersonMoskovitz1Dk(k, wind(i), []);
    j_i_k = JONSWAP1Dk(k, wind(i), fetch, []);
    d_i_k = Donelan19851Dk(k, wind(i), fetch, []);
    u_i_k = UnifiedSpectrum1Dk(k, wind(i), fetch, []);
    mss_pm(i) = sum((k.^2).*pm_i_k.*diff_k);
    mss_j(i) = sum((k.^2).*j_i_k.*diff_k);
    mss_d(i) = sum((k.^2).*d_i_k.*diff_k);
    mss_u(i) = sum((k.^2).*u_i_k.*diff_k);
end
% 
% mss_pm(isnan(mss_pm)) = 0;
% mss_j(isnan(mss_j)) = 0;
% mss_d(isnan(mss_d)) = 0;
% mss_u(isnan(mss_u)) = 0;
% 
figure
hold on
plot(wind,mss_pm,'r');
plot(wind,mss_j,'g');
plot(wind,mss_d,'b');
plot(wind,mss_u,'k');
hold off

write2dcsv(wind,mss_pm,'mss_pm.dat');
write2dcsv(wind,mss_j,'mss_jonswap_fetch_100km.dat');
write2dcsv(wind,mss_d,'mss_donelan_fetch_100km.dat');
write2dcsv(wind,mss_u,'mss_unified_fetch_100km.dat');


% pm_10_k = PiersonMoskovitz1Dk(k, 10.0, []);
% j_10_5km_k = JONSWAP1Dk(k, 10.0, 5000, []);
% j_10_500km_k = JONSWAP1Dk(k, 10.0, 500000, []);
% d_10_5km_k = Donelan19851Dk(k, 10.0, 5000, []);
% d_10_500km_k = Donelan19851Dk(k, 10.0, 500000, []);
% u_10_5km_k = UnifiedSpectrum1Dk(k, 10.0, 5000, []);
% u_10_500km_k = UnifiedSpectrum1Dk(k, 10.0, 500000, []);
% 
% 
% mss_pm_10_k = sum((k.^2).*pm_10_k.*diff_k)
% mss_j_10_5km_k = sum((k.^2).*j_10_5km_k.*diff_k)
% mss_j_10_500km_k = sum((k.^2).*j_10_500km_k.*diff_k)
% mss_d_10_5km_k = sum((k.^2).*d_10_5km_k.*diff_k)
% mss_d_10_500km_k = sum((k.^2).*d_10_500km_k.*diff_k)
% mss_u_10_5km_k = sum((k.^2).*u_10_5km_k.*diff_k)
% mss_u_10_500km_k = sum((k.^2).*u_10_500km_k.*diff_k)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% delta_k = 0.25;
% k_x = -150: delta_k: 150;
% k_y =  150:-delta_k:-150;
% 
% k = zeros(numel(k_y), numel(k_x), 2);
% [k(:,:,1), k(:,:,2)] = meshgrid(k_x,k_y);
% kn = sqrt(sum(abs(k).^2, 3));
% 
% wind = unique([0:0.25:5 5:0.5:30]);
% wind(1) = eps;
% 
% mss_x_pm = zeros(1,numel(wind));
% mss_y_pm = zeros(1,numel(wind));
% mss_x_j = zeros(1,numel(wind));
% mss_y_j = zeros(1,numel(wind));
% mss_x_d = zeros(1,numel(wind));
% mss_y_d = zeros(1,numel(wind));
% mss_x_u = zeros(1,numel(wind));
% mss_y_u = zeros(1,numel(wind));
% 
% k_x_delta_squared = (k(:,:,1).^2).*(delta_k^2);
% k_y_delta_squared = (k(:,:,2).^2).*(delta_k^2);
% 
% fetch = 500000;
% 
% for i=1:numel(wind)
% % pm_2d = PiersonMoskovitzSpectrum(k,kn,[sqrt(0.5*(wind(i)^2)) sqrt(0.5*(wind(i)^2))]);
% pm_2d = PiersonMoskovitzSpectrum(k,kn,[0 wind(i)]);
% j_2d = JONSWAPSpectrum(k,kn,[0 wind(i)],fetch);
% d_2d = DonelanSpectrum(k,kn,[0 wind(i)],fetch);
% u_2d = UnifiedSpectrum(k,kn,[0 wind(i)],fetch);
% 
% mss_x_pm(i) = sum(sum(k_x_delta_squared.*pm_2d));
% mss_y_pm(i) = sum(sum(k_y_delta_squared.*pm_2d));
% mss_x_j(i) = sum(sum(k_x_delta_squared.*j_2d));
% mss_y_j(i) = sum(sum(k_y_delta_squared.*j_2d));
% mss_x_d(i) = sum(sum(k_x_delta_squared.*d_2d));
% mss_y_d(i) = sum(sum(k_y_delta_squared.*d_2d));
% mss_x_u(i) = sum(sum(k_x_delta_squared.*u_2d));
% mss_y_u(i) = sum(sum(k_y_delta_squared.*u_2d));
% end
% 
% % save('mss_xy_f_500000_w_y.mat');
% 
% figure
% hold on
% plot(wind,mss_x_pm,'r');
% plot(wind,mss_x_j,'g');
% plot(wind,mss_x_d,'b');
% plot(wind,mss_x_u,'k');
% hold off
% 
% figure
% hold on
% plot(wind,mss_y_pm,'r');
% plot(wind,mss_y_j,'g');
% plot(wind,mss_y_d,'b');
% plot(wind,mss_y_u,'k');
% hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
end