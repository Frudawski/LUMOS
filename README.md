# LUMOS
LUMOS is a spectral radiosity lighting simulation tool written in Matlab. It allows for spectral and spatial evaluation in arbitrary points and directions.
To use LUMOS a Matlab license is required.

## Program
The LUMOS software comes with a GUI and an editor, allowing to create room geometries, add objects and lumianres, apply material data, luminaire data  and daylight data as well as review the simulation results and export any data or illustrations.




# LUMOS setup

* Download LUMOS and move it to a location of your choice.
* Start Matlab
* Add LUMOS to Matlab’s search path:
    * Type: “addpath(genpath(‘path_to_LUMOS’))” in the command window
    * Or click “Set Path” button under Matlab HOME tab -> “Add with Subfolders…” -> select LUMOS folder -> confirm -> “Save”
* Test the Lighting Toolbox functionality:
    * Type: “plotciexy” in the command window
    * A plot of the CIE x and y chromaticity should appear
*Start LUMOS by:
    * Type ```LUMOS``` in the command window,
    * or open the “spec_simulation.m” script file and click on the Run script button.

# How to cite:
### LUMOS:
Rudawski, Frederic, The spectral radiosity simulation program LUMOS for lighting research applications, version 1.0, 2022, www.frudawski.de/LUMOS

### Lighting toolbox:
Rudawski, Frederic, Lighting Toolbox for Matlab and Octave, 2022, version 1.0, URL: www.frudawski.de/LightingToolbox

### LUMOS accuracy:
Rudawski, Frederic; Knoop, Martine, Validation of the spectral radiosity calculation tool LUMOS in regards to the CIE TR 171 test scenarios for lighting simulation software,  In: Tagungsband Lux junior 2021, pp. 225-248, Digitale Bibliothek Thüringen, 2021. DOI: 10.22032/dbt.49331

### LUMOS materials:
Rudawski, Frederic; Aydınlı, Sırrı; Broszio, Kai, Spectral reflectance and transmittance of various materials, 2022, DOI: 10.14279/depositonce-11893.2
