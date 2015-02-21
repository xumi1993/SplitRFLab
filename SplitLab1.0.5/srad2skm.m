function skm = srad2skm(srad)
%SRAD2SKM Convert from s/rad to s/km
%
%   SRAD2SKM converts a ray parameter from units of s/rad (seconds per
%   radian) to s/km (seconds per kilometer).
%
%   USAGE:
%          skm = srad2skm (srad);
%
%   INPUT:
%          srad = s/rad ray parameter
%
%   OUTPUT:
%          skm = s/km ray parameter
%
%   EXAMPLE:
%          skm = srad2skm (367.68);            ANS: skm = 0.057712

%   Author: Kevin C. Eagar
%   Date Created: 01/26/2007
%   Last Updated: 05/13/2010

sdeg = srad .* ((2*pi)/360);
skm = sdeg ./ deg2km(1);