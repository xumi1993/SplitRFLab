function plotR_P4old(Datapath,OUT_path,h1,h2,k1,k2,sh1,sh2,sk1,sk2,Constantvp)

global config

%% set para
shift = 10;
enf = 0.005;
rayprange=0.03:0.001:0.084;
Moho = h1:0.1:h2;
kappa = k1:0.01:k2;
weight = [ config.weight1, config.weight2, config.weight3 ] ;% weighting matrix
linecolor=[0.94 0.27 0.2];
%% read data

if config.issac
path = fullfile(Datapath,config.stnname);
sac_all = dir(fullfile(path,'*R.sac'));
dat = struct();
for i = 1:length(sac_all)
    sac_split = regexp(sac_all(i).name,'_','split');
    sacname = sac_split(1);
    nowsac = rsac(fullfile(path,sac_all(i).name));
    dat(i).name = sacname;
    dat(i).R = nowsac(:,2);
    dat(i).rayp = lh(nowsac,'USER0');
    dat(i).bazi = lh(nowsac,'BAZ');    
end
EV_num = length(dat);
rayp = zeros(EV_num,1);
for i = 1:EV_num
    rayp(i) = dat(i).rayp;
end
[rayp,idx] = sort(rayp);
dat = dat(idx);
RFlength = length(dat(1).R);
datar = zeros(RFlength,EV_num);
for i = 1:EV_num
    disp([char(dat(i).name) ' --s.event number: ' num2str(i)]);
    datar(:,i) = dat(i).R;
end
 
else

