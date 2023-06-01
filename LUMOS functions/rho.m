% cierho function - integral reflectance value from spectral reflectance
% vales for standard illuminants.
%
% usage: r = rho(lambda,spec,illuminant)
%
% where: rho: is the integral reflectance value of the given spectrum and
%             standard illuminant
%        lambda: is a vector containing the spectral wavelength steps
%        spec: is a vector containing the spectral reflectance values for
%              wavelength steps defined by vector lambda
%        illuminant: defines the standard illumimant reference, default 'A'
%
% Author: Frederic Rudawski
% Date: 27.03.2021

function r = rho(lambda,spec,illuminant)
if ~exist('illuminant','var')
    illuminant = 'A';
end
r = ciespec2Y(lambda,spec.*ciespec(lambda,illuminant))./ciespec2Y(lambda,ciespec(lambda,illuminant));
