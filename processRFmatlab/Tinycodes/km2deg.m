function  deg = km2deg (km)
%KM2DEG         convert from kilometers to degrees
%
%    KM2DEG computes the distance in degrees from the distance
%    in kilometers.  It assumes a spherical Earth with a radius of
%    6371 km.
%
%    USAGE:
%           [deg] = km2deg (km)
%
%    INPUT:
%           km = kilometers
%
%    OUTPUT:
%           deg = degrees
%
%    EXAMPLE:
%           [deg] = km2deg (11000);
%
%    Kevin C. Eagar
%    January 23, 2007
%    Last Updated: 01/23/2007

radius = 6371;
circum = 2*pi*radius;
conv = circum / 360;
deg = km / conv;