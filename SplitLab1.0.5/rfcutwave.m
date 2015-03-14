function rfcutwave(i,para)
global  config rf 

if ispc
OUT_path = [config.cutdir '\' config.stnname];%path of cut out data
else
OUT_path = [config.cutdir '/' config.stnname];%path of cut out data
end

Ev_para = taupTime('iasp91',rf(i).depth,rf(i).phase,'sta',[config.slat,config.slong],'evt',[rf(i).lat,rf(i).lon]);   
Ev_para = srad2skm(Ev_para(1).rayParam); 

if( ~exist( OUT_path , 'dir') )
     mkdir( OUT_path ); end
fid_finallist = fopen(fullfile(OUT_path,[config.stnname 'finallist.dat']),'a+');

     fiddataT = fopen(fullfile(OUT_path,[rf(i).seisfile '_RFdata_T.dat']),'w+');
     if para==1
     fprintf(fiddataT,'%20.19f\n',rf(i).T1);
     elseif para==2
     fprintf(fiddataT,'%20.19f\n',rf(i).T2);    
     elseif para==3
     fprintf(fiddataT,'%20.19f\n',rf(i).T3);
     else
       error('This RF is not exist!')         
     end
     fclose(fiddataT);
     
     fiddataR = fopen(fullfile(OUT_path,[rf(i).seisfile '_RFdata_R.dat']),'w+'); 
     if para==1
     fprintf(fiddataR,'%20.19f\n',rf(i).R1);
     elseif para==2
     fprintf(fiddataR,'%20.19f\n',rf(i).R2);
     elseif para==3
     fprintf(fiddataR,'%20.19f\n',rf(i).R3);  
     else
       error('This RF is not exist!')        
     end
     fclose(fiddataR);
     
     fiddataZ = fopen(fullfile(OUT_path,[rf(i).seisfile '_RFdata_Z.dat']),'w+'); 
     if para==1
     fprintf(fiddataZ,'%20.19f\n',rf(i).Z1);
     elseif para==2
     fprintf(fiddataZ,'%20.19f\n',rf(i).Z2);
     elseif para==3
     fprintf(fiddataZ,'%20.19f\n',rf(i).Z3);
     else
       error('This RF is not exist!')       
     end
     fclose(fiddataZ);
     
     fprintf(fid_finallist,'%s %s %f %f %f %f %f %f %f %f\n',rf(i).seisfile,rf(i).phase,rf(i).lat,rf(i).lon,rf(i).depth,rf(i).dis,rf(i).bazi,Ev_para,rf(i).Mw,config.f0);
return
