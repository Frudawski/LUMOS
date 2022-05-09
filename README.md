# LUMOS

LUMOS is a spectral radiosity lighting simulation tool written in Matlab. It allows for spectral and spatial evaluation in arbitrary points and directions.
To use LUMOS, a Matlab license is required. The LUMOS software comes with a GUI and an editor, allowing to create room geometries, add objects and luminaires, apply material data, luminaire data and daylight data as well as review the simulation results and export any data or illustrations.

LUMOS uses the [Lighting Toolbox for Matlab and Octave](https://www.frudawski.de/LightingToolbox) for various calculations and plots and will not function without it.

[LUMOS was tested against several CIE 171 test scenarious for lighting simulation software](https://www.db-thueringen.de/receive/dbt_mods_00049331) and achieved good accuracy.

LUMOS comes with a number of different [spectral reflectance and transmittance material](https://depositonce.tu-berlin.de/handle/11303/13097.2) samples.

## LUMOS setup:

* Download LUMOS and move it to a location of your choice.
* Start Matlab
* Add LUMOS to Matlab’s search path:
    * Type: ```addpath(genpath(‘path_to_LUMOS’))``` in the command window
    * Or click “Set Path” button under Matlab HOME tab -> “Add with Subfolders…” -> select LUMOS folder -> confirm -> “Save”
* Test the Lighting Toolbox functionality:
    * Type: ```plotciexy``` in the command window
    * A plot of the CIE x and y chromaticity should appear
* Start LUMOS by:
    * Type ```LUMOS``` in the command window,
    * or open the “spec_simulation.m” script file and click on the Run script button.

## How to cite:
### LUMOS:
Rudawski, Frederic, *The spectral radiosity simulation program LUMOS for lighting research applications*, version 1.0, 2022, URL: www.frudawski.de/LUMOS

### Lighting Toolbox:
Rudawski, Frederic, *Lighting Toolbox for Matlab and Octave*, 2022, version 1.0, URL: www.frudawski.de/LightingToolbox

### LUMOS accuracy:
Rudawski, Frederic; Knoop, Martine, *Validation of the spectral radiosity calculation tool LUMOS in regards to the CIE TR 171 test scenarios for lighting simulation software*,  In: Tagungsband Lux junior 2021, pp. 225-248, Digitale Bibliothek Thüringen, 2021. DOI: 10.22032/dbt.49331

### LUMOS materials:
Rudawski, Frederic; Aydınlı, Sırrı; Broszio, Kai, *Spectral reflectance and transmittance of various materials*, 2022, DOI: 10.14279/depositonce-11893.2
