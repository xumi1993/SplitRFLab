function SEIS = remove_dcSeis( SEIS )
% 
% SEIS = remove_dcSeis( SEIS )
%
% Remove DC component of seismogram from each of three components 
%
% IN: 
% SEIS = Seismogram array (NT x NC), 1 column for each component.  
%
% Out:
% SEIS = seismograms after removing DC
%

% Modified from Alan Levander's codes by IWB, Oct 2010

nc = size(SEIS,2); % number of components
for i=1:nc,
  
  % get the mean 
  Zmean=mean(SEIS(:,i),1);

  % remove it
  SEIS(:,i) = SEIS(:,i) - Zmean;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


