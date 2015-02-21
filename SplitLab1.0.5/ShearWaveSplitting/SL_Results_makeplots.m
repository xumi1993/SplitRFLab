function SL_Results_makeplots(good, fair, poor, goodN, fairN, ...
    evt, back, phiSC, dtSC, phiRC, dtRC, phiEV, dtEV,Omega, inc, Phas)
% PLot results as Misfit, Stereoplot and as function of backazimuth
% pramters are parsed from the dialog created in SL_Results.m

global config eq

goodMarker  = 'r+';
goodNMarker = 'ro';
fairMarker  = 'bx';
fairNMarker = 'bs';
poorMarker  = 'm^';


selected    = getappdata(gcbf);
DefPos      = get(0,'DefaultFigurePosition');
FontSize    = get(0,'DefaultAxesFontSize')-2;

handles = guidata(gcbf);
defcol   = get(handles.color, 'UserData');
defwidth = get(handles.width, 'UserData');
defstyle = get(handles.style, 'UserData');




%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% Create Figure
tit =['Results of ' config.project ];
fig = findobj('type', 'figure','Name', tit);
if isempty(fig)
    figure('NumberTitle', 'Off',...
        'Name', tit,...
        'FileName',        config.project(1:end-4),...
        'Position',DefPos+[-105 -100 210 100],...
        'PaperType',       config.PaperType)
else
    figure(fig)
    clf
end
orient landscape

%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% 1) stereoplots
if selected.Nulls(2)
    %only if Non-Nulls are also displayed...
    if license('checkout','MAP_Toolbox')
        rowNumbers=3;
    else
        rowNumbers=2;
    end
else
    %skip stereoplots, do not make much sense when only Nulls are displayed
    rowNumbers=2;
end


if rowNumbers==3
    k = [good fair];%poor
    subplot(3,3,7)
    if length(k)>0
        h = stereoplot(back(k), inc(k), phiRC(k), dtRC(k));
        set(h,'Color','b')
    else
        box on
        axis square
        set(gca,'Xtick',[],'Ytick',[])
    end
    % xlabel('Rotation Correlation')
    axis on
    %----------------------------------------------------------
    subplot(3,3,8)
    if length(k)>0
        h = stereoplot(back(k), inc(k), phiSC(k), dtSC(k));
        set(h,'Color','b')
    else
        box on
        axis square
        set(gca,'Xtick',[],'Ytick',[])
    end
    % xlabel('Minimum energy')
    axis on
    % %----------------------------------------------------------
    subplot(3,3,9)
    if length(k)>0
        h = stereoplot(back(k), inc(k), phiEV(k), dtEV(k));
        set(h,'Color','b')
    else
        box on
        axis square
        set(gca,'Xtick',[],'Ytick',[])
    end
    % xlabel('EigenValue')
    axis on
end



%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% 1) Fast axis plots

hlineX=[0 90 nan   0 180 nan  90 270 nan 180 360 nan 270 360 nan 0 360];
hlineY=[0 90 nan -90  90 nan -90  90 nan -90  90 nan -90   0 nan 0   0];

hlineX2=[ 0 45 nan   0 135 nan   45 225 nan 135 315 nan 225 360 nan 315 360];
hlineY2=[45 90 nan -45  90 nan  -90  90 nan -90  90 nan -90  45 nan -90 -45];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(rowNumbers, 3, 1);
cla
box on
title('Rotation-Correlation')
xlim([0 360])
ylim([-90 90])
hold on
if selected.NullLines
    plot(hlineX,hlineY,'-','color',[1 1 1] *.0 ,'Handlevisibility','off')
    plot(hlineX2,hlineY2,':','color',[1 1 1] *.0,'Handlevisibility','off')
end
t(1) = plot(0:359,zeros(1,360),'color', defcol, 'Linestyle', defstyle, 'Linewidth',defwidth, 'Visible','off','Tag','phi_theoreticLine');

plot (back(poor), phiRC(poor),  poorMarker, 'MarkerSize', 5 )
plot (back(fair), phiRC(fair),  fairMarker, 'MarkerSize', 5 )
plot(back(fairN), phiRC(fairN), fairNMarker, 'MarkerSize', 4 )
plot( back(goodN),phiRC(goodN), goodNMarker,'MarkerSize', 4 )
plot( back(good), phiRC(good),  goodMarker, 'MarkerSize', 5 )
hold off
set(gca, 'XMinortick', 'on', 'Xtick', [-0:45:360], 'Ytick', [-90:30:90], 'YMinortick', 'on','FontSize',FontSize)

