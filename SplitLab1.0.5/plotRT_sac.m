function plotRT_sac

global config

%% read sac
path = fullfile(config.RFdatapath,config.stnname);
sac_all = dir(fullfile(path,'*R.sac'));
dat = struct();
for i = 1:length(sac_all)
    sacname = regexpi(sac_all(i).name,'\d+\W\d+\W\d+\W\d+\W\d+','match');
    nowsac = rsac(fullfile(path,sac_all(i).name));
    phase = strtrim(lh(nowsac,'KT1'));
    disp(char(sacname))
    dat(i).name = sacname;
    dat(i).R = nowsac(:,2);
    nowsac = rsac(fullfile(path,[char(sacname) '_' char(phase) '_T.sac']));
    dat(i).T = nowsac(:,2);
    dat(i).rayp = lh(nowsac,'USER0');
    dat(i).bazi = lh(nowsac,'BAZ');   
end
f0 = num2str(lh(nowsac,'USER1'),'%5.1f');
%% sort by bazi
EV_num = length(dat);
bazi = zeros(EV_num,1);
for i = 1:EV_num
    bazi(i) = dat(i).bazi;
end
[bazi,idx] = sort(bazi);
backazimuth=num2str(bazi,'%5.1f\n');
dat = dat(idx);
RFlength = length(dat(1).R);
datar = zeros(RFlength,EV_num);
datat = zeros(RFlength,EV_num);
event = cell(EV_num,1);
for i = 1:EV_num
    datar(:,i) = dat(i).R;
    datat(:,i) = dat(i).T;
    event(i) = dat(i).name;
end


%% poltting wave
h=figure(99);orient landscape;
set(h,'Position',[500 0 800 600]);hold on;
shift = config.extime_before;
plotpara = 1;
enf = 5;%enlarge factor for waveforms
sampling = (config.extime_before + config.extime_after) / (RFlength - 1);    

Timeaxis = (0:1:RFlength-1)*sampling - shift;


%1st step-fill color   
   m=1;
