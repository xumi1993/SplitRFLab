function [km] = deg2km (deg)
%DEG2KM         convert from degrees to kilometers
%
%    DEG2KM computes the distance in kilometers from the distance
%    in degrees.  It assumes a spherical Earth with a radius of
%    6371 km.
%
%    USAGE:
%           [km] = deg2km (deg)
%
%    INPUT:
%           deg = degrees
%
%    OUTPUT:
%           km = kilometers
%
%    EXAMPLE:
%           [km] = deg2km (78);
%
%    Kevin C. Eagar
%    January 23, 2007
%    Last Updated: 01/23/2007
radius = 6371;
circum = 2*pi*radius;
conv = circum / 360;
km = deg * conv;