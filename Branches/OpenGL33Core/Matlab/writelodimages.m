function writelodimages( prefix, lod )

ppi2meters = ceil((96 / 2.54) * 100);

gradients = {lod.gx, lod.gz};
displacements = {lod.dx, lod.dz};

ngradients = imrelnormalize(gradients);
ndisplacements = imrelnormalize(displacements);

imwrite(imnormalize(lod.heights), [ prefix 'heights.png' ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(ngradients{1},     [ prefix 'gradient_x.png'     ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(ngradients{2},     [ prefix 'gradient_z.png'     ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(ndisplacements{1}, [ prefix 'displacement_x.png' ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);
imwrite(ndisplacements{2}, [ prefix 'displacement_z.png' ], 'ResolutionUnit', 'meter', 'XResolution', ppi2meters, 'YResolution', ppi2meters);

end

