function deg = rad2deg (rad)
%RAD2DEG       convert from radians to degrees
%
%    RAD2DEG converts from units of radians to degrees.
%
%    USAGE:
%           deg = rad2deg (rad);
%
%    INPUT:
%           rad = radians
%
%    OUTPUT:
%           deg = degrees
%
%    EXAMPLE:
%           deg = rad2deg (367.68);            ANS: deg = 6.4172
%
%    Kevin C. Eagar
%    January 26, 2007
%    Last Updated: 01/26/2007
deg = rad .* (360/(2*pi));