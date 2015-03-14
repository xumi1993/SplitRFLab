function rfKeyPress(~,evnt,rfseis)


global  rf thisrf config

if strcmp(evnt.Key,'c')
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
           RfViewer(idx);clear idx;
       end
    else
        RfViewer(idx);clear idx;
    end
elseif strcmp(evnt.Key,'z')
    idx=thisrf.index-1;
    if idx<1;
        idx = length(rf);
    else
        rfseis=RfViewer(idx);
    end
elseif strcmp(evnt.Key,'q')
    if config.issac
        saverf_sac(thisrf.index,1);
    else
        saverf(thisrf.index,1);
    end
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
          rfseis= RfViewer(idx);clear idx;
       end
    else
       rfseis= RfViewer(idx);clear idx;
    end
elseif strcmp(evnt.Key,'w')
    if config.issac
        saverf_sac(thisrf.index,2);
    else
        saverf(thisrf.index,2);
    end
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
          rfseis= RfViewer(idx);clear idx;
       end
    else
       rfseis= RfViewer(idx);clear idx;
    end
    
elseif strcmp(evnt.Key,'e')
    if config.issac
        saverf_sac(thisrf.index,3);
    else
        saverf(thisrf.index,3);
    end
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
          rfseis= RfViewer(idx);clear idx;
       end
    else
       rfseis= RfViewer(idx);clear idx;
    end
elseif strcmp(evnt.Key,'s')
    if config.isoldver
        SL_SeismoViewer4old(config.db_index);
    else
        SL_SeismoViewer(config.db_index);
    end
    
elseif strcmp(evnt.Key,'d')
    delRF;

elseif strcmp(evnt.Key,'i')
    if config.issac
        rfcutwave_sac(thisrf.index,1);
    else
        rfcutwave(thisrf.index,1);
    end
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
          rfseis= RfViewer(idx);clear idx;
       end
    else
       rfseis= RfViewer(idx);clear idx;
    end
    
elseif strcmp(evnt.Key,'o')
    if config.issac
        rfcutwave_sac(thisrf.index,2);
    else
        rfcutwave(thisrf.index,2);
    end
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
          rfseis= RfViewer(idx);clear idx;
       end
    else
       rfseis= RfViewer(idx);clear idx;
    end
    
 elseif strcmp(evnt.Key,'p')
    if config.issac
        rfcutwave_sac(thisrf.index,3);
    else
        rfcutwave(thisrf.index,3);
    end
    idx=thisrf.index+1;
    if idx>length(rf);
        idx =1;
        button = MFquestdlg([ 0.4 , 0.42 ],'Do you want to quit the database?','PS_RecFunc',  ...
                            'Yes','No','Yes');
       if strcmp(button, 'Yes')
           close(gcf);clear idx;return
       else
          rfseis= RfViewer(idx);clear idx;
       end
    else
       rfseis= RfViewer(idx);clear idx;
    end
end

set(gcbf,'KeyPressFcn',{@rfKeyPress,rfseis})
return