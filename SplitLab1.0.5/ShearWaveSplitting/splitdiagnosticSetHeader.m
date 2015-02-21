function setsplitheader(axH, phiRC, dtRC, phiSC, dtSC, phiEV, dtEV,pol,  splitoption)
global thiseq config

axes(axH);
str11 = sprintf(['%4.0f<%4.0f\\circ <%4.0f']   ,phiRC);
str21 = sprintf('%3.1f<%3.1fs<%3.1f'           ,dtRC);
str12 = sprintf(['%4.0f<%4.0f\\circ <%4.0f']   ,phiSC);
str22 = sprintf('%3.1f<%3.1fs<%3.1f'           ,dtSC);
str13 = sprintf(['%4.0f<%4.0f\\circ <%4.0f']   ,phiEV);
str23 = sprintf('%3.1f<%3.1fs<%3.1f'           ,dtEV);

SNRstr = ['\rm SNR_{SC}:\bf'        sprintf('%4.1f' ,thiseq.tmpresult.SNR(2) )];
% str41 = [' \rmMute_{RC}:\bf'  sprintf('%.1f' ,thiseq.tmpresult.SNR(3) )];
% str42 = [' \rmMute_{SC}:\bf'  sprintf('%.1f' ,thiseq.tmpresult.SNR(4) )];
% 
% str51 = ['\rm Corr_{RC}:\bf'        sprintf('%2.0f%%' ,thiseq.tmpresult.SNR(5)*100 )];
% str52 = ['\rm Corr_{SC}:\bf'        sprintf('%2.0f%%' ,thiseq.tmpresult.SNR(6)*100 )];


%% 

switch splitoption 
    case 'Minimum Energy'
       optionstr ='      Minimum Energy';
    case 'Eigenvalue: max(lambda1)'
       optionstr ='             max(\lambda1)';
    case 'Eigenvalue: max(lambda1 / lambda2)'
       optionstr ='        max(\lambda1 / \lambda2)';
    case 'Eigenvalue: min(lambda2)'
       optionstr ='             min(\lambda2)  ';
    case 'Eigenvalue: min(lambda1 * lambda2)'
       optionstr ='        min(\lambda1 * \lambda2)';
end



str ={['\rm  Event: \bf' ...
    sprintf('%s (%03.0f) %02.0f:%02.0f  %6.2fN %6.2fE  %.0fkm  \\rmMw=\\bf%3.1f',thiseq.dstr, thiseq.date([7 4 5]) ,thiseq.lat, thiseq.long, thiseq.depth, thiseq.Mw) ];
    ['       \rmStation: \bf' config.stnname '   \rmBackazimuth: \bf' sprintf(['%5.1f'  char(186)],thiseq.bazi) '   \rmDistance: \bf' sprintf(['%.2f'  char(186)],thiseq.dis)];
    ['\rminit.Pol.:  \bf' sprintf(['%5.1f'  char(186)],pol) '  \rmFilter: \bf' sprintf('%.3fHz - %.2fHz',thiseq.filter) '   ' SNRstr];
    '';
    ['\rmRotation Correlation: ' str11 '     ' str21 ];
    ['\rm      Minimum Energy: ' str12 '     ' str22 ];
    ['\rm          Eigenvalue: ' str13 '     ' str23 ];
    ['             \rmQuality: \bf ?   \rm    IsNull: \bf ? \rm    Phase: \bf' thiseq.SplitPhase] };


text(.1, .5,str,...
    'HorizontalAlignment','left',...
    'Tag','FigureHeader',...
    'fontname','fixedwidth');

