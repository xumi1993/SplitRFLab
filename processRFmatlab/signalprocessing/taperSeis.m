function SEIS = taperSeis( SEIS, TAPERW )
% 
% SEIS = taperSeis( SEIS, TAPERW )
%
% Taper the seismogram using a hanning window 
%
% In: 
%   SEIS = Seismogram array (NT x NC), 1 column for each component.  
%   TAPERW = proportion of seismogram length to apply taper to 
%
% Out:
% SEIS = seismograms after taper
%

nc = size(SEIS,2); % number of components
nt = size(SEIS,1); % number of samples
nw = 2*min( round(TAPERW*nt), nt); % width of filter
taper = hann( nw );

for i=1:nc,
  % add to the start
  SEIS(1:0.5*nw,i) = SEIS(1:0.5*nw,i).*taper(1:0.5*nw); 
  
  % add to the end
  SEIS((nt+1-0.5*nw):nt,i) = SEIS((nt+1-0.5*nw):nt,i).*taper(1+0.5*nw:nw); 

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


