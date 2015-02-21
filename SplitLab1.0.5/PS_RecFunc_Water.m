function PS_RecFunc_Water
% make your own function for splitlab
%
% this takes theselected time window performs a operation that you define
% and than gives an example of how to access the final results structure
% 

%% FIRST, make global variables visible to our template.
% config   - contains information on your configuration (directories, etc)
% eq       - is the structure of all earthquake parameters
% thiseq   - contains the paramters of this earthquake (very smart), plus 
%            additional temporary information, eg in thiseq.Amp the amplitude
%            vectors are saved 
global  config eq thiseq 
%print info to standard output
fprintf(' %s -- analysing event  %s:%4.0f.%03.0f (%.0f/%.0f) --\n',...
    datestr(now,13) , config.stnname, thiseq.date(1), thiseq.date(7),config.db_index, length(eq));


  
%% extend selection window
%some calculations require an extended tim window to perferm properly
% so this is what we do here
extime_before    = 10 ; 
extime_after    = 120 ; 
o         = thiseq.Amp.time(1);%common offset of all files after hypotime
extbegin  = floor( (thiseq.a - extime_before - o) / thiseq.dt); %index of first element of amplitude verctor of the selected time window
extfinish = floor( (thiseq.a + extime_after - o) / thiseq.dt); %index of last element
extIndex  = extbegin:extfinish;%create vector of indices to elements of extended selection window
RFlength = length(extIndex);
% now find indices of selected window, but this time 
% relative to extended window, defined above

%ex = floor(extime/thiseq.dt) ;
%w  = (ex+1):(length(extIndex)-ex);


%% OK, now we can define our seismogram components windows
E =  thiseq.Amp.East(extIndex);
N =  thiseq.Amp.North(extIndex);
Z =  thiseq.Amp.Vert(extIndex);

Q = thiseq.Amp.Radial(extIndex)';
T = thiseq.Amp.Transv(extIndex)';
L = thiseq.Amp.Ray(extIndex)';


%% Filtering
% the seismogram components are not yet filtered
% define your filter here.
% the selected corner frequncies are stored in the varialbe "thiseq.filter"
% 
ny    = 1/(2*thiseq.dt);%nyquist freqency of seismogramm
n     = 3; %filter order

f1 = thiseq.filter(1);
f2 = thiseq.filter(2);
if f1==0 && f2==inf %no filter
    % do nothing
    % we leave the seismograms untouched
else
    if f1 > 0  &&  f2 < inf
        % bandpass
        [b,a]  = butter(n, [f1 f2]/ny);
    elseif f1==0 &&  f2 < inf
        %lowpass
        [b,a]  = butter(n, [f2]/ny,'low');

    elseif f1>0 &&  f2 == inf
        %highpass
        [b,a]  = butter(n, [f1]/ny, 'high');
    end
    Q = filtfilt(b,a,Q); %Radial     (Q) component in extended time window
    T = filtfilt(b,a,T); %Transverse (T) component in extended time window
    L = filtfilt(b,a,L); %Vertical   (L) component in extended time window
    
    E = filtfilt(b,a,E); 
    N = filtfilt(b,a,N);
    Z = filtfilt(b,a,Z);
end

%% do some detrending of extended time window
    E = detrend(E,'constant');
    E = detrend(E,'linear');
    N = detrend(N,'constant');
    N = detrend(N,'linear');
    Z = detrend(Z,'constant');
    Z = detrend(Z,'linear');
    
    Q = detrend(Q,'constant');
    Q = detrend(Q,'linear');
    T = detrend(T,'constant');
    T = detrend(T,'linear');
    L = detrend(L,'constant');
    L = detrend(L,'linear');
    
    seis = rotateSeisENZtoTRZ( [E, N, Z] , thiseq.bazi );
T = seis(:,1);
R = seis(:,2);
Z = seis(:,3);
    
    %% Rotate to P-SV-SH
