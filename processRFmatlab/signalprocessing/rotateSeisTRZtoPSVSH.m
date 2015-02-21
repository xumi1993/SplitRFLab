function [seis, key]=rotateSeisTRZtoPSVSH( seis, rayp, Vp, Vs);

% rotateSeisTRZtoPSVSH Rotate 3-component seismogram
%
% [SEIS,KEY]=rotateSeisTRZtoPSVSH(SEIS,RAYP,VP,VS)
%
% Convert Transverse, Radial, up seismic records into P, SV, and SH components using the
% free surface transfer matrix. This results in a loss of amplitude due to downgoing
% energy. Note the z component is oposite to that of Kennett
%
% Inputs:
% SEIS = Seismogram array (NT x 3 ), 1 column for each component,
%        must have correct order [ T, R, Z ]; 
%        T=right of propagation, R= horizontal in dirn propagation, Z = up  
% RAYP = ray parameter of incident wave, in s/km
% VP   = P-wave velocity near the surface, in km/s
% VS   = S-wave velocity near the surface, in km/s
%
% Outputs:
% SEIS = Modified seismogram array [P, SV, SH]
%        P=dirn propagation, SV = oposite to back azimuth, SH = right of dirn propagation
% KEY = Legend for each column ['P'; 'SV'; 'SH'], useful for plot3seis function
%

%-- rotateSeisTRZtoPSVSH.m --- 
%  
%  Filename: rotateSeisTRZtoPSVSH.m
%  Author: Stefan Rondenay (at EISW workshop 2011), modified by Iain Bailey
%  Maintainer: IW Bailey
%  Created: Wed Jul 20 17:12:28 2011 (-0700)
%  Version: 1
%  Last-Updated: Tue Aug  2 15:56:13 2011 (-0700)
%            By: Iain Bailey
%      Update #: 94
%  Compatibility: Matlab 2011a
%  
%-- Change Log:
%  
%  
%  
%  
%  
%-- Code:

% get components
T=seis(:,1);
R=seis(:,2);
Z=seis(:,3);

% compute P-SV-SH components
qal = sqrt(1/Vp^2-rayp^2); % vertical slowness for p
qbe = sqrt(1/Vs^2-rayp^2); % and s

ZRT = [ -1*Z, R, T ].';

% multiply by transfer matrix
t11 = (Vs^2*rayp^2 - 0.5)/(Vp*qal);
t12 = (rayp*Vs^2)/Vp;
t21 = rayp*Vs;
t22 = (0.5 - Vs^2*rayp^2)/(Vs*qbe);
psvsh = [ t11 , t12 , 0; ...
	  t21 , t22 , 0; ...
	  0,    0,    0.5] * ZRT;

% assign to matrix
seis(:,1) = psvsh(1,:).';
seis(:,2) = psvsh(2,:).';
seis(:,3) = psvsh(3,:).';

% set label
key = ['P '; 'SV'; 'SH'];

return
%----------------------------------------------------------------------
%-- rotateSeisTRZtoPSVSH.m ends here
