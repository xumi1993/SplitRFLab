function RFwave = RFseisview(idx)

global config eq thisrf

if isempty([thisrf.seisfiles{:}])
errordlg('No SAC files associated to database!','Files not associated')
    return
end


efile = fullfile(config.datadir, thisrf.seisfiles{1});
nfile = fullfile(config.datadir, thisrf.seisfiles{2});
zfile = fullfile(config.datadir, thisrf.seisfiles{3});
if ~exist(efile,'file')||~exist(nfile,'file')||~exist(zfile,'file')
    errordlg({'Seismograms not found!','Please check data directory',efile,nfile,zfile},'File I/O Error')
   return
end

%% plot defaults
scol = [0 0 1; 1 0 0;0 .8 0];% color ordering of seimogramms
tcol = 'm';  % color of travel time markers
acol = [0.9 0.9 0.9]; % color of active selection area
ocol = [1 1 .8];      % color of old selection area(s)
afcol= [1 1 1] * .6;  %color of SAC header A & F markers
fontsize          = get(gcf,'DefaultAxesFontsize')-3;
thisrf.system     = 'ENV'; % or: 'LTQ'; % DEFAULT SYSTEM
thisrf.SplitPhase = 'SKS'; %default selection

thisrf.resultnumber = length(thiseq.results) + 1;
n = thisrf.resultnumber;

titlestr={sprintf('Event: %s, (%03.0f); Station: %s; E_{SKS}: %4.1f%%',thiseq.dstr, thiseq.date(7), config.stnname, abs(thiseq.energy*100));
    sprintf(['M_w = %3.1f  Backazimuth: %6.2f' char(186) '  Distance: %6.2f' char(186) '   Depth: %3.0fkm'],thiseq.Mw, thiseq.bazi, thiseq.dis, thiseq.depth)};



