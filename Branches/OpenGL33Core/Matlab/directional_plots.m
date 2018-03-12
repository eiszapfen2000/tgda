clear all;
close all;

resolution = [ 512 512 ];
area = [ 40 40 ];

[k knorm x] = build_wave_vectors(resolution, area);

[s m1 d1] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(2) 0]);
[s m2 d2] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(8) 0]);
[s m3 d3] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(50) 0]);
[s m4 d4] = PiersonMoskovitzSpectrum(k, knorm, [sqrt(200) 0]);

[s m5 d5] = PiersonMoskovitzSpectrum(k, knorm, [1 1]);
[s m6 d6] = PiersonMoskovitzSpectrum(k, knorm, [2 2]);
[s m7 d7] = PiersonMoskovitzSpectrum(k, knorm, [5 5]);
[s m8 d8] = PiersonMoskovitzSpectrum(k, knorm, [10 10]);

area = [ 100 100 ];
[k knorm x] = build_wave_vectors(resolution, area);

[s u1] = UnifiedSpectrum(k, knorm, [sqrt(2) 0], 100000);
[s u2] = UnifiedSpectrum(k, knorm, [sqrt(8) 0], 100000);
[s u3] = UnifiedSpectrum(k, knorm, [sqrt(50) 0], 100000);
[s u4] = UnifiedSpectrum(k, knorm, [sqrt(200) 0], 100000);
[s u5] = UnifiedSpectrum(k, knorm, [1 1], 100000);
[s u6] = UnifiedSpectrum(k, knorm, [2 2], 100000);
[s u7] = UnifiedSpectrum(k, knorm, [5 5], 100000);
[s u8] = UnifiedSpectrum(k, knorm, [10 10], 100000);

ppi2meters = ceil((96 / 2.54) * 100);

% imwrite(m1, 'dfilt_wr_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m2, 'dfilt_wr_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m3, 'dfilt_wr_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m4, 'dfilt_wr_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m5, 'dfilt_wur_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m6, 'dfilt_wur_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m7, 'dfilt_wur_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(m8, 'dfilt_wur_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);

% low = min([min(min(m1)) min(min(m2)) min(min(m3)) min(min(m4)) min(min(m5)) min(min(m6)) min(min(m7)) min(min(m8))]);
% high = max([max(max(m1)) max(max(m2)) max(max(m3)) max(max(m4)) max(max(m5)) max(max(m6)) max(max(m7)) max(max(m8))]);
% 
% imwrite(imadjust(m1,[low; high],[0;1]), 'mitsuyasu_dfilt_wr_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m2,[low; high],[0;1]), 'mitsuyasu_dfilt_wr_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m3,[low; high],[0;1]), 'mitsuyasu_dfilt_wr_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m4,[low; high],[0;1]), 'mitsuyasu_dfilt_wr_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m5,[low; high],[0;1]), 'mitsuyasu_dfilt_wur_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m6,[low; high],[0;1]), 'mitsuyasu_dfilt_wur_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m7,[low; high],[0;1]), 'mitsuyasu_dfilt_wur_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(imadjust(m8,[low; high],[0;1]), 'mitsuyasu_dfilt_wur_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);

low = min([min(min(d1)) min(min(d2)) min(min(d3)) min(min(d4)) min(min(d5)) min(min(d6)) min(min(d7)) min(min(d8))]);
high = max([max(max(d1)) max(max(d2)) max(max(d3)) max(max(d4)) max(max(d5)) max(max(d6)) max(max(d7)) max(max(d8))]);

imwrite(uint8(imadjust(d1 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wr_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d2 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wr_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d3 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wr_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d4 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wr_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d5 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wur_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d6 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wur_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d7 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wur_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(uint8(imadjust(d8 ./ min(high,1),[low; min(high,1)],[0;1]).*255), 'donelan_dfilt_wur_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);

% imwrite(d1, 'donelan_dfilt_wr_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d2, 'donelan_dfilt_wr_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d3, 'donelan_dfilt_wr_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d4, 'donelan_dfilt_wr_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d5, 'donelan_dfilt_wur_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d6, 'donelan_dfilt_wur_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d7, 'donelan_dfilt_wur_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
% imwrite(d8, 'donelan_dfilt_wur_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
%
minU = min(min([u1;u2;u3;u4;u5;u6;u7;u8]));
maxU = max(max([u1;u2;u3;u4;u5;u6;u7;u8]));
% 
imwrite(imadjust(u1, [minU maxU], [0; 1]), 'unified_dfilt_wr_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u2, [minU maxU], [0; 1]), 'unified_dfilt_wr_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u3, [minU maxU], [0; 1]), 'unified_dfilt_wr_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u4, [minU maxU], [0; 1]), 'unified_dfilt_wr_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u5, [minU maxU], [0; 1]), 'unified_dfilt_wur_sqrt2.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u6, [minU maxU], [0; 1]), 'unified_dfilt_wur_sqrt8.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u7, [minU maxU], [0; 1]), 'unified_dfilt_wur_sqrt50.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imadjust(u8, [minU maxU], [0; 1]), 'unified_dfilt_wur_sqrt200.png', 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);


% 
% fetch = 100000;
% area = [ 15 15 ];
% deltax = area(1) / resolution(1);
% deltay = area(2) / resolution(2);
% deltakx = 2*pi / area(1);
% deltaky = 2*pi / area(2);
% 
% % spatial domain
% [ x(:,:,1) x(:,:,2) ] = meshgrid(alphas.*deltax, betas.*deltay);
% % wave vector domain
% [ k(:,:,1) k(:,:,2) ] = meshgrid(alphas.*deltakx, betas.*deltaky);
% 
% kx2tmp = realpow(k(:,:,1), 2);
% ky2tmp = realpow(k(:,:,2), 2);
% kx2y2tmp = kx2tmp + ky2tmp;
% knorm = realsqrt(kx2y2tmp);
% 
% [a d1] = DonelanSpectrum(k, knorm, [sqrt(2) 0], fetch);
% [a d2] = DonelanSpectrum(k, knorm, [sqrt(8) 0], fetch);
% [a d3] = DonelanSpectrum(k, knorm, [sqrt(50) 0], fetch);
% [a d4] = DonelanSpectrum(k, knorm, [sqrt(200) 0], fetch);
% 
% [a d5] = DonelanSpectrum(k, knorm, [1 1], fetch);
% [a d6] = DonelanSpectrum(k, knorm, [2 2], fetch);
% [a d7] = DonelanSpectrum(k, knorm, [5 5], fetch);
% [a d8] = DonelanSpectrum(k, knorm, [10 10], fetch);
% 
% figure
% imshow(d5,[]);
% figure
% imshow(d6,[]);
% figure
% imshow(d7,[]);
% figure
% imshow(d8,[]);
