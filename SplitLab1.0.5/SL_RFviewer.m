function SL_RFviewer(idx)

global config rf

data_info = regexp(rf(idx).seisfile,'_', 'split');
titlestr = {sprintf(['Event: %s; Station: %s; (' num2str(idx) '/' num2str(length(rf)) ')'],rf(idx).seisfile, config.stnname);
            sprintf(['M_w = %3.1f  Backazimuth: %6.2f' char(186) '  Distance: %6.2f' char(186) '   Depth: %3.0fkm'],rf(idx).Mw, rf(idx).bazi, rf(idx).dis, rf(idx).depth)};


time = - config.extime_before  + rf(idx).dt*(0:1:rf(idx).RFlength-1);


plot(time,rf(idx).RadialRF,'k','LineWidth',2.0);hold on;
plot(time,rf(idx).TransverseRF);hold on
plot(xlim,[0 0],'g--');
set(gca,'xlim',[-3 30],'xtick',(0:2:30),'Xgrid','on')
title(gca,titlestr,'FontSize',16)
hold off;

return