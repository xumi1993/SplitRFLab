function srad = skm2srad(skm)
%SKM2SRAD Convert from s/km to s/rad
%   SKM2SRAD converts a ray parameter from units of s/km (seconds per
%   kilometer) to s/rad (seconds per radian).
%
%   USAGE:
%          srad = skm2srad (skm)
%
%   INPUT:
%          skm = s/km ray parameter
%
%   OUTPUT:
%          srad = s/rad ray parameter
%
%   EXAMPLE:
%          srad = skm2srad (0.057712);            ANS: skm = 367.68

%   Author: Kevin C. Eagar
%   Date Created: 02/03/2007
%   Last Updated: 05/17/2010

sdeg = skm .* deg2km(1);
srad = rad2deg(sdeg);