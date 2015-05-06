function saverf(i,para)

global config rf

if ispc
OUT_path = [config.RFdatapath '\' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '\' config.stnname];%path of cut out data
else
OUT_path = [config.RFdatapath '/' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '/' config.stnname];%path of cut out data
end

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
        if para==1
        for ii = 1:rf(i).RFlength
        fprintf(fidR,'%f\n',rf(i).RadialRF_f1(ii));         
        end
        elseif para==2
        for ii = 1:rf(i).RFlength
        fprintf(fidR,'%f\n',rf(i).RadialRF_f2(ii));         
        end
        elseif para==3
        for ii = 1:rf(i).RFlength
        fprintf(fidR,'%f\n',rf(i).RadialRF_f3(ii));         
        end 
        else
            error('This RF is not exist!')
          
        end
        fclose(fidR);
        
        %OUTPUT Transverse RFs
        fidT = fopen(fullfile(OUT_path,[rf(i).seisfile '_' rf(i).phase '_T.dat']),'w+');  
        if para==1
        for ii = 1:rf(i).RFlength
        fprintf(fidT,'%f\n',rf(i).TransverseRF_f1(ii));       
        end
        elseif para==2
        for ii = 1:rf(i).RFlength
        fprintf(fidT,'%f\n',rf(i).TransverseRF_f2(ii));       
        end
        elseif para==3
        for ii = 1:rf(i).RFlength
        fprintf(fidT,'%f\n',rf(i).TransverseRF_f3(ii));       
        end
        else
           error('This RF is not exist!')
           
        end 
        fclose(fidT);
        
        %OUTPUT iteration number
        fprintf(fid_iter_R,'%s %s %u %f\n',rf(i).seisfile,rf(i).phase,rf(i).it_num_R,rf(i).RMS_R(rf(i).it_num_R));
        fprintf(fid_iter_T,'%s %s %u %f\n',rf(i).seisfile,rf(i).phase,rf(i).it_num_T,rf(i).RMS_T(rf(i).it_num_T));
        
        %Add the current earthquake to the finallist:
        Ev_para = taupTime('iasp91',rf(i).depth,rf(i).phase,'sta',[config.slat,config.slong],'evt',[rf(i).lat,rf(i).lon]);   
        Ev_para = srad2skm(Ev_para(1).rayParam);       
        fprintf(fid_finallist,'%s %s %f %f %f %f %f %f %f %f\n',rf(i).seisfile,rf(i).phase,rf(i).lat,rf(i).lon,rf(i).depth,rf(i).dis,rf(i).bazi,Ev_para,rf(i).Mw,config.f0);
        flocse(fid_iter_R);fclose(fid_iter_T);fclose(fid_finallist);
        
     
     fiddataT = fopen(fullfile(OUT_path1,[rf(i).seisfile '_RFdata_T.dat']),'w+');
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
     
     fiddataR = fopen(fullfile(OUT_path1,[rf(i).seisfile '_RFdata_R.dat']),'w+'); 
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
     
     fiddataZ = fopen(fullfile(OUT_path1,[rf(i).seisfile '_RFdata_Z.dat']),'w+'); 
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
     
     fprintf(fid_finallist1,'%s %s %f %f %f %f %f %f %f %f\n',rf(i).seisfile,rf(i).phase,rf(i).lat,rf(i).lon,rf(i).depth,rf(i).dis,rf(i).bazi,Ev_para,rf(i).Mw,config.f0);
     fclose(fid_finallist1)

return