% Alpha = 5;
% W=20;
% for t=1:length(T)
% winbegin  = t - floor( W/2 / thiseq.dt);
% winfinish = t + floor( W/2 / thiseq.dt);
% if winbegin <= 0 
%     winbegin = 1;
% elseif winfinish >= length(T)
%     winfinish =length(T);
% end
% winIndex  = winbegin:winfinish;
% 
% %     winT =  T(winIndex);
%     winR =  R(winIndex);
%     winZ =  Z(winIndex);
% 
% % Caculate the covariane matrix
% V = cov(winZ,winR);
% % calculating the eigenvalues and the eigenvectors
% [Ve,d]=eig(V);
% e1=Ve(:,1);e2=Ve(:,2); %e1=[eZ1,eR1]T;e2=[eZ2,eR2]T
% d1=d(1,1);d2=d(2:2);
% if e1(1)/e1(2) > tan(Alpha) || e1(1)/e1(2) < -1/tan(Alpha)
%     OP = [1;0];
%     OS = [0;1];
% elseif e1(1)/e1(2) < tan(Alpha) && e1(1)/e1(2) < -1/tan(Alpha)
%     OP = [0;1];
%     OS = [1;0];
% end
% Z(t) =  [Z(t) R(t)]*Ve*OP;
% R(t) = [Z(t) R(t)]*Ve*OS;
% end
    
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%                P U T     Y O U R    C O D E    H E R E
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% here you can start with your own coding;
% you should make use of the global "config" and "thiseq" variable to get
% information about the station (lat, long) and earthquake (bazi, depth).
%
% any of your results may be stored temporarily in a variable within thiseq
% something like     
%    thiseq.MyVariable=[max(E) max(N) max(Z)];

%% Receiver function parameters
RFlength = length(extIndex);
Shift = 10; %RF starts at 10 s
f0 = 2.0; % pulse width
% niter = 400;  % number iterations
% minderr = 0.001;  % stop when error reaches limit

% Make receiver function
% seis = rotateSeisENZtoTRZ( [E, N, Z] , thiseq.bazi );
% T = seis(:,1);
% R = seis(:,2);
% Z = seis(:,3);
[thiseq.RadialRF, thiseq.RMS_R,thiseq.it_num_R] = makeRFwater_ammon( R, Z, Shift, thiseq.dt, RFlength, ...
				 0.01, f0, 0);
[thiseq.TransverseRF, thiseq.RMS_T,thiseq.it_num_T] = makeRFwater_ammon( T, Z, Shift, thiseq.dt, RFlength, ...
				 0.01, f0, 0);
%plot RF
time = - Shift  + thiseq.dt*(0:1:RFlength-1);
figure(10);
% set(figure(10),'position',[200 400 1000 800]);
%subplot(3,1,1);plot(time,E,'k');
%subplot(3,1,2);plot(time,N,'k');
%subplot(3,1,3);plot(time,Z,'k');
%pause
plot(time,thiseq.RadialRF,'k','LineWidth',1.1);hold on;
plot(time,thiseq.TransverseRF);hold on
plot(xlim,[0 0],'g--');
set(gca,'xlim',[-5 30],'xtick',(0:2:30),'Xgrid','on')
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%              R E S U L T   S A V E   T E M P L A T E
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% assume you stored your output in the global variable "thiseq.MyVariable"
% Then you pose a question, if the user wants to save this result (see  the 
% Matlab function QUESTDLG). We have to transmit this result now from temporary
% thiseq to the permanent project variable "eq"
% the index of thiseq in the permanent eq structure is given by the varible
% thiseq.index (very smart...)
%
OUT_path = ['/Volumes/LaCie/YN.RFunction/RFresult/' config.stnname];
OUT_path1 = ['/Volumes/LaCie/YN.RFunction/RFcutoutdata/' config.stnname];
button = MFquestdlg( [ 0.4 , 0.22 ] ,'Do you want to keep the result?','PS_RecFunc',  ...
    'Yes','No','Yes');
