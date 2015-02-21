function template
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
fprintf(' %s -- analysing event  %s:%4.0f.%03.0f (%.0f/%.0f) --',...
    datestr(now,13) , config.stnname, thiseq.date(1), thiseq.date(7),config.db_index, length(eq));


  
%% extend selection window
%some calculations require an extended tim window to perferm properly
% so this is what we do here
extime    = 20 ; %define extension time, here 20sec
o         = thiseq.Amp.time(1);%common offset of all files after hypotime
extbegin  = floor( (thiseq.a-extime-o) / thiseq.dt); %index of first element of amplitude verctor of the selected time window
extfinish = floor( (thiseq.f+extime-o) / thiseq.dt); %index of last element
extIndex  = extbegin:extfinish;%create vector of indices to elements of extended selection window

% now find indices of selected window, but this time 
% relative to extended window, defined above
ex = floor(extime/thiseq.dt) ;
w  = (ex+1):(length(extIndex)-ex);


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
if f1==0 & f2==inf %no filter
    % do nothing
    % we leave the seismograms untouched
else
    if f1 > 0  &  f2 < inf
        % bandpass
        [b,a]  = butter(n, [f1 f2]/ny);
    elseif f1==0 &  f2 < inf
        %lowpass
        [b,a]  = butter(n, [f2]/ny,'low');

    elseif f1>0 &  f2 == inf
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

button = questdlg('Do you want to keep the result?','MyFunction',  ...
    'Yes','No','Yes');
switch button
    case 'Yes';
     idx = thiseq.index;
     eq(idx).MyVarible = thiseq.MyVariable;
     %you may also want to write a logfile...
    case 'No'
        %do other things
end

%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%%              R E S U L T   O U T P U T    T E M P L A T E
%% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% lastly, how to you access later your results. For example write your
% results to a data files:

% we have to loop over all (permanent) "eq" entries. 
fid = fopen('MyResults.dat');
for k = 1:length(eq)
    tmp=eq(k);
    
    %Now, we look if eq(k).MyVariable is set
    if isfield(tmp, 'MyVariable')
        %now we can do what ever we want with this
        fprintf(fid,'Year: %4.0f  JDay: %03.0f  Backazimuth: %6.2f  Value: %f\n',...
                     tmp.date(1), tmp.date(7),  tmp.bazi,           tmp.MyVariable);
    end
    % go to next earthquake
end
fclose(fid);