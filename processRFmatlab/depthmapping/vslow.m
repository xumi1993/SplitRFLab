function result = vslow( v, rayp )
%
% result = vslow( v, rayp )
%
% vertical slowness or sth like that
% IN:
% vel
% slowness (s/km)
%
result = sqrt( 1./(v.^2) - rayp.^2 );
