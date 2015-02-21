function xzoomON(src,seismo)
ud.down=get(gcbf,'WindowButtonDownFcn');
ud.up  =get(gcbf,'WindowButtonUpFcn');
ud.motion=get(gcbf,'WindowButtonMotionFcn');
set(src,'Userdata',ud);
s=nan;
pointer=[
    s s s s 1 1 1 1 s s s s s s s s
    s s 1 1 s 2 s 2 1 1 s s s s s s
    s 1 2 s 2 s 2 s 2 s 1 s s s s s
    s 1 s 2 s 1 1 2 s 2 1 s s s s s
    1 s 2 s 2 1 1 s 2 s 2 1 s s s s
    1 2 s 1 1 1 1 1 1 2 s 1 s s s s
    1 s 2 1 1 1 1 1 1 s 2 1 s s s s
    1 2 s 2 s 1 1 2 s 2 s 1 s s s s
    s 1 2 s 2 1 1 s 2 s 1 s s s s s
    s 1 s 2 s 2 s 2 s 2 1 s s s s s
    s s 1 1 2 s 2 s 1 1 1 1 s s s s
    s s s s 1 1 1 1 s s 1 1 1 s s s
    s s s s s s s s s s s 1 1 1 s s
    s 1 s s s s s 1 s s s s 1 1 1 s
    1 1 1 1 1 1 1 1 1 s s s s 1 1 1
    s 1 s s s s s 1 s s s s s s 1 s];
set(gcbf,...
    'WindowButtonDownFcn',{@localZoomSeismo,gcbf,seismo},...
    'WindowButtonUpFcn','',...
    'WindowButtonMotionFcn','',...
    'Pointer','Custom','PointerShapeCData',pointer,'PointerShapeHotSpot',[7 7])
return

function localZoomSeismo(hFig,evt,fig,seismo)
% k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1);              % extract x and y
point2 = point2(1);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
x = [p1(1) p1(1)+offset(1) ];

if x(2)-x(1) < 2
    %prevent exessive zooming smaller than 2seconds
    return
end

subax=findobj('Type','Axes','Parent',gcbf);
set(subax(4),'xlim', round(x(1:2)))
return

function xzoomOFF(hFig,evt,seismo)
ud=get(gcbo,'Userdata');
set(gcbf,...
    'WindowButtonDownFcn',ud.down,...
    'WindowButtonUpFcn',ud.up,...
    'WindowButtonMotionFcn',ud.motion,...
    'Pointer','crosshair')
return

function xzoomOutON(src,evt,seismo)
t   = get(seismo(2),'xData');
x   = xlim;
xx  = diff(x/2);
xxx = x+[-xx xx];
if xxx(1) < t(1);   xxx(1) = t(1);   end
if xxx(2) > t(end); xxx(2) = t(end); end

subax=findobj('Type','Axes','Parent',gcbf);
set(subax(4),'xlim', round(xxx))
