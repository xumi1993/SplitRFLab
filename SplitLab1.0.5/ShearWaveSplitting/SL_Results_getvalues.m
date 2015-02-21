function out = SL_Results_getvalues
%find events with selected criteria and assings automatic Quality

global  eq

for i = 1 : length(eq) %just look again for evetns with results
    x(i)=~isempty(eq(i).results);
end
res = find(x==1) ;
if isempty(res)
    out=[];
    return
end


selected = getappdata(gcf);



%%
out.good  = [];
out.fair  = [];
out.poor  = [];
out.goodN = [];
out.fairN = [];

k=0;
for i = 1:length(res)% Loop over each event with result
    num = res(i);
    for val=1:length(eq(num).results)%Loop over number of results per event
        thisphase = eq(num).results(val).SplitPhase;

        if isempty(thisphase); break; end
        %check if result phase corresponds to any of the selected phase
        correspond = ~isempty(strmatch(thisphase,selected.phases, 'exact'));
        if correspond
            k=k+1;
            if strcmp(selected.method, 'Manual')
                Q = eq(num).results(val).quality;
                N = eq(num).results(val).Null;
                if selected.Quality(1) && strcmp(Q,'good') && selected.Nulls(2) && strcmp(N,'No')
                    out.good(end+1) = k;
                elseif selected.Quality(2) && strcmp(Q,'fair') && selected.Nulls(2) && strcmp(N,'No')
                    out.fair(end+1) = k;
                elseif selected.Quality(3) && strcmp(Q,'poor') %&& selected.Nulls(2) && strcmp(N,'No')
                    out.poor(end+1) = k;
                elseif selected.Quality(1) && strcmp(Q,'good') && selected.Nulls(1) && strcmp(N,'Yes')
                    out.goodN(end+1) = k;
                elseif selected.Quality(2) && strcmp(Q,'fair') && selected.Nulls(1) && strcmp(N,'Yes')
                    out.fairN(end+1) = k;
                else
                    k=k-1;
                    break
                end
            end

            out.evt(k)    = eq(num).date(1)*1000 + eq(num).date(7) + eq(num).date(4)/100;
            out.back(k)   = eq(num).bazi;

            out.dtSC(k)   = eq(num).results(val).dtSC(2);
            out.phiSC(k)  = eq(num).results(val).phiSC(2);

            out.phiRC(k)  = eq(num).results(val).phiRC(2);
            out.dtRC(k)   = eq(num).results(val).dtRC(2);
            
            out.phiEV(k)  = eq(num).results(val).phiEV(2);
            out.dtEV(k)   = eq(num).results(val).dtEV(2);

            out.inc(k)   = eq(num).results(val).incline;
            out.Omega(k) = mod(abs(out.phiSC(k)-out.phiRC(k)), 90);
            out.Phas{k}  = eq(num).results(val).SplitPhase;
            SNR_T(k)     = eq(num).results(val).SNR(2);
        end
    end
end

if strcmp(selected.method, 'Automatic')
    [out.good, out.fair, out.poor, out.goodN, out.fairN]=NullCriterion(out.phiSC, out.phiRC, out.dtSC, out.dtRC, SNR_T);
    if ~selected.Quality(1) || ~selected.Nulls(2),        out.good=[];     end
    if ~selected.Quality(2) || ~selected.Nulls(2),        out.fair=[];     end
    if ~selected.Quality(3),                              out.poor=[];     end
    if ~selected.Quality(1) || ~selected.Nulls(1),        out.goodN=[];    end
    if ~selected.Quality(2) || ~selected.Nulls(1),        out.fairN=[];    end
    k=length([out.good, out.fair, out.poor, out.goodN, out.fairN]);
end

 count = [length(out.good) length(out.fair) length(out.poor) length(out.fairN) length(out.goodN)];
   
if k==0
    warndlg('No result matches selected criteria, sorry!')
    out=[];
    return
end



disp(['Number of results: ' num2str(k)]);


fprintf(' good fair poor fairNull goodNull \n');
fprintf(' %3.0f  %3.0f  %3.0f    %3.0f      %3.0f   \n\n', count);




