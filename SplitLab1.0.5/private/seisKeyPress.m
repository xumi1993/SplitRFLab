function seisKeyPress(src,evnt,seis)
% handle keypress within Splitlab seismmogram plot

global thiseq eq config
% local filter is temporary filter structure, filt structure in calling
% function will be assigned to the new value
f1 = thiseq.filter(1);
f2 = thiseq.filter(2);



if strcmp(evnt.Key,'`')
    return

elseif strcmp(evnt.Key,'return')
    if ~isfield(thiseq, 'a')|| (isempty(thiseq.a) && isempty(thiseq.f)) 
        errordlg('no time window picked... Sorry, can''t split','Error')
        return
    else
        preSplit
        return
    end
%% STILL A bug in seismogram order 08.05.06    
% elseif strcmp(upper(evnt.Key),'L')
%     %lock aspect
%seismo  = findobj('Tag','seismo');
%     lockbut = findobj('Type','uitoggletool','Tag','LockButton');
%     switch get(lockbut,'State')
%         case 'on'%lock to common Y-limits
%             for k=1:3
%                 yyy(k,:)   =get(get(seis(k),'Parent'),'YLim');
%             end
%             yyy =[min(yyy(:,1)) max(yyy(:,2))];
%             for k=1:3
%                 set(get(seis(k),'Parent'), 'YLim',yyy,'YLimMode','manual')
%             end
%             set(lockbut ,'State','off','Cdata',getfield(get(lockbut ,'UserData'),'locked'))
%         case 'off'%unlock Y-limits
%             for k=1:3
%                 set(get(seis(k),'Parent'),'YLimMode','auto')
%             end
%             set(lockbut,'State','on','Cdata',getfield(get(lockbut,'UserData'),'unlocked'))
%     end
%     
%     
elseif strcmp(evnt.Key,'tab')|strcmp(evnt.Key,'escape')
    %jump close to selected phase
    val  = get(findobj('Tag','PhaseSelector'),'Value');
    t_home = floor(thiseq.phase.ttimes(val)/10)*10 - 18; %~30 seconds before phase; at full 10 seconds
    xlim([t_home t_home+65]) % timewindow of 150 sec

elseif strcmp(evnt.Key,'[')
    xx = xlim;
    xlim(xx-diff(xx)/5)

elseif strcmp(evnt.Key,']')
    xx=xlim;
    xlim(xx+diff(xx)/5)
elseif strcmp(evnt.Key,'backspace')
    xlim('auto')
% elseif strcmp(evnt.Key,'m')
%     Aniso_multi;
elseif strcmp(evnt.Key,'r')
    if config.issac
        PS_RF_sac
    else
        PS_RF
    end
elseif strcmp(evnt.Key,'v')
    cutwave
elseif strcmp(evnt.Key,'e')
    PS_RecFunc_TZ
elseif strcmp(evnt.Key,'d')
    PS_RecFunc_Water

elseif strcmp(evnt.Key,'z') 
    idx = thiseq.index-1; if idx < 1; idx = length(eq);end; seis=SL_SeismoViewer(idx); clear idx; 
    f1 = thiseq.filter(1);
    f2 = thiseq.filter(2);
elseif strcmp(evnt.Key,'c') 
    idx = thiseq.index+1; 
    if idx > length(eq) 
       idx =1;
       button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
          close(figure(2));close(figure(3));close(figure(4));clear idx;return;
       else
           seis=SL_SeismoViewer(idx); clear idx;
       end
    else
        seis=SL_SeismoViewer(idx); clear idx;
    end
    f1 = thiseq.filter(1);
    f2 = thiseq.filter(2);
else

    switch evnt.Character
%         case 'p'
%             polarisation2006
%             return
        case 'f'
            [f1, f2] = filterdialog(thiseq.filter);
        case '0'
            f1 = 0;z
            f2 = inf;
        case '1'
            f1 = 0.03;
            f2 = 2;
        case '2'
            f1 = 0.03;
            f2 = 1;
        case '3'
            f1 = 0.03;
            f2 = 0.5;
        case '4'
            f1 = 0.03;
            f2 = 0.25;
        case '5'
            f1 = 0.03;
            f2 = 1/6;
        case '6'
            f1 = 0.05;
            f2 = 0.2;
        case '7'
            f1 = 0.04;
            f2 = 0.125;
         case '8'
            f1 = 0.04;
            f2 = 0.15;
        case '9'
            f1 = 0.04;
            f2 = 0.2;
        case 'q'
            f1 = 0.1;
            f2 = 2;
        case 'w'
            f1 = 0.1;
            f2 = 1; 
        case 'a'
            f1 = 0.05;
            f2 = 2;
        case 's'
            f1 = 0.05;
            f2 = 1;

        case '+'
            f1  = f1 + 0.01;
            if f1  >= f2
                f1 = f2-0.01;
            elseif f2  <= f1
                f1 = f1 - 0.01;
            end
        case '-'
            f1  = f1 - 0.01;
            if f1  < 0
                f1 = 0;
            end
        case '*'
            f2  = f2 + 0.02;
        case '/'
            f2  = f2 - 0.02;
            if f2  < 0
                f2 = 0;
            elseif f2  <= f1
                f2 = f1 + 0.002;
            end

        case ' ' %space
            % rotate system
            button=findobj('Tag','SystemButton');
            if thiseq.system=='ENV';
                thiseq.system='LTQ';
                set(button, 'State','On')
            elseif thiseq.system=='LTQ';
                thiseq.system='ENV';
                set(button, 'State','Off')
            end
%             SL_updatefiltered(flipud(findobj('Tag','seismo')))
            return
        case 'x'
            button=findobj('Tag','xzoom');
            if strcmp(get(button, 'State'),'off')
                xzoomON(src,seis)
                set(button, 'State','On')
            elseif strcmp(get(button, 'State'),'on')
               xzoomOFF(src,seis)
               set(button, 'State','off')
            end
        case 'b'
            t   = get(seis(2),'xData');
            x   = xlim;
            xx  = diff(x/2);
            xxx = x+[-xx xx];
            if xxx(1) < t(1);   xxx(1) = t(1);   end
            if xxx(2) > t(end); xxx(2) = t(end); end

            subax=findobj('Type','Axes','Parent',gcbf);
            set(subax(4),'xlim', round(xxx))
    end %switch
end %else

thiseq.filter = [f1 f2]; %update variable filt in caller function
set(gcbf,'KeyPressFcn',{@seisKeyPress,seis})

%% filtering and display...
SL_updatefiltered(seis);
