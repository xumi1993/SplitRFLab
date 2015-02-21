function [SEIS] = rotateSeisTRZtoTLQ( SEIS , INC )
%
% [SEIS, KEY] = rotateSeisTRZtoTLQ( SEIS , INC )
%
% Rotate channels from Transverse-Radial-Z(up) to
% Transverse-L(Along_Ray/P)-Q(Ray_Perpendicular/SV) coordinate system
%
% IN:
% SEIS = Seismogram array (NT x 3), 1 column for each component,
%        must have correct order [ T, R, Z ]  
% INC = Incident angle in degrees
%
% OUT:
% SEIS = rotated seismogram in new coord system
% KEY = names of each component

% get components
T=SEIS(:,1);
R=SEIS(:,2);
Z=SEIS(:,3);

% get the P and SV components
%L = Z*cosd(INC) + R*sind(INC); % P
%Q = Z*sind(INC) - R*cosd(INC); % SV

L = Z*cosd(INC) - R*sind(INC); % P %hui
Q = Z*sind(INC) + R*cosd(INC); % SV %hui

% l = z * cos(inc) - n * sin(inc) * cos(ba) - e * sin(inc) * sin(ba)
%     q = -z * sin(inc) - n * cos(inc) * cos(ba) - e * cos(inc) * sin(ba)
%     t = -n * sin(ba) + e * cos(ba)
 
SEIS = [ T, L, Q];
%KEY = strvcat('T','L','Q');
return;
