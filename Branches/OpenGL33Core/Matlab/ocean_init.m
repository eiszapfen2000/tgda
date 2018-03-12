function result = ocean_init(geometry, settings)

if ~isscalar(geometry.geometryRes) || ~isscalar(geometry.gradientRes)
    error('BRAK');
end

geometryResLog2 = log2(geometry.geometryRes);
gradientResLog2 = log2(geometry.gradientRes);

[ ~, fge ] = modf(geometryResLog2);
[ ~, fgr ] = modf(gradientResLog2);

if ~isequal(fge, 0) || ~isequal(fgr, 0)
    msg = 'Resolution not power of 2';
    error(msg);
end

if isempty(geometry.lodAreas)
    msg = 'lodAreas is empty';
    error(msg);
end

result.lods = {};
result.geometry = geometry;
result.settings = settings;

necessaryRes = max(geometry.geometryRes, geometry.gradientRes);
numberOfLods = size(geometry.lodAreas, 2);

for l=1:numberOfLods
    [k, kn, deltakx, deltaky] = generate_k(necessaryRes, geometry.lodAreas(l));
    [x, z, deltax, deltay]  = generate_xz(necessaryRes, geometry.lodAreas(l));
    
    Theta = generateSpectrum(k, kn, settings);
    amplitudes = sqrt(2.*Theta.*deltakx.*deltaky);
    
%     mss_x = (k(:,:,1).^2) .* Theta .* (deltakx^2);
%     mss_z = (k(:,:,2).^2) .* Theta .* (deltaky^2);
%     mss = ((k(:,:,1).^2) + (k(:,:,2).^2)) .* Theta .* (deltakx * deltaky);
%     
%     mss_x
%     mss_z
%     mss
%     
%     sum(sum(mss_x))
%     sum(sum(mss_z))
%     sum(sum(mss))
%     
%     sum(sum(mss_x)) + sum(sum(mss_z))
    
    gaussrandr = normrnd(0, 1, necessaryRes, necessaryRes);
    gaussrandi = normrnd(0, 1, necessaryRes, necessaryRes);
    
    result.lods{l}.resolution = necessaryRes;
    result.lods{l}.area = geometry.lodAreas(l);
    result.lods{l}.k = k;
    result.lods{l}.kn = kn;
    result.lods{l}.deltakx = deltakx;
    result.lods{l}.deltaky = deltaky;
    result.lods{l}.x = x;
    result.lods{l}.z = z;
    result.lods{l}.deltax = deltax;
    result.lods{l}.deltay = deltay;
    result.lods{l}.Theta = Theta;
    result.lods{l}.amplitudes = amplitudes;
    result.lods{l}.randomNumbers = complex(gaussrandr, gaussrandi);
end

end

function y = generateSpectrum(k, kn, settings)

switch lower(settings.generatorName)
    case 'pm'
        y = PiersonMoskovitzSpectrum(k, kn, settings.wind);
    case 'jonswap'
        y = JONSWAPSpectrum(k, kn, settings.wind, settings.fetch);
    case 'donelan'
        y = DonelanSpectrum(k, kn, settings.wind, settings.fetch);
    case 'unified'
        y = UnifiedSpectrum(k, kn, settings.wind, settings.fetch);
end

end