[s.event s.phase s.evlat s.evlon s.evdep s.dis s.bazi s.rayp s.magnitude s.f0]=textread([Datapath '\' config.stnname '\' config.stnname 'finallist.dat'],'%s %s %f %f %f %f %f %f %f %f',-1);
%sort by rayp
[rayp, idx]=sort(s.rayp);
s.event=s.event(idx);
s.phase=s.phase(idx);
s.evlat=s.evlat(idx);
s.evlon=s.evlon(idx);
s.evdep=s.evdep(idx);
s.dis=s.dis(idx);
s.bazi=s.bazi(idx);
s.magnitude=s.magnitude(idx);

EV_num=length(s.evdep);
backazimuth=num2str(s.bazi,'%5.1f\n');
distance=num2str(s.dis,'%5.1f\n');
raypara=num2str(s.rayp,'%5.3f\n');

m=1;
while 1
    if m==EV_num+1
    break,end;
filename=s.event(m,:);
disp([char(filename) ' --s.event number: ' num2str(m)]);
datafile=strcat([Datapath '\' config.stnname '\'],filename,'_',s.phase(m,:),'_R.dat');
datar(:,m)=load(char(datafile));
m=m+1;
end
RFlength=length(datar(:,1));
end

dataverage=mean(datar,2);
sampling = (config.extime_after + config.extime_before) / (RFlength - 1);


%% H-k stacking
[stack, stackvar, stack_all, stackall_var ] = hkstack_iwb( datar, -shift, sampling, rayp, Moho, kappa, Constantvp,weight );
%[stack_all, stackall_var,besth, bestk] = hkstack(datar,-shift,sampling,s.rayp,Moho,kappa,Constantvp,weight,1,0);
% combine the stacks 
allstack = weight(1)*stack(:,:,1) + weight(2)*stack(:,:,2) + weight(3)*stack(:,:,3);
Normed_stack = allstack - min(min(allstack));
Normed_stack = Normed_stack./max(max(Normed_stack));
sh=find(Moho>sh1 & Moho<sh2);
sk=find(kappa>sk1 & kappa<sk2);
[maxA, i] = max(max(Normed_stack(sk,sh)));
[i,j] = find( Normed_stack == maxA ,1);
besth = Moho(j);
bestk = kappa(i);
fprintf('Best Mohodepth = %.2f km\nBest kappa = %.2f\n', [besth,bestk] );
Temnormed_stack = (Normed_stack(sk,sh))';
cvalue = 1 - std(reshape(Temnormed_stack,1,numel(Temnormed_stack)))/sqrt(EV_num);

eta_p = vslow( Constantvp, rayprange);  % get vp vertical slowness
eta_s = vslow( Constantvp./bestk, rayprange); % get vertical slowness for all vs
TPs = tPs(besth, eta_p, eta_s );
TPpPs = tPpPs(besth, eta_p, eta_s );
TPsPs = tPsPs(besth, eta_s );
%% plot RFs at predicted arrived times for besth and bestk
h=figure(81);orient tall;
set(h,'position',[200 10 400 800]);
hold on;
receiver=zeros(RFlength,1);
time=(0:1:RFlength-1)*sampling - shift;
h1 = subplot(3,1,1);
     hold on;
edgeColor=0.012;
 m=1;
while 1
    if m==EV_num+1
        break,end;
    receiver=datar(:,m); pos=zeros(RFlength,1)+edgeColor;neg=zeros(RFlength,1);   
   %fill color:
   for i=1:RFlength
        if receiver(i)>edgeColor
            pos(i)=receiver(i);
        elseif receiver(i)<0
            neg(i)=receiver(i)*enf;
        end        
   end
    pos=pos*enf;
    fillpos=pos+rayp(m);fillneg=neg+rayp(m);
    yy = rayp(m)*ones(1,RFlength)+edgeColor*enf; 
    hold on
    posX=[time,fliplr(time)];posY=[fillpos',fliplr(yy)];
    fill(posX,posY,[0 0.56 0.76],'EdgeColor','none','LineStyle','none');
%     negX=[time,fliplr(time)];negY=[fillneg',fliplr(yy)];
%     fill(negX,negY,[0.5 0.5 0.5],'EdgeColor','none','LineStyle','none');
    box on;
    m=m+1;
end

m=1;
while 1
    if m==EV_num+1
        break,end;
    receiver=datar(:,m);pos=zeros(RFlength,1);neg=zeros(RFlength,1);
    receiver=receiver*enf+rayp(m);
   %plot lines:
     
    hold on;
    plot(h1,time,receiver,'color',[0.5 0.5 0.5],'lineWidth',0.2);

     m=m+1;    
end
% plot 
hold on;
text(TPs(length(TPs))-0.5,max(rayprange)+0.0015,'Ps','FontSize',14);
text(TPpPs(length(TPs))-1.4,max(rayprange)+0.0015,'PpPs','FontSize',14);
text(TPsPs(length(TPs))-1.6,max(rayprange)+0.0011,'+PsPs','FontSize',14);
text(TPsPs(length(TPs))-1.6,max(rayprange)+0.0028,'PpSs','FontSize',14);

%% plot average
h2 = subplot(3,1,2);
 receiver=dataverage; pos=zeros(RFlength,1)+edgeColor;neg=zeros(RFlength,1);   
   %fill color:
   for i=1:RFlength
        if receiver(i)>edgeColor
            pos(i)=receiver(i);
        elseif receiver(i)<0
            neg(i)=receiver(i);
        end        
   end
   fillpos=pos+1;fillneg=neg+1;
   yy = ones(1,RFlength)+edgeColor; 
    hold on
    posX=[time,fliplr(time)];posY=[fillpos',fliplr(yy)];
    fill(posX,posY,[0 0.56 0.76],'EdgeColor','none','LineStyle','none');
%     negX=[time,fliplr(time)];negY=[fillneg',fliplr(yy)];
%     fill(negX,negY,[0.5 0.5 0.5],'EdgeColor','none','LineStyle','none');
    box on;
 plot(h2,time,receiver+1,'color',[0.5 0.5 0.5],'lineWidth',0.2)
 p2ylim=[min(receiver+1)-min(receiver+1)/10 max(receiver+1)+max(receiver+1)/10];
 text(-4,(p2ylim(1)+p2ylim(2))/2,'sum','FontSize',14)
 
%% H-k maps
h3=subplot(3,1,3);box on
hold on;
imagesc(Moho, kappa, Normed_stack);
load('cyan.mat','cyan');
colormap(cyan);hold on;
% axis square
%contourf(Moho,kappa,stack_all,'LineStyle','none');hold on;%plot the 1-sigma contour
%tempstr = num2str(onesigma);
%onesigma = str2double(tempstr(1:5));
[cc bb] = contour(Moho,kappa,Normed_stack,[cvalue],'ShowText','off','linestyle','-','linewidth',0.7,'linecolor',[.2 .2 .2]);
% cb4 = colorbar('peer',gca);
%clabel(cc,bb,'fontsize',10,'FontName','Arial','color','k','rotation',0)
set(h3,'position',[0.2 0.78 0.75 0.16])
set(h3,'YDir','normal','xlim',[min(Moho) max(Moho)],'ylim',[min(kappa) max(kappa)],...
    'xtick',[min(Moho):10:max(Moho)],'xticklabel',[min(Moho):10:max(Moho)],'FontSize',14,...
    'xminortick','on','yminortick','on','tickdir','out')
% set(h3,'ticklength',[0.03,0.5],'linewidth',1.0,'fontsize',15);
title(h3,config.stnname,'FontSize',18,'FontWeight','bold') 
line([besth besth],ylim, 'LineStyle','--','Color',linecolor,'LineWidth',0.8);line(xlim, [bestk bestk], 'LineStyle','--','Color',linecolor,'LineWidth',0.8); 
plot(besth, bestk,'color', linecolor,'Marker','square', 'MarkerSize',5,'LineWidth',1)
H=num2str(besth);
K=num2str(bestk);
txtloca = floor(length(Moho)/3*2);
text(Moho(txtloca),1.95,strcat('H=',H,' km'),'FontSize',15);
text(Moho(txtloca),1.88,strcat('Vp/Vs=',K),'FontSize',15);
ylabel(h3, 'Vp/Vs','FontSize',15 )
xlabel(h3, 'Depth (km)', 'FontSize',15 )
%% figure configurations
 
set(h2,'position',[0.2 0.66 0.75 0.06])
set(h2,'xtick',[0:2:80],'xlim',[0 config.timeafterp],'ylim',p2ylim,'ytick',[],'xticklabel',[],'yTickLabel',[]) 
set(h2, 'XGrid','on','lineWidth',1);
% ylabel(h2,'sum','FontSize',8);

set(h1,'position',[0.2 0.072 0.75 0.58])
    plot(h1,TPs, rayprange, '--','color', linecolor,  'linewidth',1.5)
   % text(TPs(length(TPs)),max(rayprange)+0.002,'Ps');
    plot(h1,TPpPs, rayprange, '--','color', linecolor, 'linewidth',1.5)
%     text(TPpPs(length(TPs))-0.5,0.084,'PpPs');
    plot(h1,TPsPs, rayprange, '--','color', linecolor, 'linewidth',1.5)
%     text(TPsPs(length(TPs))-1,0.084,'PpSs+PsPs');
    xlabel(h1,'Time after P (s)','FontSize',16);ylabel(h1,'Rayp (s/km)','FontSize',16);
    set(h1,'xtick',[0:2:80],'xlim',[0 config.timeafterp],'ylim',[0.038 0.088],'xticklabel',[0:2:80],'FontSize',14,'ytick',[0.04:0.01:0.08],'tickdir','out');
    set(h1,'YMinorTick','on');
    set(h1, 'XGrid','on','lineWidth',1);
  %  plot(h1,[0,0],[0,s.rayp],'-','linewidth',1.0,'color','k');
%% save plotting
set(gcf,'PaperPositionMode', 'manual');
set(gcf,'PaperUnits','points');
set(gcf, 'PaperPosition', [28 0 350 800]);

 button1 = MFquestdlg( [ 0.4 , 0.12 ] ,'Do you want to save the plot ?','plot',  ...
      'Yes','No','Yes');
if strcmp(button1, 'Yes')
     
% print(h,'-dpdf',  ['/Volumes/LaCie/YN.RFunction/plotRT' config.stnname 'RT_bazorder_' num2str(plotpara) '.pdf'])
 print(h,'-dpdf',  [OUT_path '\' config.stnname '_R_rayp.pdf'])
% saveas(h,['/Users/xumj/Documents/YunNan/plotrayp/' config.stnname '_R_rayp.eps'])
 end 