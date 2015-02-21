function [gclat,gclon] = gg2gc (gglat,gglon)
%GG2GC      convert from geographic to geocentric coordinates
%
%    GG2GC converts a latitude and longitude from geographic to
%    geocentric coordinate system.
%
%    USAGE:
%           [gclat,gclon] = gg2gc (gglat,gglon)
%
%    INPUT:
%           gglat       = geographic latitude
%           gglon      = geographic longitude
%
%    OUTPUT:
%           gclat       = geocentric latitude
%           gclon      = geocentric longitude
%
%    NOTES:
%    1) Latitude 0 to 90 is North and 0 to -90 is South
%    2) Longitude is 0 to -180 is West and 0 to 180 is East
%
%    EXAMPLE:
%           [elat,elon] = gg2gc (38.45,-118.32);
%
%    Kevin C. Eagar
%    December 19, 2006
%    Last Updated: 01/06/2007

a = 0.9933056;       % ratio of polar radius to equitorial radius
gclat = atan (a * tan (gglat * pi / 180));
gclon = gglon * pi / 180;