while 1
    if m==EV_num+1
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
%     receiver=receiver*enf+1.0*m;receiver1=receiver1*enf+1.0*m;      
    yy = m*ones(1,RFlength);
    h1=subplot(2,3,4);
    hold on;
    posX=[Timeaxis,fliplr(Timeaxis)];posY=[fillpos',fliplr(yy)];
    fill(posX,posY,'r','EdgeColor','none','LineStyle','none');
    negX=[Timeaxis,fliplr(Timeaxis)];negY=[fillneg',fliplr(yy)];
    fill(negX,negY,'b','EdgeColor','none','LineStyle','none');
    box on; 
    h2=subplot(2,3,5);
    hold on;
     posX1=[Timeaxis,fliplr(Timeaxis)];posY1=[fillpos1',fliplr(yy)];
    fill(posX1,posY1,'r','EdgeColor','none','LineStyle','none');
    negX1=[Timeaxis,fliplr(Timeaxis)];negY1=[fillneg1',fliplr(yy)];
    fill(negX1,negY1,'b','EdgeColor','none','LineStyle','none');box on; 
    
    m=m+1;    
end
%% plotting mean
datar_mean = mean(datar,2);
maxr = max(datar_mean);
datar_mean = datar_mean/maxr;
datat_mean = mean(datat,2);
datat_mean = datat_mean/maxr;

% h4 = subplot(2,3,1);
receiver=datar_mean;receiver1=datat_mean;pos=zeros(RFlength,1);pos1=zeros(RFlength,1);neg=zeros(RFlength,1);neg1=zeros(RFlength,1); 
for i=1:RFlength
    if receiver(i)>0
        pos(i)=receiver(i);
    elseif receiver(i)<0
        neg(i)=receiver(i);
    end
    if receiver1(i)>0
        pos1(i)=receiver1(i);
    elseif receiver1(i)<0
        neg1(i)=receiver1(i);
    end
end
fillpos=pos;fillpos1=pos1;
fillneg=neg;fillneg1=neg1;
yy = zeros(1,RFlength);
h4 = subplot(2,3,1);
hold on;
posX=[Timeaxis,fliplr(Timeaxis)];posY=[fillpos',fliplr(yy)];
fill(posX,posY,'r','EdgeColor','none','LineStyle','none');
negX=[Timeaxis,fliplr(Timeaxis)];negY=[fillneg',fliplr(yy)];
fill(negX,negY,'b','EdgeColor','none','LineStyle','none');
box on; 
text(-7,0,'Sum');
h5 = subplot(2,3,2);
hold on;
posX=[Timeaxis,fliplr(Timeaxis)];posY=[fillpos1',fliplr(yy)];
fill(posX,posY,'r','EdgeColor','none','LineStyle','none');
negX=[Timeaxis,fliplr(Timeaxis)];negY=[fillneg1',fliplr(yy)];
fill(negX,negY,'b','EdgeColor','none','LineStyle','none');
box on; 
text(-7,0,'Sum');

%% figure beauty
h3=subplot(2,3,6); evnum=(1:1:EV_num);
plot(bazi,evnum,'o','Markersize',5.0);set(h3,'xtick',[0:60:360],'ytick',[],'ylim',[0 m+2],'xlim',[0 360]);box on;xlabel(h3,['Backazimuth (' '\circ' ')'],'FontSize',16);
set(h3, 'XGrid','on','lineWidth',1);title(h3,'Backazimuth of events','FontSize',18,'FontName','Times new roman');
xlabel(h1,'Time after P (s)','FontSize',16);ylabel(h1,'Event','FontSize',16);title(h4,['R components' ' (' config.stnname ')'],'FontSize',18,'FontName','Times new roman');
xlabel(h2,'Time after P (s)','FontSize',16);ylabel(h2,['Backazimuth (' '\circ' ')'],'FontSize',16);title(h5,['T components' ' (' config.stnname ')'],'FontSize',18,'FontName','Times new roman');
set(h1,'xtick',[0:2*plotpara:config.timeafterp],'xlim',[-2 plotpara*config.timeafterp],'ylim',[0 m+2],'xticklabel',[0:2*plotpara:plotpara*config.timeafterp],'FontSize',6);set(h1, 'XGrid','on','lineWidth',0.4);
set(h1,'ytick',[1:1:EV_num]);set(h1,'yticklabel',event([1:1:EV_num],:));
set(h2,'xtick',[0:2*plotpara:config.timeafterp],'xlim',[-2 plotpara*config.timeafterp],'ylim',[0 m+2],'xticklabel',[0:2*plotpara:plotpara*config.timeafterp],'FontSize',6);set(h2, 'XGrid','on','lineWidth',0.4);
set(h2,'ytick',[1:1:EV_num]);set(h2,'yticklabel',backazimuth);
plot(h1,[0,0],[0,m+4],'-','linewidth',1.0,'color','k');plot(h2,[0,0],[0,m+4],'-','linewidth',1.0,'color','k');
set(h4,'xtick',[0:2*plotpara:config.timeafterp],'xlim',[-2 plotpara*config.timeafterp],'xticklabel',[],'ylim',[-1 1.2],'ytick',[],'XGrid','on','lineWidth',0.4);
set(h5,'xtick',[0:2*plotpara:config.timeafterp],'xlim',[-2 plotpara*config.timeafterp],'xticklabel',[],'ylim',[-1 1.2],'ytick',[],'XGrid','on','lineWidth',0.4);
plot(h4,[0,0],[-2,2],'-','linewidth',1.0,'color','k');
plot(h5,[0,0],[-2,2],'-','linewidth',1.0,'color','k');
pos1 = get(h1,'Position');pos2 = get(h2,'Position');pos3 = get(h3,'Position');pos4 = get(h4,'Position');pos5 = get(h5,'Position');
newpos1 = [pos1(1),pos1(2),pos1(3),pos1(4)+0.4];
newpos2 = [pos2(1),pos2(2),pos2(3),pos2(4)+0.4];
newpos3 = [pos3(1),pos3(2),pos3(3),pos3(4)+0.4];
newpos4 = [pos4(1),pos4(2)+0.28,pos4(3),pos4(4)-0.28];
newpos5 = [pos5(1),pos5(2)+0.28,pos5(3),pos5(4)-0.28];
set(h1,'Position',newpos1);
set(h2,'Position',newpos2);
set(h3,'Position',newpos3);
set(h4,'Position',newpos4);
set(h5,'Position',newpos5);
%% output

outpath = fullfile(config.imout,[config.stnname 'RT_bazorder_' num2str(plotpara) '_' f0 '.pdf']);
button1 = MFquestdlg( [ 0.4 , 0.12 ] ,'Do you want to save the plot ?','plot',  ...
     'Yes','No','Yes');
if strcmp(button1, 'Yes')
    print(h,'-dpdf', outpath);
end
return