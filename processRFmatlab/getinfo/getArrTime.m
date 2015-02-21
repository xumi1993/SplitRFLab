function tarr = getArrTime( arrname, times, labels )
% GETARRTIME finds the time corresponding to a specific phase label
%
% tarr = getarrtime( arrname, times, labels )
%
% Get the time of an arrival with label arrname from the arrival times and label
% arrays 
% 
% IN: 
% arrname = label of phase looking for (e.g., 'P')
% times = numeric array of all times to look through
% labels = vertical string array of labels for each of the times
%
% OUT:
% tarr = time of desired arrival
%

tarr = NaN;

for i = 1:length( times ),
  % match the correct label 
  if(strcmp( strtrim(labels(i,:)), arrname) == 1 ),
    % set to corresponding time
    tarr = times(i);
  end
end

% Check if found
if( isnan( tarr ) ),
  fprintf( 'WARNING: time of %s arrival not defined\n', arrname );
  fprintf('\t... Labels defined are\n')
  for i = 1:length( times ),
      if( ~strcmp( labels(i,:), '-12345') ),
          fprintf('\t\t%s\n', labels(i,:) );
      end
   end
end

return


%---------------------------------------------------------
