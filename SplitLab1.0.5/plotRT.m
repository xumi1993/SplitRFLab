function plotRT(Datapath,imout,Station,timelength1)

global config


Station=char(Station);
[s.event s.phase s.evlat s.evlon s.evdep s.dis s.bazi s.rayp s.magnitude s.f0]=textread([Datapath '/' Station '/' Station 'finallist.dat'],'%s %s %f %f %f %f %f %f %f %f',-1);
[s.bazi,idx]=sort(s.bazi);
s.event=s.event(idx);
s.phase=s.phase(idx);
s.evlat=s.evlat(idx);
s.evlon=s.evlon(idx);
s.evdep=s.evdep(idx);
s.dis=s.dis(idx);
s.rayp=s.rayp(idx);
s.magnitude=s.magnitude(idx);
EV_num=length(s.evdep);

%% read RF data
m=1;
while 1
    if m==EV_num+1
    break,end;
filename=s.event(m,:);
disp(char(filename));
datafile=strcat([Datapath '/' Station '/'],filename,'_',s.phase(m,:),'_R.dat');datafile1=strcat([Datapath '/' Station '/'],filename,'_',s.phase(m,:),'_T.dat');
datar(:,m)=load(char(datafile));datat(:,m)=load(char(datafile1));
m=m+1;
end

RFlength=length(datar(:,1));
backazimuth=num2str(s.bazi,'%5.1f\n');
distance=num2str(s.dis,'%5.1f\n');
raypara=num2str(s.rayp,'%5.3f\n');
% average
receivermean=mean(datar,2);
receivermean1=mean(datat,2);
datar(:,EV_num+3)=receivermean;datat(:,EV_num+3)=receivermean1;
for i=4:6
    datar(:,EV_num+i)=0;
    datat(:,EV_num+i)=0;
end

%% plot waveforms
h=figure(99);orient landscape;
set(h,'Position',[500 0 800 600]);hold on;
shift = 10;
plotpara = 1;
enf = 5;%enlarge factor for waveforms
sampling = (config.extime_before + config.extime_after) / (RFlength - 1);

receiver=zeros(RFlength,1);receiver1=zeros(RFlength,1);
Timeaxis = (0:1:RFlength-1)*sampling - shift;%Time axis
%1st step-fill color   
   m=1;
