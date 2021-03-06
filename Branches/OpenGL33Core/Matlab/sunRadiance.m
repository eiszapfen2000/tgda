function xyY = sunRadiance(thetaSun, turbidity)

sun_spectral_radiance = [ ...
%in W.cm^{-2}.um^{-1}.sr^{-1}
1655.9,  1623.37, 2112.75, 2588.82, 2582.91, 2423.23, 2676.05, 2965.83, 3054.54, 3005.75, ...
3066.37, 2883.04, 2871.21, 2782.5,  2710.06, 2723.36, 2636.13, 2550.38, 2506.02, 2531.16, ...
2535.59, 2513.42, 2463.15, 2417.32, 2368.53, 2321.21, 2282.77, 2233.98, 2197.02, 2152.67, ...
2109.79, 2072.83, 2024.04, 1987.08, 1942.72, 1907.24, 1862.89, 1825.92,     0.0,     0.0, ...
0.0 ...
];

sun_spectral_k_o = [ ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.003, 0.006, 0.009, ...
0.014, 0.021, 0.03, 0.04, 0.048, 0.063, 0.075, 0.085, 0.103, 0.12, ...
0.12, 0.115, 0.125, 0.12, 0.105, 0.09, 0.079, 0.067, 0.057, 0.048, ...
0.036, 0.028, 0.023, 0.018, 0.014, 0.011, 0.01, 0.009, 0.007, 0.004, ...
0.0 ...
];

sun_spectral_k_wa = [ ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.016, 0.024, 0.0125, 1.0, 0.87, 0.061, 0.001, 1e-05, 1e-05, ...
0.0006 ...
];

sun_spectral_k_g = [ ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, ...
0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 0.21, ...
0.0 ...
];

lambda_micrometer = [ ...
0.380, 0.390, 0.400, 0.410, 0.420, 0.430, 0.440, 0.450, 0.460, 0.470, ...
0.480, 0.490, 0.500, 0.510, 0.520, 0.530, 0.540, 0.550, 0.560, 0.570, ...
0.580, 0.590, 0.600, 0.610, 0.620, 0.630, 0.640, 0.650, 0.660, 0.670, ...
0.680, 0.690, 0.700, 0.710, 0.720, 0.730, 0.740, 0.750, 0.760, 0.770, ...
0.780 ...
];

xyz_matching_functions = [...
0.000159952,0.0023616,0.0191097,0.084736,0.204492,0.314679,0.383734,0.370702,0.302273,0.195618,0.080507,0.016172,0.003816,0.037465,0.117749,0.236491,0.376772,0.529826,0.705224,0.878655,1.01416,1.11852,1.12399,1.03048,0.856297,0.647467,0.431567,0.268329,0.152568,0.0812606,0.0408508,0.0199413,0.00957688,0.00455263,0.00217496,0.00104476,0.000508258,0.000250969,0.00012639,6.45258E-05,3.34117E-05; ...
1.7364e-05,0.0002534,0.0020044,0.008756,0.021391,0.038676,0.062077,0.089456,0.128201,0.18519,0.253589,0.339133,0.460777,0.606741,0.761757,0.875211,0.961988,0.991761,0.99734,0.955552,0.868934,0.777405,0.658341,0.527963,0.398057,0.283493,0.179828,0.107633,0.060281,0.0318004,0.0159051,0.0077488,0.00371774,0.00176847,0.00084619,0.00040741,0.00019873,9.8428e-05,4.9737e-05,2.5486e-05,1.3249e-05; ...
0.000704776,0.0104822,0.0860109,0.389366,0.972542,1.55348,1.96728,1.9948,1.74537,1.31756,0.772125,0.415254,0.218502,0.112044,0.060709,0.030451,0.013676,0.003988,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ...
];

% https://pvlib-python.readthedocs.io/en/latest/_modules/pvlib/atmosphere.html
radiansToDegree = 180 / pi;
degreeToRadians = pi / 180;
thetaSunDegrees = thetaSun * radiansToDegree;
% simple
% m = 1.0 / cos(thetaSun);
% kasten 1966
m = 1.0 / (cos(thetaSun) + 0.15 * power(93.885 - thetaSunDegrees, -1.253));
% kasten young 1989
% m = 1.0 / (cos(thetaSun) + 0.50572 * power((6.07995 + (90 - thetaSunDegrees)), - 1.6364));
% pickering 2002
% m = 1.0 / sin(degreeToRadians*(90 - thetaSunDegrees + 244 / (power(165 + 47.0 * (90 - thetaSunDegrees), 1.1))));
beta = 0.04608 * turbidity - 0.04586;
l = 0.35;
alpha = 1.3;
w = 2.0;

exponent = zeros(size(lambda_micrometer));
exponent = exponent + (-0.008735 * power(lambda_micrometer, -4.08 * m));
exponent = exponent + (-beta * power(lambda_micrometer, -alpha * m));
exponent = exponent + (-sun_spectral_k_o .* l .* m);
exponent = exponent + ((-1.41 .* sun_spectral_k_g .* m) ./ power(1.0 + 118.93 .* sun_spectral_k_g .* m, 0.45));
exponent = exponent + ((-0.2385 .* sun_spectral_k_wa .* w .* m) ./ power(1.0 + 20.07 .* sun_spectral_k_wa .* w .* m, 0.45));
spectralRadiance = sun_spectral_radiance .* exp(exponent);

scaling = (100^2) * (1/10^3);
deltanm = 10.0;
combined = scaling * deltanm;

sunXYZ = [0 0 0];
sunXYZ(1) = (spectralRadiance * xyz_matching_functions(1,:)') .* combined;
sunXYZ(2) = (spectralRadiance * xyz_matching_functions(2,:)') .* combined;
sunXYZ(3) = (spectralRadiance * xyz_matching_functions(3,:)') .* combined;

xyY = XYZ2xyY(sunXYZ);

end