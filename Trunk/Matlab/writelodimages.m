function writelodimages( prefix, lod )

ppi2meters = ceil((96 / 2.54) * 100);
imwrite(imnormalize(lod.heights), [ prefix 'heights.png'        ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imnormalize(lod.gx),      [ prefix 'gradient_x.png'     ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imnormalize(lod.gz),      [ prefix 'gradient_z.png'     ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imnormalize(lod.dx),      [ prefix 'displacement_x.png' ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(imnormalize(lod.dz),      [ prefix 'displacement_z.png' ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);

end

