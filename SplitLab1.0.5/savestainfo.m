function savestainfo(stnname)

global  config 

OUT_path= config.stapath;
[st,la,lo,el]=textread(OUT_path,'%s %f %f %d',-1);
idx=find(strcmp(st,stnname));
config.slat=la(idx);
config.slong=lo(idx);
config.sele=el(idx);
fprintf('Stalat=%f;Stalon=%f;Staelev=%d\n',config.slat,config.slong,config.sele)

% % if( ~exist( fullfile(OUT_path,filename) , 'file') )
% %   fid_Stalist = fopen(fullfile(OUT_path,filename),'a+');
% %   fprintf(fid_Stalist,'%s %5.3f %6.3f %d\n',stnname,slat,slong,elev);
% %     helpdlg('Saving succesful!!!', 'Info');   
% % else
% fid_Stalist = fopen(fullfile(OUT_path),'a+');
% if isempty(fid_Stalist)
%    
%   fprintf(fid_Stalist,'%s %5.3f %6.3f %4d\n',stnname,slat,slong,elev);
%     helpdlg('Saving succesful!!!', 'Info');   
% else
% [stnnames,~,~,~] = textread(fullfile(OUT_path),'%s %f %f %d',-1);
% stnnames=char(stnnames);
% [m,n] = size(stnnames);
% N=zeros(1,m);
% for i=1:m
% if strcmp(char(stnnames(i,:)),stnname)
%     N(i)=1;
% else
%     N(i)=0;
% end
% end
% if isempty(find(N==1, 1))
%     fprintf(fid_Stalist,'%s %5.3f %6.3f %4d\n',stnname,slat,slong,elev);
%     helpdlg('Saving succesful!!!', 'Info');   
% else
%     warndlg('You have saved this station!','warn Dialog Box','modal');
% end
% end