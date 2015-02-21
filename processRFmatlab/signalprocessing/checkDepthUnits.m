function z = checkDepthUnits( z, units , isForce)

% Make sure units are correct and modify if not
%
% z = checkDepthUnits( z, units )
%
% IN:
% z = depth
% units: 'km' = change m to km, 'm' = change km to m
% isForce (optional): true = force the conversion, 
%                     false(default) = check based on if z > 800
% 
% OUT: 
% z = modified depth 
%

zmaxkm = 800; % don't expect km depths to be greater than this

% default check before converting, useful for heterogeneous data sets
if nargin < 3, isForce = false; end

if( units == 'km' ),
  if( isForce | (z>zmaxkm & ~isForce)),
    z = z/1e3;
  end
elseif( units == 'm' ),
  if( isForce | (z>zmaxkm & ~isForce)),
    z = z*1e3;
  end
else
  fprintf('checkdepth: units not recognised')
end

return
