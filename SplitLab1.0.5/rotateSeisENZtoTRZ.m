function [SEIS, KEY] = rotateSeisENZtoTRZ( SEIS , BAZ )
%
% SEIS = rotateSeisENZtoTRZ( SEIS , BAZ )
%
% Rotate channels from East-North-Z(up) to Transverse-Radial-Z(up)
% coordinate system
%
% IN:
% SEIS = Seismogram array (NT x 3), 1 column for each component,
%        must have correct order [ E, N, Z ]  
% BAZ = Back azimuth of ray at station in degrees
%
% OUT:
% SEIS = rotated seismogram in new coord system [ T, R, Z ]
% KEY = labels for which component is in which column

% Modified from Levander's code by IWB, Oct 2010


% get components
E=SEIS(:,1);
N=SEIS(:,2);
Z=SEIS(:,3);

% Flip the angle by 180 degrees and get in range 0 - 360 degrees
angle = mod( BAZ+180, 360);

% get the radial and transverse components
R = N.*cosd( angle ) + E.*sind(angle);
T = E.*cosd( angle ) - N.*sind(angle);

SEIS = [ T, R, Z];
KEY = strvcat('T', 'R', 'Z' );
return;
