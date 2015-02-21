function [lat2,lon2] = latlon_from (lat1,lon1,azimuth,distance)
%LATLON_FROM        lat/lon at a distance and azimuth from a point
%已知1点经纬度、方位角、距离算第2点经纬度
%    LATLON_FROM computes the lat/lon coordinates of a point given a
%    distance and azimuth from an input point.
%
%    USAGE:
%           [lat2,lon2] = latlon_from (lat1,lon1,azimuth,distance);
%
%    INPUT:
%           lat1 = latitude of point 1
%           lon1 = longitude of point 1
%           azimuth = azimuth to new point
%           distance = distance from point 1 to point 2 (in km)
%
%    OUTPUT:
%           lat2 = latitude of point 2
%           lon2 = longitude of point 2
%
%    NOTES:
%    1. Azimuth OR distance can be a vector, but not both.
%    2. If one is a vector, the output coordinates are also vectors of the
%    same length.
%
%    Kevin C. Eagar
%    February 19, 2007
%    Last Updated: 02/20/2007

% convert distance in km to distance in degrees along a Great Circle path
%--------------------------------------------------------------------------
gcarc_dist = km2deg (distance);

% find lat and lon that corresponds to this distance and back-azimuth
%--------------------------------------------------------------------------
% law of cosines to find latitude
lat2 = asind ((sind (lat1) .* cosd (gcarc_dist)) + (cosd (lat1) .* sind (gcarc_dist) .* cosd (azimuth)));
% law of sines to find longitude
if length(gcarc_dist) >= 2
    for n = 1:length(gcarc_dist)
        if ( cosd (gcarc_dist(n)) >= (cosd (90 - lat1) .* cosd (90 - lat2(n))))
            lon2(n) = lon1 + asind (sind (gcarc_dist(n)) .* sind (azimuth) / cosd (lat2(n)));
        else
            lon2(n) = lon1 + asind (sind (gcarc_dist(n)) .* sind (azimuth) / cosd (lat2(n))) + 180;
        end
    end
elseif length(azimuth) >= 2
    for n = 1:length(azimuth)
        if ( cosd (gcarc_dist) >= (cosd (90 - lat1) .* cosd (90 - lat2(n))))
            lon2(n) = lon1 + asind (sind (gcarc_dist) .* sind (azimuth(n)) / cosd (lat2(n)));
        else
            lon2(n) = lon1 + asind (sind (gcarc_dist) .* sind (azimuth(n)) / cosd (lat2(n))) + 180;
        end
    end
else
    if ( cosd (gcarc_dist) >= (cosd (90 - lat1) .* cosd (90 - lat2)))
        lon2 = lon1 + asind (sind (gcarc_dist) .* sind (azimuth) / cosd (lat2));
    else
        lon2 = lon1 + asind (sind (gcarc_dist) .* sind (azimuth) / cosd (lat2)) + 180;
    end
end