ylabel('Fast axis')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(rowNumbers, 3, 2);
cla
box on
title('Minimum Energy')
xlim([0 360])
ylim([-90 90])
hold on
if selected.NullLines
    plot(hlineX,hlineY,'-','color',[1 1 1] *.0 ,'Handlevisibility','off')
    plot(hlineX2,hlineY2,':','color',[1 1 1] *.0,'Handlevisibility','off')
end
t(2) = plot(0:359,zeros(1,360),'color', defcol, 'Linestyle', defstyle, 'Linewidth',defwidth, 'Visible','off','Tag','phi_theoreticLine');

plot (back(poor), phiSC(poor), poorMarker, 'MarkerSize', 5 )
plot (back(fair), phiSC(fair), fairMarker, 'MarkerSize', 5 )
plot(back(fairN),phiSC(fairN), fairNMarker,'MarkerSize', 4 )
plot(back(goodN),phiSC(goodN), goodNMarker,'MarkerSize', 4 )
plot(back(good), phiSC(good),  goodMarker, 'MarkerSize', 5 )
hold off
set(gca, 'XMinortick', 'on', 'Xtick', [-0:45:360], 'Ytick', [-90:30:90], 'YMinortick', 'on','FontSize',FontSize)

ylabel(config.stnname)

Label = xlabel(' ', 'FontWeight', 'Demi');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(rowNumbers, 3, 3);
cla
box on
title('Eigenvalue method')
xlim([0 360])
ylim([-90 90])
hold on
if selected.NullLines
    plot(hlineX,hlineY,'-','color',[1 1 1] *.0 ,'Handlevisibility','off')
    plot(hlineX2,hlineY2,':','color',[1 1 1] *.0,'Handlevisibility','off')
end
t(3) = plot(0:359,zeros(1,360),'color', defcol, 'Linestyle', defstyle, 'Linewidth',defwidth, 'Visible','off','Tag','phi_theoreticLine');

plot (back(poor), phiEV(poor), poorMarker, 'MarkerSize', 5 )
plot (back(fair), phiEV(fair), fairMarker, 'MarkerSize', 5 )
plot(back(fairN),phiEV(fairN), fairNMarker,'MarkerSize', 4 )
plot(back(goodN),phiEV(goodN), goodNMarker,'MarkerSize', 4 )
plot(back(good), phiEV(good),  goodMarker, 'MarkerSize', 5 )
hold off
set(gca, 'XMinortick', 'on', 'Xtick', [-0:45:360], 'Ytick', [-90:30:90], 'YMinortick', 'on','FontSize',FontSize)

ylabel(config.stnname)







%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% Delay time plots

subplot(rowNumbers, 3, 4, 'Layer','Top');
cla
box on
hold on

t(4) = plot(0:359,zeros(1,360),'color', defcol, 'Linestyle', defstyle, 'Linewidth',defwidth, 'Visible','off','Tag','phi_theoreticLine');

plot (back(poor),  dtRC(poor),  poorMarker, 'MarkerSize', 5 )
plot(  back(fair), dtRC(fair),  fairMarker, 'MarkerSize', 5 )
plot(back(fairN),  dtRC(fairN), fairNMarker,'MarkerSize', 4 )
plot(back(goodN),  dtRC(goodN), goodNMarker,'MarkerSize', 4 );
plot( back(good),  dtRC(good),  goodMarker, 'MarkerSize', 5 );

hold off
set(gca,  'XMinortick', 'on', 'Xtick', [0:45:360], 'Ytick', [0:4],'FontSize',FontSize)
axis([0 360 0 4])

ylabel('delay time')
xlabel('Backazimuth')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(rowNumbers, 3, 5, 'Layer','Top');
cla
box on
hold on

t(5) = plot(0:359,zeros(1,360),'color', defcol, 'Linestyle', defstyle, 'Linewidth',defwidth, 'Visible','off','Tag','phi_theoreticLine');

plot (back(poor), dtSC(poor),  poorMarker, 'MarkerSize', 5 )
plot( back(fair), dtSC(fair),  fairMarker, 'MarkerSize', 5 )
plot(back(fairN), dtSC(fairN), fairNMarker,'MarkerSize', 4 )
plot(back(goodN), dtSC(goodN), goodNMarker,'MarkerSize', 4 );
plot(back(good),  dtSC(good),  goodMarker, 'MarkerSize', 5 );

