#ifndef ODENERGY_H_
#define ODENERGY_H_

float peak_energy_wave_frequency_pm(float U10);
float peak_energy_wave_frequency_jonswap(float U10, float fetch);
float peak_energy_wave_frequency_donelan(float U10, float fetch);
float peak_energy_wave_number_unified(float U10, float fetch);

float energy_pm_wave_frequency(float omega, float U10);
float energy_jonswap_wave_frequency(float omega, float U10, float fetch);
float energy_donelan_wave_frequency(float omega, float U10, float fetch);
float energy_unified_wave_number(float k, float U10, float fetch);

float directional_spreading_mitsuyasu_hasselmann(float omega_p, float omega, float theta_p, float theta);
float directional_spreading_donelan(float omega_p, float omega, float theta_p, float theta);
float directional_spreading_unified(float U10, float k_p, float k, float theta_p, float theta);

#endif

