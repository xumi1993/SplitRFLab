function hkmap(Datapath,OUT_path,mapath,h1,h2,k1,k2,sh1,sh2,sk1,sk2,Constantvp)

global config

shift = 10;
Moho = h1:0.1:h2;
kappa = k1:0.01:k2;
weight = [ config.weight1, config.weight2, config.weight3 ] ;% weighting matrix
linecolor=[0.94 0.27 0.2];

if config.issac 
%% read sac
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
[s.event s.phase s.evlat s.evlon s.evdep s.dis s.bazi s.rayp s.magnitude s.f0]=textread([Datapath '/' config.stnname '/' config.stnname 'finallist.dat'],'%s %s %f %f %f %f %f %f %f %f',-1);
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
%% Read RF data
m=1;
while 1
    if m==EV_num+1
    break,end;
filename=s.event(m,:);
disp([char(filename) ' --s.event number: ' num2str(m)]);
datafile=strcat([Datapath '/' config.stnname '/'],filename,'_',s.phase(m,:),'_R.dat');
datar(:,m)=load(char(datafile));
m=m+1;
end
RFlength=length(datar(:,1));
end

sampling = (config.extime_after + config.extime_before) / (RFlength - 1);
%% H-k stacking 
%----------------------------------------------------------------------
[stack, ~, ~, stackall_var ] = hkstack_iwb( datar, -shift, sampling, rayp, Moho, kappa, Constantvp,weight );
%[stack_all, stackall_var,besth, bestk] = hkstack(datar,-shift,sampling,s.rayp,Moho,kappa,Constantvp,weight,1,0);
% combine the stacks 
allstack = weight(1)*stack(:,:,1) + weight(2)*stack(:,:,2) + weight(3)*stack(:,:,3);
Normed_stack = allstack - min(min(allstack));
Normed_stack = Normed_stack./max(max(Normed_stack));
sh= Moho>sh1 & Moho<sh2;
sk= kappa>sk1 & kappa<sk2;
[maxA, i] = max(max(Normed_stack(sk,sh)));
[i,j] = find( Normed_stack == maxA ,1);
besth = Moho(j);
bestk = kappa(i);
%onesigma = maxA - sqrt(stackall_var(i,j));
fprintf('Best Mohodepth = %.2f km\nBest kappa = %.2f\n', [besth,bestk] );
%Estimate the confidence bounds by the contours at the 1-sigma value
Temnormed_stack = (Normed_stack)';
cvalue = 1 - std(reshape(Temnormed_stack,1,numel(Temnormed_stack)))/sqrt(EV_num);
c = contourc(kappa,Moho,Temnormed_stack,[cvalue cvalue]);
NumContours = find(c(1,:) == cvalue);
    if length(NumContours) == 1
        Maxksig = (max(c(1,2:end)) - min(c(1,2:end)))/2;
        MaxHsig = (max(c(2,2:end)) - min(c(2,2:end)))/2;
    else
        [junk,IndexOfMaxk]=min(abs(c(1,:) - bestk));
        RightContour = find(NumContours < IndexOfMaxk,1,'last');
        if RightContour ~= length(NumContours)
            Maxksig = (max(c(1,NumContours(RightContour)+1:NumContours(RightContour+1)-1)) - min(c(1,NumContours(RightContour)+1:NumContours(RightContour+1)-1)))/2;
            MaxHsig = (max(c(2,NumContours(RightContour)+1:NumContours(RightContour+1)-1)) - min(c(2,NumContours(RightContour)+1:NumContours(RightContour+1)-1)))/2;
        else
            Maxksig = (max(c(1,NumContours(RightContour)+1:end)) - min(c(1,NumContours(RightContour)+1:end)))/2;
            MaxHsig = (max(c(2,NumContours(RightContour)+1:end)) - min(c(2,NumContours(RightContour)+1:end)))/2;
        end
    end


%% Calculate the predicted travel times at the best estimated Mohodepth and Kappa 
eta_p = vslow( Constantvp,rayp);  % get vp vertical slowness
eta_s = vslow( Constantvp./bestk, rayp); % get vertical slowness for all vs
TPs = tPs(besth, eta_p, eta_s );
TPpPs = tPpPs(besth, eta_p, eta_s );
TPsPs = tPsPs(besth, eta_s );
%% plot H-kappa stacking map
h=figure(81);
subplot(2,2,1)
imagesc(Moho, kappa, stack(:,:,1)); hold on;
load('cyan.mat','cyan');
colormap(cyan);hold on;
plot( besth, bestk, 'wx', 'MarkerSize',10,'LineWidth',1.5,'Color',linecolor)
axis square
cb1 = colorbar('peer',gca);
set(gca,'YDir','normal','xlim',[h1 h2],'xminortick','on','yminortick','on')
set(gca,'ticklength',[0.03,0.5],'linewidth',1.0,'fontsize',15);
ylabel( 'Vp/Vs', 'FontSize',16 )
xlabel( 'H (km)', 'FontSize',16 )
title('Ps',  'fontname','Times new roman','FontSize',16)

