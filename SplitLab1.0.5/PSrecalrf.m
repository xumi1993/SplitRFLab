function PSrecalrf

global config 
if ~config.issac
%% *.dat
[event phase evlat evlon evdep dis bazi rayp magnitude f00]=textread(fullfile(config.cutdir,config.stnname,[config.stnname 'finallist.dat']),'%s %s %f %f %f %f %f %f %f %f',-1);
EV_num=length(evdep);
%% read RF data
m=1;
disp('Read RF data...');
while 1
    if m==EV_num+1
    break,end;
filename=event(m,:);
datafile=fullfile(config.cutdir,config.stnname,[char(filename) '_RFdata_R.dat']);
datafile1=fullfile(config.cutdir,config.stnname,[char(filename) '_RFdata_T.dat']);
datafile2=fullfile(config.cutdir,config.stnname,[char(filename) '_RFdata_Z.dat']);
datar(:,m)=load(char(datafile));
datat(:,m)=load(char(datafile1));
dataz(:,m)=load(char(datafile2));
m=m+1;
end

RFlength = length(datar);
dt = (config.extime_before + config.extime_after +1) / RFlength;
Shift = config.extime_before;
f0 = config.f0;
niter = 400;  % number iterations
minderr = 0.001;  % stop when error reaches limit

RadialRF = zeros(RFlength,EV_num);
TransverseRF = zeros(RFlength,EV_num);
for i=1:EV_num
    str  = ['Calculate ' char(event(i,:))];
    head = ['done...Calculating' num2str(i) 'th of' num2str(EV_num)];
    workbar(i/EV_num, str, head)
    
    disp(event(i,:));
    [RadialRF(:,i), RMS_R,it_num_R] = makeRFitdecon_la( datar(:,i), dataz(:,i), dt, RFlength, Shift, f0, ...
				 niter, minderr);
    [TransverseRF(:,i), RMS_T,it_num_T] = makeRFitdecon_la( datat(:,i), dataz(:,i), dt, RFlength, Shift, f0, ...
				 niter, minderr);
end
OUT_path = fullfile(config.RFdatapath,config.stnname);
if( ~exist( OUT_path , 'dir') )
     mkdir( OUT_path ); end
fid_finallist = fopen(fullfile(OUT_path,[config.stnname 'finallist.dat']),'a+');
disp('Save RFs...') 
for m=1:EV_num  
   %OUTPUT Radial RFs
        fidR = fopen(fullfile(OUT_path,[char(event(m,:)) '_P_R.dat']),'w+');        
        fprintf(fidR,'%f\n',RadialRF(:,m));         
        fclose(fidR);
    %OUTPUT Transverse RFs
        fidR = fopen(fullfile(OUT_path,[char(event(m,:)) '_P_T.dat']),'w+');        
        fprintf(fidR,'%f\n',TransverseRF(:,m));         
        fclose(fidR);
        
        fprintf(fid_finallist,'%s %s %f %f %f %f %f %f %f %f\n',char(event(m,:)),char(phase(m,:)),evlat(m,:),evlon(m,:),evdep(m,:),dis(m,:),bazi(m,:),rayp(m,:),magnitude(m,:),f0);

end
fclose(fid_finallist);

end


return