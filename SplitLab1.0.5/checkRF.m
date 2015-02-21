function checkRF
global config rf

if ispc
OUT_path = [config.RFdatapath '\' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '\' config.stnname];%path of cut out data
else
OUT_path = [config.RFdatapath '/' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '/' config.stnname];%path of cut out data
end





for i=1:length(rf)
    
time = - config.extime_before  + rf(i).dt*(0:1:rf(i).RFlength-1);
figure(10);
% set(figure(10),'position',[200 400 1000 800]);
%subplot(3,1,1);plot(time,E,'k');
%subplot(3,1,2);plot(time,N,'k');
%subplot(3,1,3);plot(time,Z,'k');
%pause
plot(time,rf(i).RadialRF,'k','LineWidth',2.0);hold on;
plot(time,rf(i).TransverseRF);hold on
plot(xlim,[0 0],'g--');
set(gca,'xlim',[-5 30],'xtick',(0:2:30),'Xgrid','on')
    



button = MFquestdlg( [ 0.4 , 0.22 ] ,'Do you want to keep the result?','PS_RecFunc',  ...
    'Yes','No','Yes');
if strcmp(button, 'Yes')

    if( ~exist( OUT_path , 'dir') )
     mkdir( OUT_path ); end
     fid_iter_R = fopen(fullfile(OUT_path,[config.stnname 'iter_R.dat']),'a+');
     fid_iter_T = fopen(fullfile(OUT_path,[config.stnname 'iter_T.dat']),'a+');
     fid_finallist = fopen(fullfile(OUT_path,[config.stnname 'finallist.dat']),'a+');

     
    if( ~exist( OUT_path1 , 'dir') )
      mkdir( OUT_path1 ); end
        fid_finallist1 = fopen(fullfile(OUT_path1,[config.stnname 'finallist.dat']),'a+');
        
        
      %OUTPUT Radial RFs
        fidR = fopen(fullfile(OUT_path,[rf(i).seisfile '_' rf(i).phase '_R.dat']),'w+');        
        for ii = 1:rf(i).RFlength
        fprintf(fidR,'%f\n',rf(i).RadialRF(ii));         
        end
        fclose(fidR);
        
        %OUTPUT Transverse RFs
        fidT = fopen(fullfile(OUT_path,[rf(i).seisfile '_' rf(i).phase '_T.dat']),'w+');       
        for ii = 1:rf(i).RFlength
        fprintf(fidT,'%f\n',rf(i).TransverseRF(ii));       
        end
        fclose(fidT);
        
        %OUTPUT iteration number
        fprintf(fid_iter_R,'%s %s %u %f\n',rf(i).seisfile,rf(i).phase,rf(i).it_num_R,rf(i).RMS_R(rf(i).it_num_R));
        fprintf(fid_iter_T,'%s %s %u %f\n',rf(i).seisfile,rf(i).phase,rf(i).it_num_T,rf(i).RMS_T(rf(i).it_num_T));
        
        %Add the current earthquake to the finallist:
        Ev_para = taupTime('iasp91',rf(i).depth,rf(i).phase,'sta',[config.slat,config.slong],'evt',[rf(i).lat,rf(i).lon]);   
        Ev_para = srad2skm(Ev_para(1).rayParam);       
        fprintf(fid_finallist,'%s %s %f %f %f %f %f %f %f %f\n',rf(i).seisfile,rf(i).phase,rf(i).lat,rf(i).lon,rf(i).depth,rf(i).dis,rf(i).bazi,Ev_para,rf(i).Mw,config.f0);

        
     
     fiddataT = fopen(fullfile(OUT_path1,[rf(i).seisfile '_RFdata_T.dat']),'w+'); 
     fprintf(fiddataT,'%20.19f\n',rf(i).T);
     fclose(fiddataT);
     
     fiddataR = fopen(fullfile(OUT_path1,[rf(i).seisfile '_RFdata_R.dat']),'w+'); 
     fprintf(fiddataR,'%20.19f\n',rf(i).R);
     fclose(fiddataR);
     
     fiddataZ = fopen(fullfile(OUT_path1,[rf(i).seisfile '_RFdata_Z.dat']),'w+'); 
     fprintf(fiddataZ,'%20.19f\n',rf(i).Z);
     fclose(fiddataZ);
     
     fprintf(fid_finallist1,'%s %s %f %f %f %f %f %f %f %f\n',rf(i).seisfile,rf(i).phase,rf(i).lat,rf(i).lon,rf(i).depth,rf(i).dis,rf(i).bazi,Ev_para,rf(i).Mw,config.f0);
     
     fclose(fid_iter_R);fclose(fid_iter_T);fclose(fid_finallist);
    
end
close(figure(10));
end
return