subplot(2,2,2)
imagesc(Moho, kappa, stack(:,:,2)); hold on;
colormap(cyan);hold on;
plot( besth, bestk, 'wx', 'MarkerSize',10,'LineWidth',1.5,'Color',linecolor)
axis square
cb2 = colorbar('peer',gca);
set(gca,'YDir','normal','xlim',[h1 h2],'xminortick','on','yminortick','on')
set(gca,'ticklength',[0.03,0.5],'linewidth',1.0,'fontsize',15);
ylabel( 'Vp/Vs', 'FontSize',16 )
xlabel( 'H (km)', 'FontSize',16 )
title('PpPs', 'fontname','Times new roman', 'FontSize',16)

subplot(2,2,3)
imagesc(Moho, kappa, stack(:,:,3)); hold on;
colormap(cyan);hold on;
plot( besth, bestk, 'wx', 'MarkerSize',10,'LineWidth',1.5,'Color',linecolor)
axis square
cb3 = colorbar('peer',gca);
set(gca,'YDir','normal','xlim',[h1 h2],'xminortick','on','yminortick','on')
set(gca,'ticklength',[0.03,0.5],'linewidth',1.0,'fontsize',15);
ylabel( 'Vp/Vs', 'FontSize',16 )
xlabel( 'H (km)', 'FontSize',16 )
title('PsPs & PpSs', 'fontname','Times new roman', 'FontSize',16)

subplot(2,2,4)
imagesc(Moho, kappa, Normed_stack); hold on;
colormap(cyan);hold on;
plot( besth, bestk, 'wx', 'MarkerSize',10,'LineWidth',0.8,'color', linecolor)
axis square
%contourf(Moho,kappa,stack_all,'LineStyle','none');hold on;%plot the 1-sigma contour
%tempstr = num2str(onesigma);
%onesigma = str2double(tempstr(1:5));
[~, bb] = contour(Moho,kappa,Normed_stack,[cvalue,1],'ShowText','off','linestyle','-','linewidth',1,'linecolor','k');
cb4 = colorbar('peer',gca);
%clabel(cc,bb,'fontsize',10,'FontName','Arial','color','k','rotation',0)
set(gca,'YDir','normal','xlim',[h1 h2],'xminortick','on','yminortick','on')
set(gca,'ticklength',[0.03,0.5],'linewidth',1.0,'fontsize',15);
line([besth besth], ylim,'Color',linecolor,'linestyle','--','LineWidth',1);line(xlim, [bestk bestk],'Color',linecolor,'linestyle','--','LineWidth',1); 
ylabel( 'Vp/Vs','FontSize',16 )
xlabel( 'H (km)', 'FontSize',16 )
title(['w1: ' num2str(weight(1)) ', w2: ' num2str(weight(2)) ', w3: ' num2str(weight(3))],  'fontname','Times new roman','FontSize',16)
 button1 = MFquestdlg( [ 0.4 , 0.12 ] ,'Do you want to save the plot ?','plot',  ...
     'Yes','No','Yes');
 if strcmp(button1, 'Yes') 

print(h,'-dpdf', [mapath '/' config.stnname 'hkmap.pdf'])
end
%% Output results


 button1 = MFquestdlg( [ 0.4 , 0.12 ] ,'Do you want to save the H-k list ?','list',  ...
     'Yes','No','Yes');
 if strcmp(button1, 'Yes') 
fid=fopen(OUT_path,'a+');
if isempty(fid)
    fprintf(fid,'H-k stacking results');
    fprintf(fid,'\n-------------------------------------------------------------------------------------------------------------------------------------');
    fprintf(fid,'\n Station Stalat Stalon RFnumber w1 w2 w3 Mohodepth deltaMoho kappa deltakappa');
end
    fseek(fid,0,'eof');
    fprintf(fid,'\n %s %6.2f %6.2f %u %f %f %f %f %f %f %f',config.stnname,config.slat,config.slong,EV_num,weight(1), weight(2),weight(3),besth,MaxHsig,bestk,Maxksig);
    fclose(fid);
 end
