function phase = calcphase(config,thiseq)
%calculate travel-times for earthquake

% convert cell to comma-separated string as used by matTaup toolbox:
xx  = config.phases{1};
for i=2:length(config.phases);
    xx=strcat(xx, ',', config.phases{i});
end;
phases=xx;

try
tt = taupPath(config.earthmodel, thiseq.depth, phases, 'deg',thiseq.dis);
catch
    disp('Problem with calcutation phase arrivals!')
    disp('Please check selected phases');
    phase=[];
    return
end
    
    
% in some cases, several arrivals of the same phase are calculated in a
% short time difference. Find these, and just take the first occurence:
if length(tt)>1
    idx=1;
    for k =2:length(tt)
        N1 = tt(k).phaseName;
        N2 = tt(k-1).phaseName;
        t1 = tt(k).time;
        t2 = tt(k-1).time;

        SameName = strcmp(N1,N2);
        lag      = abs(t1-t2);
        if ~(SameName & lag<1);
            % remove double arrivlas, which seems to be a bug in matTaup
            % phases with same name must be one seconds appart to be preserved
            idx(end+1)=k;
        end
    end
    tt = tt(idx);
end
%now sort for arrival time
[phase.ttimes,sid] = sort(cell2mat({tt.time}));
phase.Names        = {tt(sid).phaseName};

%% calculate inclination and takeoff for each phase from data
for iii = 1:length(tt)
    ii = sid(iii);
    cx = (6371-tt(ii).path.depth).*sin(tt(ii).path.distance/180*pi);
    cy = (6371-tt(ii).path.depth).*cos(tt(ii).path.distance/180*pi);

    dx = cx(2) - cx(1);
    dy = cy(2) - cy(1);
    phase.takeoff(iii) = 90 + atan2(dy,dx)*180/pi; %counter Clockwise from vertical downward

    dx = cx(end) - cx(end-1);
    dy = cy(end) - cy(end-1);
    phase.inclination(iii) = 90 - thiseq.dis - atan2(dy,dx)*180/pi ; %Counter Clockwise from vertical (at station) downward
end

