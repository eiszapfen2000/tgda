# Ocean Surface Generation and Rendering
A real-time capable implementation of Tessendorf's choppy wave algorithm [Tessendorf1999a], augmented with wave spectrum models from oceanographic research.

## Videos

| Overview  | Lods |
| ------------- | ------------- |
| [![Overview](https://img.youtube.com/vi/op_NVMRhpL0/0.jpg)](https://www.youtube.com/watch?v=op_NVMRhpL0) | [![Lods](https://img.youtube.com/vi/RiBrIPSPOxo/0.jpg)](https://www.youtube.com/watch?v=RiBrIPSPOxo) |

## Ocean Surface Synthesis
Oceanographic wave spectra:
* Pierson-Moskowitz [Pierson1964a]
* JONSWAP [Hasselmann1973a]
* Donelan [Donelan1985a]
* Elfouhaily [Elfouhaily1997a] 

Donelan and Elfouhaily incorporate a directional distribution. For Pierson-Moskowitz and JONSWAP we employ [Mitsuyasu1975a, Hasselmann1980a]

Fourier Transform done with FFTW, single precision variant.

## Ocean Surface Rendering
* Projected Grid [Johanson2004a]
* Seamless Ocean Surface Lighting [Bruneton2010a]
* Ocean Whitecaps [Dupuy2012a]

## Skylight
Preetham sky light [Preetham1999a, Section 3.1] and sun light [Preetham1999a, Section 3.2].

## Tonemapping
Global tonemapping operator by Reinhard et al. [Reinhard2002a, Equation 4], temporal luminance adaptation algorithm by Krawczyk et al. [Krawczyk2005a, Equations 5, 6, 7, 12]. Color space conversions are done according to http://brucelindbloom.com

## Literature
[Bruneton2010a] Eric Bruneton, Fabrice Neyret, and Nicolas Holzschuch. Real-time realistic ocean lighting using seamless transitions from geometry to brdf. Computer Graphics Forum, 29(2):487–496, 2010.

[Donelan1985a] M. A. Donelan, J. Hamilton, andW. H. Hui. Directional spectra of wind-generated waves. Phil. Trans. Roy. Soc. London A, 315:509–562, 1985.

[Dupuy2012a] Jonathan Dupuy and Eric Bruneton. Real-time animation and rendering of ocean whitecaps. In SIGGRAPH Asia 2012 Technical Briefs, SA ’12, pages 15:1–15:3. ACM, 2012.

[Elfouhaily1997a] T. Elfouhaily, B. Chapron, K. Katsaros, and D. Vandemark. A unified directional spectrum for long and short wind-driven waves. J. Geophys. Res., 102(C7):15781–15796, 1997.

[Hasselmann1973a] K. Hasselman, T. P. Barnett, E. Bouws, D. E. Carlson, and P. Hasselmann. Measurements of wind-wave growth and swell decay during the joint north sea wave project (jonswap). Deutsche Hydrographische Zeitschrift, 8(12), 1973.

[Hasselmann1980a] D. E. Hasselmann, M. Dunckel, and J. A. Ewing. Directional wave spectra observed during JONSWAP 1973. J. Phys. Oceanogr., 10:1264–1280, 1980.

[Johanson2004a] Claes Johanson. Real-time water rendering - introducing the projected grid concept. Master’s thesis, Department of Computer Science, Lund University, 2004.

[Krawczyk2005a] Grzegorz Krawczyk, Karol Myszkowski, and Hans-Peter Seidel. Perceptual effects in real-time tone mapping. In Proceedings of the 21st Spring Conference on Computer Graphics, SCCG ’05, pages 195–202. ACM, 2005.

[Mitsuyasu1975a] H. Mitsuyasu, F. Tasai, T. Suhara, S. Mizuno, M. Ohkusu, T. Honda, and K. Rikiishi. Observations of the Directional Spectrum of Ocean Waves Using a Cloverleaf Buoy. Journal of Physical Oceanography, 5:750, 1975.

[Pierson1964a] Willard J. Pierson and Lionel Moskowitz. A proposed spectral form for fully developed wind seas based on the similarity theory of S. A. Kitaigorodskii. J. Geophys. Res., 69(24), December 1964.

[Preetham1999a] A. J. Preetham, Peter Shirley, and Brian Smits. A practical analytic model for daylight. In Proceedings of the 26th Annual Conference on Computer Graphics and Interactive Techniques, SIGGRAPH ’99, pages 91–100. ACM Press/Addison-Wesley Publishing Co., 1999.

[Reinhard2002a] Erik Reinhard, Michael Stark, Peter Shirley, and James Ferwerda. Photographic tone reproduction for digital images. In Proceedings of the 29th Annual Conference on Computer Graphics and Interactive Techniques, SIGGRAPH ’02, pages 267–276. ACM, 2002.

[Tessendorf1999a] Jerry Tessendorf. Simulating ocean water. In SIGGRAPH course notes. ACM, 1999.
