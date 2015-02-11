#ifndef ODENERGY_H_
#define ODENERGY_H_

float peak_energy_wave_frequency_pm(float U10);
float peak_energy_wave_frequency_jonswap(float U10);

float energy_pm_wave_frequency(float omega, float U10);
float energy_jonswap_wave_frequency(float omega, float U10, float fetch);

float directional_spreading_mitsuyasu_hasselmann(float omega_p, float omega, float theta_p, float theta);

#endif

