function delRF
global thisrf config

if ispc
OUT_path = [config.RFdatapath '\' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '\' config.stnname];%path of cut out data
else
OUT_path = [config.RFdatapath '/' config.stnname];%path of PRFs
OUT_path1 = [config.cutdir '/' config.stnname];%path of cut out data
end

if config.issac
    file = [thisrf.seisfile '_' thisrf.phase '_*.sac'];
    file1 = [thisrf.seisfile '_RFdata_*.sac' ];
    button1 = MFquestdlg( [ 0.4 , 0.3 ] ,['Do you want to remove the RF result of' thisrf.seisfile '?'],'plot',  ...
      'Yes','No','Yes');
    if strcmp(button1, 'Yes')
        if ispc
            system(['del ' fullfile(OUT_path,file)])
            system(['del ' fullfile(OUT_path1,file1)])
        else
            system(['rm ' fullfile(OUT_path,file)])
            system(['rm ' fullfile(OUT_path1,file1)])
        end
    end
end