function [stnname, netw, slat, slong, sele] = loadstainfo
global config rf eq

sac_all = dir(fullfile(config.datadir,config.searchstr));
sacname = [config.datadir '/' sac_all(1).name];
nowsac = rsac(sacname);
stnname = deblank(lh(nowsac,'KSTNM'));
netw = deblank(lh(nowsac,'KNETWK'));
slat = lh(nowsac,'STLA');
slong = lh(nowsac,'STLO');
sele = lh(nowsac,'STEL');
rf = [];
eq = [];


return