set(gca,  'XMinortick', 'on', 'Xtick', [0:45:360], 'Ytick', [0:4],'FontSize',FontSize)
axis([0 360 0 4])


xlabel('Backazimuth')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(rowNumbers, 3, 6, 'Layer','Top');
cla
box on
hold on


t(6) = plot(0:359,zeros(1,360),'color', defcol, 'Linestyle', defstyle, 'Linewidth',defwidth, 'Visible','off','Tag','phi_theoreticLine');

plot (back(poor), dtEV(poor),  poorMarker, 'MarkerSize', 5 )
plot( back(fair), dtEV(fair),  fairMarker, 'MarkerSize', 5 )
plot(back(fairN), dtEV(fairN), fairNMarker,'MarkerSize', 4 )
plot(back(goodN), dtEV(goodN), goodNMarker,'MarkerSize', 4 );

plot(back(good),  dtEV(good),  goodMarker, 'MarkerSize', 5 );

set(gca,  'XMinortick', 'on', 'Xtick', [0:45:360], 'Ytick', [0:4],'FontSize',FontSize)
axis([0 360 0 4])
xlabel('Backazimuth')

%% LEGEND XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% make invisible markers, to assure that all legend entries are plot, even if not present in diagram
e = plot(0,0, goodMarker,    0,0,fairMarker,  0,0,poorMarker,   0,0, goodNMarker,   0,0,fairNMarker,  'Visible', 'off');

hold off
L=legend(e,'good splitting','fair splitting','poor'  ,'good Null' , 'fair Null','Orientation','horizontal');
Pos = get(L,'Position');
Pos(1:3)=[.2 .05 .6];
Pos(1:3)=[.2 .01 .6];
set(L,'Position',Pos),





%%--------------------------------------------------
if selected.theoLines
    set(t,'Visible','on')
end
handles = guidata(gcbf);
handles.theoLines = [t(1:3); t(4:6)]';
handles.Label = Label;
guidata(gcbf, handles)


drawTheoreticLines












%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

if selected.Nulls(2)
%only if Non-Nulls are also displayed...


    tit =['Theoretic distribution' ];
    fig = findobj('type', 'figure','Name', tit);
    if isempty(fig)
        figure('NumberTitle', 'Off',...
            'Name', tit,...
            'PaperUnits','inches',...
            'PaperOrientation','portrait',...
            'PaperPosition',[0.25 2.5  7.5 3.5 ],...
            'FileName',        [config.project(1:end-4) 'TheoStereo'],...
            'PaperType',       config.PaperType)
    else
        figure(fig)
        clf
    end



    subplot(1,2,1)
    k = [good fair  goodN fairN ];
    NN=(length([good fair])+1):length(k);

    if length(k)>0
        [h,m] = stereoplot(back(k), inc(k), phiSC(k), dtSC(k), NN);
        set(h,'Color','b')
    else
        box on
        axis square
        set(gca,'Xtick',[],'Ytick',[])
    end
    xlabel('Minimum energy')
    axis on
    %theoretic distribution
    subplot(1,2,2)
    handles = guidata(gcbf);
    phi1 = get(handles.Layer1Phi, 'Value');
    phi2 = get(handles.Layer2Phi, 'Value');
    dt1  = get(handles.Layer1dt, 'Value');
    dt2  = get(handles.Layer2dt, 'Value');
    period = get(handles.period, 'Value');

    bazi=0:7.5:179;
    [phi0, dt0]=twolayermodel(bazi, phi1,dt1, phi2, dt2, period);

    phi0 = [phi0; phi0];
    dt0  = [dt0; dt0];
    bazi = [bazi, bazi+180]';

    inc =ones(size(bazi))*10; %default 10deg inclination

    h = stereoplot(bazi, inc, phi0, dt0);
    set(h,'Color','b')

    xlabel('theoretic distribution')
    axis on



    %make invisible axis for title:
    hold on
    aa=axes;
    ttt=title('dummy');
    axis off
    hold off


    valuestring ={sprintf('Upper Layer: %3.0f\circ, %.1fs', phi2, dt2);
        sprintf('Lower Layer: %3.0f\circ, %.1fs', phi1, dt1)};

    set(ttt, 'string', valuestring, 'visible','on')
end






