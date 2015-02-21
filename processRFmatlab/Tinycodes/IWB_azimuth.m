function az = azimuth (lat1,lon1,lat2,lon2);
%AZIMUTH            computes azimuth between two lat/lon coordinates
%
%    AZIMUTH computes the azimuth angle from coordinates [lat1 lon1] to
%    coordinates [lat2 lon2].  Azimuths are undefined at the poles, so we
%    choose a convention: zero at the north pole and pi at the south pole.
%
%    USAGE:
%           az = azimuth (lat1,lon1,lat2,lon2)
%
%    INPUT:
%           lat1 = latitude of point 1
%           lon1 = longitude of point 1
%           lat2 = latitude of point 2
%           lon2 = longitude of point 2
%
%    OUTPUT:
%           az = azimuth angle (in degrees)
%
%    EXAMPLE:
%           az = azimuth (45,-120,50,-88);          az = 65.436;
%
%    Kevin C. Eagar
%    December 19, 2006
%    Last Updated: 02/20/2007

% convert from geographic to geocentric coordinates
%--------------------------------------------------------------------------
[gc_lat1,gc_lon1] = gg2gc(lat1,lon1);
[gc_lat2,gc_lon2] = gg2gc(lat2,lon2);

% calculate azimuth
%--------------------------------------------------------------------------
az = atan2((cos(gc_lat2) * sin(gc_lon2 - gc_lon1)), ((cos(gc_lat1) * sin(gc_lat2)) - (sin(gc_lat1) * cos(gc_lat2) * cos(gc_lon2 - gc_lon1))));

% define azimuths at the poles
%--------------------------------------------------------------------------
az(gc_lat2 <= -pi/2) = 0;
az(gc_lat1 >=  pi/2) = 0;
az(gc_lat1 <= -pi/2) = pi;
az(gc_lat2 >=  pi/2) = pi;

% output azimuths in degrees
%--------------------------------------------------------------------------
az = az * 180/pi;
if (az < 0); az = 360 + az; end