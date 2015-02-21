function rayp = getSlowness( arrname, user, labels, isRad2km )
%
% get the slowness value for a particular phase
% 
% IN:
% arrname = the name of the phase to look for, e.g., 'P'
% user = the user data containing the slownesses
% labels = the labels for the phases corresponding to each slowness value
% isRad2deg = True means convert from s/radians to s/km

RE=6371;
rayp = NaN;

for i = 1:length( user ),
  % match the correct label 
  if(strcmp( strtrim(labels(i,:)), arrname) == 1 ),
    % set to corresponding time
    rayp = user(i);
  end
end

% Check if found
if( isnan( rayp ) ),
  for i = 1:length( user ),
    disp( labels(i,:) )
  end
  error( ['ERROR: slowness of ',arrtime,' arrival not defined'] );
end

% conversion
if( isRad2km ), rayp = rayp/RE;end
  
return

