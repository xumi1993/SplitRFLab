function [newlat, newlon] = geoproject(lat_p, lon_p, lat1, lon1, lat2, lon2)
[~, azi] = distance(lat1, lon1, lat2, lon2);
[dis_center, azi_center] = distance(lat1, lon1, lat_p, lon_p);
dis_along = atand(tand(dis_center)).*cosd(azi - azi_center);
[newlat, newlon] = latlon_from(lat1, lon1,azi,deg2km(dis_along));
return