while 1
    if m==EV_num+6
        break,end;
    receiver=datar(:,m);receiver1=datat(:,m);pos=zeros(RFlength,1);pos1=zeros(RFlength,1);neg=zeros(RFlength,1);neg1=zeros(RFlength,1);     
   %fill color:
   for i=1:RFlength
        if receiver(i)>0
            pos(i)=receiver(i)*enf;
        elseif receiver(i)<0
            neg(i)=receiver(i)*enf;
        end
        if receiver1(i)>0
            pos1(i)=receiver1(i)*enf;
        elseif receiver1(i)<0
            neg1(i)=receiver1(i)*enf;
        end
   end
    fillpos=pos+1.0*m;fillpos1=pos1+1.0*m;
    fillneg=neg+1.0*m;fillneg1=neg1+1.0*m;
    receiver=receiver*enf+1.0*m;receiver1=receiver1*enf+1.0*m;      
    yy = m*ones(1,RFlength);
    h1=subplot(1,3,1);
    hold on;
    posX=[Timeaxis,fliplr(Timeaxis)];posY=[fillpos',fliplr(yy)];
    fill(posX,posY,'r','EdgeColor','none','LineStyle','none');
    negX=[Timeaxis,fliplr(Timeaxis)];negY=[fillneg',fliplr(yy)];
    fill(negX,negY,'b','EdgeColor','none','LineStyle','none');
    box on; 
    h2=subplot(1,3,2);
    hold on;
     posX1=[Timeaxis,fliplr(Timeaxis)];posY1=[fillpos1',fliplr(yy)];
    fill(posX1,posY1,'r','EdgeColor','none','LineStyle','none');
    negX1=[Timeaxis,fliplr(Timeaxis)];negY1=[fillneg1',fliplr(yy)];
    fill(negX1,negY1,'b','EdgeColor','none','LineStyle','none');box on; 
    

     m=m+1;    
end

m=1;
while 1
    if m==EV_num+6
        break,end;
    receiver=datar(:,m);receiver1=datat(:,m);pos=zeros(RFlength,1);pos1=zeros(RFlength,1);neg=zeros(RFlength,1);neg1=zeros(RFlength,1); 
    receiver=receiver*enf+1.0*m;receiver1=receiver1*enf+1.0*m; 

   %plot lines:
        hold on;plot(h1,Timeaxis,receiver,'black','lineWidth',0.2,'Visible','off');
        hold on;plot(h2,Timeaxis,receiver1,'black','lineWidth',0.2,'Visible','off'); 

     m=m+1;    
end

%% figure configurations
    %title('R & T components','FontSize',16,'FontName','Cambria','FontAngle','italic','FontWeight','bold','Color','red') 
    %set(gca,'ytick',[1 3 5 7]);%set(gca,'ytick',[]);%set(gca,'xtick',[0.04 0.05 0.06 0.07 0.08]);
    %change=[0.04 0.05 0.06
    %0.07];set(gca,'yticklabel',change);%set(gca,'YDir','reverse');%set(gca,'XAxisLocation','top');
 h3=subplot(1,3,3); evnum=(1:1:EV_num);
plot(s.bazi,evnum,'o','Markersize',5.0);set(h3,'xtick',[0:60:360],'ytick',[],'ylim',[0 m],'xlim',[0 360]);box on;xlabel(h3,['Backazimuth (' '\circ' ')'],'FontSize',16);
set(h3, 'XGrid','on','lineWidth',1);
xlabel(h1,'Time after P (s)','FontSize',16);ylabel(h1,'Event','FontSize',16);title(h1,['R components' ' (' Station ')'],'FontSize',18,'FontName','Times new roman');
xlabel(h2,'Time after P (s)','FontSize',16);ylabel(h2,['Backazimuth (' '\circ' ')'],'FontSize',16);title(h2,['T components' ' (' Station ')'],'FontSize',18,'FontName','Times new roman');
set(h1,'xtick',[0:2*plotpara:timelength1],'xlim',[-2 plotpara*timelength1],'ylim',[0 m],'xticklabel',[0:2*plotpara:plotpara*timelength1],'FontSize',6);set(h1, 'XGrid','on','lineWidth',0.4);
set(h1,'ytick',[1:1:EV_num]);set(h1,'yticklabel',s.event([1:1:EV_num],:));
set(h2,'xtick',[0:2*plotpara:timelength1],'xlim',[-2 plotpara*timelength1],'ylim',[0 m],'xticklabel',[0:2*plotpara:plotpara*timelength1],'FontSize',6);set(h2, 'XGrid','on','lineWidth',0.4);
set(h2,'ytick',[1:1:EV_num]);set(h2,'yticklabel',backazimuth);
plot(h1,[0,0],[0,m],'-','linewidth',1.0,'color','k');plot(h2,[0,0],[0,m],'-','linewidth',1.0,'color','k');
set(gcf,'PaperPositionMode', 'manual');
set(gcf,'PaperUnits','points');
set(gcf, 'PaperPosition', [20 0 800 600]);
button1 = MFquestdlg( [ 0.4 , 0.12 ] ,'Do you want to save the plot ?','plot',  ...
     'Yes','No','Yes');
 if strcmp(button1, 'Yes')
     
% print(h,'-dpdf',  ['/Volumes/LaCie/YN.RFunction/plotRT' Station 'RT_bazorder_' num2str(plotpara) '.pdf'])
print(h,'-dpdf',  [imout '/' Station 'RT_bazorder_' num2str(plotpara) '_' num2str(s.f0(1)) '.pdf'])
 end