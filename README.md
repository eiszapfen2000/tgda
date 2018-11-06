# Real-Time Ocean Surface Generation and Rendering
A real-time capable implementation of Tessendorf's choppy wave algorithm.

[![Overview](https://img.youtube.com/vi/op_NVMRhpL0/0.jpg)](https://www.youtube.com/watch?v=op_NVMRhpL0)
[![Lods](https://img.youtube.com/vi/RiBrIPSPOxo/0.jpg)](https://www.youtube.com/watch?v=RiBrIPSPOxo)

## Ocean Surface Synthesis
Oceanographic wave spectra:
* Pierson-Moskowitz
* JONSWAP
* Donelan
* Elfouhailly

Tessendorf ad-hoc spectrum:
* Phillips (deprecated)

Directional distribution Hasselmann 1973 and Mitsuyasu 1980.

Fourier Transform done with FFTW, single precision variant. Initially, complex-to-real transformation, later pack two hermitian spectra into one, and therefore transform both at once.

## Ocean Surface Rendering
* Projected Grid - Johanson
* Seamless Ocean Surface Lighting - Bruneton, Neyret
* Ocean Whitecaps - Dupuy, Neyret

## Skylight
Preetham sky light and sun light, where the sun color is computed via full scattering.

## Tonemapping
Reinhard global tonemapping operator. Color space conversions are done according to http://brucelindbloom.com
