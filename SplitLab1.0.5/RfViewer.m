function rfseis=RfViewer(idx)

if nargin<1||isempty(idx)
    idx=1;
end

global config rf thisrf eq
    
if isempty(rf)
    beep
    errordlg('Sorry no SplitLab-Project is loaded!','No project')
    return
end

thisrf = [];
config.db_index = idx;
try
    thisrf = rf(idx); %AW; 07.01.06
    thisrf.index=idx;
%     config.db_index = rf(idx).eqidx;
catch
    thisrf = rf(1); %AW; 07.01.06
    thisrf.index=1;
    config.db_index=1;
end

titlestr = sprintf(['M_w = %3.1f  Backazimuth: %6.2f' char(186) '  Distance: %6.2f' char(186) '   Depth: %3.0fkm'],rf(idx).Mw, rf(idx).bazi, rf(idx).dis, rf(idx).depth);


rffig = findobj('Tag','RFFigure');
figname = sprintf(['Event: %s; Station: %s; (' num2str(idx) '/' num2str(length(rf)) ')'],rf(idx).seisfile, config.stnname);
if isempty(rffig)
    pos=get(0,'ScreenSize');
    width= pos(3)/2.5 ; height=pos(4);
    xpos = pos(1) +width/2;  ypos = height/2 ;
    figpos =[xpos ypos width height];
    rffig = figure('NumberTitle','off',...
        'name',figname,...
        'renderer','painters',...
        'ToolBar','none',...
        'Menubar','none',...
        'Tag','RFFigure',...
        'color','w',...
        'Position',figpos,...
        'Pointer','crosshair', ...
        'PaperType',       config.PaperType,...
        'PaperOrientation','landscape',...
        'PaperUnits','centimeters');
else
   figure(rffig); %bring window to front
    figpos   = get(gcf,'Position');
    clf(rffig) 
    set(rffig,'name',figname,'Tag','RFFigure','Pointer','crosshair',...
        'WindowButtonDownFcn','',  'PaperOrientation','landscape')
end

orient landscape;

s = findobj('Tag','Statusbar');
    set(s,'String', 'Status:  Drawing axes ...');drawnow
    
time = - config.extime_before  + rf(idx).dt*(0:1:rf(idx).RFlength-1);

if config.f0 < 1
Ev_para = taupTime('iasp91',rf(idx).depth,rf(idx).phase,'sta',[config.slat,config.slong],'evt',[rf(idx).lat,rf(idx).lon]);   
Ev_para = srad2skm(Ev_para(1).rayParam); 

vp1=6.3;vs1=3.6500;H1=40;
vp2=8.4152;vs2=4.6068;H2=370;
vp3=9.7964;vs3=5.3454;H3=250;

vp410=(vp1*H1+vp2*H2)/410;
vs410=(vs1*H1+vs2*H2)/410;
vp660=(vp1*H1+vp2*H2+vp3*H3)/660;
vs660=(vs1*H1+vs2*H2+vs3*H3)/660;

eta_p410 = vslow( vp410, Ev_para);
eta_s410 = vslow( vs410, Ev_para);
eta_p660 = vslow( vp660, Ev_para);
eta_s660 = vslow( vs660, Ev_para);

tp410s=tPs(410, eta_p410, eta_s410 );
tp660s=tPs(660, eta_p660, eta_s660 );
end

    h1 = subplot(3,1,1);
    rfseis(1) = plot(time,rf(idx).RadialRF_f1,'k','LineWidth',2.0);hold on;
    plot(time,rf(idx).TransverseRF_f1);hold on
    plot(xlim,[0 0],'g--');hold on;
    if config.f0 < 1
    plot([tp410s tp410s],ylim,'r','LineWidth',0.8);hold on;
    plot([tp660s tp660s],ylim,'r','LineWidth',0.8);hold on;
    end
    set(h1,'xlim',[-3 config.timeafterp],'xtick',(0:2:config.timeafterp),'Xgrid','on')
    title(h1,titlestr,'FontSize',14)
    xlabel(h1,'Time after P(s)');
    ylabel(h1,'filtering from 0.03 to 2Hz');
    
    h2 = subplot(3,1,2);
    rfseis(2) = plot(time,rf(idx).RadialRF_f2,'k','LineWidth',2.0);hold on;
    plot(time,rf(idx).TransverseRF_f2);hold on
    plot(xlim,[0 0],'g--');hold on;
    if config.f0 < 1
    plot([tp410s tp410s],ylim,'r','LineWidth',0.8);hold on;
    plot([tp660s tp660s],ylim,'r','LineWidth',0.8);hold on;
    end
    set(h2,'xlim',[-3 config.timeafterp],'xtick',(0:2:config.timeafterp),'Xgrid','on')
    xlabel(h2,'Time after P(s)');
    ylabel(h2,'filtering from 0.06 to 2Hz');
    
    h2 = subplot(3,1,3);
    rfseis(2) = plot(time,rf(idx).RadialRF_f3,'k','LineWidth',2.0);hold on;
    plot(time,rf(idx).TransverseRF_f3);hold on
    plot(xlim,[0 0],'g--');hold on;
    if config.f0 < 1
    plot([tp410s tp410s],ylim,'r','LineWidth',0.8);hold on;
    plot([tp660s tp660s],ylim,'r','LineWidth',0.8);hold on;
    end
    set(h2,'xlim',[-3 config.timeafterp],'xtick',(0:2:config.timeafterp),'Xgrid','on')
    xlabel(h2,'Time after P(s)');
    ylabel(h2,'filtering from 0.1 to 2Hz');
    
earthfig= findobj('Type','Figure','Tag','EarthView');
if ~isempty(earthfig)
  SL_Earthview(thisrf.lat, thisrf.lon, thisrf.Mw, thisrf.depth, eq(idx).date(2))
% set(0,'CurrentFigure',seisfig)
%  set(seisfig,'Position',figpos);
end    
    
rffigbuttons(rffig);  
set(rffig,'KeyPressFcn',{@rfKeyPress,rfseis});
    
    