if strcmp(button, 'Yes')
     if( ~exist( OUT_path , 'dir') )
     mkdir( OUT_path ); end
     fid_iter_R = fopen(fullfile(OUT_path,[config.stnname 'iter_R.dat']),'a+');
     fid_iter_T = fopen(fullfile(OUT_path,[config.stnname 'iter_T.dat']),'a+');
     fid_finallist = fopen(fullfile(OUT_path,[config.stnname 'finallist.dat']),'a+');
      %OUTPUT Radial RFs
        fidR = fopen(fullfile(OUT_path,[thiseq.seisfiles{1}(1:17) '_' thiseq.SplitPhase '_R.dat']),'w+');        
        for ii = 1:RFlength
        fprintf(fidR,'%f\n',thiseq.RadialRF(ii));         
        end
        fclose(fidR);
        
        %OUTPUT Transverse RFs
        fidT = fopen(fullfile(OUT_path,[thiseq.seisfiles{1}(1:17) '_' thiseq.SplitPhase '_T.dat']),'w+');       
        for ii = 1:RFlength
        fprintf(fidT,'%f\n',thiseq.TransverseRF(ii));       
        end
        fclose(fidT);
        
        %OUTPUT iteration number
        fprintf(fid_iter_R,'%s %s %u %f\n',thiseq.seisfiles{1}(1:17),thiseq.SplitPhase,thiseq.it_num_R,thiseq.RMS_R(thiseq.it_num_R));
        fprintf(fid_iter_T,'%s %s %u %f\n',thiseq.seisfiles{1}(1:17),thiseq.SplitPhase,thiseq.it_num_T,thiseq.RMS_T(thiseq.it_num_T));
        
        %Add the current earthquake to the finallist:
        Ev_para = taupTime('iasp91',thiseq.depth,thiseq.SplitPhase,'sta',[config.slat,config.slong],'evt',[thiseq.lat,thiseq.long]);   
        Ev_para = srad2skm(Ev_para(1).rayParam);       
        fprintf(fid_finallist,'%s %s %f %f %f %f %f %f %f %f\n',thiseq.seisfiles{1}(1:17),thiseq.SplitPhase,thiseq.lat,thiseq.long,thiseq.depth,thiseq.dis,thiseq.bazi,Ev_para,thiseq.Mw,f0);
     %idx = thiseq.index;
     %eq(idx).RadialRF = thiseq.RadialRF;
     %eq(idx).RMS_R = thiseq.RMS_R;
     %eq(idx).it_num_R = thiseq.it_num_R;
     
     %eq(idx).TransverseRF = thiseq.TransverseRF;
     %eq(idx).RMS_T = thiseq.RMS_T;
     %eq(idx).it_num_T = thiseq.it_num_T;
     %you may also want to write a logfile...
     
%%     cut out data
% datE =  thiseq.Amp.East(extIndex);
% datN =  thiseq.Amp.North(extIndex);
% datZ =  thiseq.Amp.Vert(extIndex);
% [B,A]  = butter(n, [0.03 2]/ny);
%     datE = filtfilt(B,A,datE); 
%     datN = filtfilt(B,A,datN);
%     datZ = filtfilt(B,A,datZ);
%     datE = detrend(datE,'constant');
%     datE = detrend(datE,'linear');
%     datN = detrend(datN,'constant');
%     datN = detrend(datN,'linear');
%     datZ = detrend(datZ,'constant');
%     datZ = detrend(datZ,'linear');
%     seis1 = rotateSeisENZtoTRZ( [datE, datN, datZ] , thiseq.bazi );
%     datT = seis1(:,1);
%     datR = seis1(:,2);
%     datZ = seis1(:,3);
    

     if( ~exist( OUT_path1 , 'dir') )
         mkdir( OUT_path1 ); end
     fiddataT = fopen(fullfile(OUT_path1,[thiseq.seisfiles{1}(1:17) '_RFdata_T.dat']),'w+'); 
     fprintf(fiddataT,'%20.19f\n',T);
     fclose(fiddataT);
     
     fiddataR = fopen(fullfile(OUT_path1,[thiseq.seisfiles{1}(1:17) '_RFdata_R.dat']),'w+'); 
     fprintf(fiddataR,'%20.19f\n',R);
     fclose(fiddataR);
     
     fiddataZ = fopen(fullfile(OUT_path1,[thiseq.seisfiles{1}(1:17) '_RFdata_Z.dat']),'w+'); 
     fprintf(fiddataZ,'%20.19f\n',Z);
     fclose(fiddataZ);
     
     fid_finallist1 = fopen(fullfile(OUT_path1,[config.stnname 'finallist.dat']),'a+');
     fprintf(fid_finallist1,'%s %s %f %f %f %f %f %f %f %f\n',thiseq.seisfiles{1}(1:17),thiseq.SplitPhase,thiseq.lat,thiseq.long,thiseq.depth,thiseq.dis,thiseq.bazi,Ev_para,thiseq.Mw,f0);
     
     fclose(fid_iter_R);fclose(fid_iter_T);fclose(fid_finallist);close(figure(10));     
else
    clear('thiseq.RadialRF','thiseq.TransverseRF', 'thiseq.RMS_R','thiseq.it_num_R', 'thiseq.RMS_T','thiseq.it_num_T');close(figure(10));
end

end
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%              R E S U L T   O U T P U T    T E M P L A T E
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% lastly, how to you access later your results. For example write your
% results to a data files:

% we have to loop over all (permanent) "eq" entries. 




%for k = 1:length(eq)
    %tmp=eq(k);
    
    %Now, we look if eq(k).MyVariable is set
    %if isfield(tmp, 'RadialRF') && ~isempty(tmp.RadialRF)
       
    %end
    % go to next earthquake
%end

