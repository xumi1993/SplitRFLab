function rfseis=RfViewer(idx)

if nargin<1||isempty(idx)
    idx=1;
end

global config rf thisrf
    
if isempty(rf)
    beep
    errordlg('Sorry no SplitLab-Project is loaded!','No project')
    return
end

thisrf = [];

try
    thisrf = rf(idx); %AW; 07.01.06
    thisrf.index=idx;
catch
    thisrf = rf(1); %AW; 07.01.06
    thisrf.index=1;
%     config.db_index=1;
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

orient landscape

s = findobj('Tag','Statusbar');
    set(s,'String', 'Status:  Drawing axes ...');drawnow
    
    
    time = - config.extime_before  + rf(idx).dt*(0:1:rf(idx).RFlength-1);
    h1 = subplot(3,1,1);
    rfseis(1) = plot(time,rf(idx).RadialRF_f1,'k','LineWidth',2.0);hold on;
    plot(time,rf(idx).TransverseRF_f1);hold on
    plot(xlim,[0 0],'g--');
    set(h1,'xlim',[-3 30],'xtick',(0:2:30),'Xgrid','on')
    title(h1,titlestr,'FontSize',14)
    xlabel(h1,'Time after P(s)');
    ylabel(h1,'filtering from 0.03 to 2Hz');
    
    h2 = subplot(3,1,2);
    rfseis(2) = plot(time,rf(idx).RadialRF_f2,'k','LineWidth',2.0);hold on;
    plot(time,rf(idx).TransverseRF_f2);hold on
    plot(xlim,[0 0],'g--');
    set(h2,'xlim',[-3 30],'xtick',(0:2:30),'Xgrid','on')
    xlabel(h2,'Time after P(s)');
    ylabel(h2,'filtering from 0.06 to 2Hz');
    
    h2 = subplot(3,1,3);
    rfseis(2) = plot(time,rf(idx).RadialRF_f3,'k','LineWidth',2.0);hold on;
    plot(time,rf(idx).TransverseRF_f3);hold on
    plot(xlim,[0 0],'g--');
    set(h2,'xlim',[-3 30],'xtick',(0:2:30),'Xgrid','on')
    xlabel(h2,'Time after P(s)');
    ylabel(h2,'filtering from 0.1 to 2Hz');
    
    
    
rffigbuttons(rffig,rfseis);  
set(rffig,'KeyPressFcn',{@rfKeyPress,rfseis});
    
    
