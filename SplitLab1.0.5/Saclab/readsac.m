function sh = readsac( file, pathname )
% RSAC reads the data from a binary SAC time series file
%
% format s = readsac('file'); Returns a structure!
% To see the data once you've read it, type plot(s.t,s.d)
%
% Charles J Ammon (Penn State) and George Randall (LANL)
%

if nargin < 1
	[file, pathname] = uigetfile('*', 'Choose a SAC file')
	if file == 0                          % cancel chosen in uigetfile
		return;
	end
	if isunix
	  eval(['cd ' pathname]); 
	else
		cd(pathname);
	end
%
elseif nargin > 1
  	if sh                                  % error return from cd
    	disp('Usage: readsac(filename, pathname)');
    	disp(['       pathname: ', pathname]);
    	return
  	end
end
%
% sh = sacacheader;
%
fid = fopen(file, 'r');
if ( fid > 0 )
   %
   % Read sh.struct SacHeader
   %
   % Floats
   %                  
   sh.delta = fread(fid, 1, 'float');
   sh.depmin = fread(fid, 1, 'float');
   sh.depmax = fread(fid, 1, 'float');
   sh.scale = fread(fid, 1, 'float');
   sh.odelta = fread(fid, 1, 'float');    
   sh.b = fread(fid, 1, 'float');
   sh.e = fread(fid, 1, 'float');
   sh.o = fread(fid, 1, 'float');
   sh.a = fread(fid, 1, 'float');
   sh.fmt = fread(fid, 1, 'float'); 
   sh.t0 = fread(fid, 1, 'float');
   sh.t1 = fread(fid, 1, 'float');
   sh.t2 = fread(fid, 1, 'float');
   sh.t3 = fread(fid, 1, 'float');
   sh.t4 = fread(fid, 1, 'float');        
   sh.t5 = fread(fid, 1, 'float');
   sh.t6 = fread(fid, 1, 'float');
   sh.t7 = fread(fid, 1, 'float');
   sh.t8 = fread(fid, 1, 'float');
   sh.t9 = fread(fid, 1, 'float');        
   sh.f = fread(fid, 1, 'float');
   sh.resp0 = fread(fid, 1, 'float');
   sh.resp1 = fread(fid, 1, 'float');
   sh.resp2 = fread(fid, 1, 'float');
   sh.resp3 = fread(fid, 1, 'float');     
   sh.resp4 = fread(fid, 1, 'float');
   sh.resp5 = fread(fid, 1, 'float');
   sh.resp6 = fread(fid, 1, 'float');
   sh.resp7 = fread(fid, 1, 'float');
   sh.resp8 = fread(fid, 1, 'float');     
   sh.resp9 = fread(fid, 1, 'float');
   sh.stla = fread(fid, 1, 'float');
   sh.stlo = fread(fid, 1, 'float');
   sh.stel = fread(fid, 1, 'float');
   sh.stdp = fread(fid, 1, 'float');      
   sh.evla = fread(fid, 1, 'float');
   sh.evlo = fread(fid, 1, 'float');
   sh.evel = fread(fid, 1, 'float');
   sh.evdp = fread(fid, 1, 'float');
   sh.mag = fread(fid, 1, 'float');   
   sh.user0 = fread(fid, 1, 'float');
   sh.user1 = fread(fid, 1, 'float');
   sh.user2 = fread(fid, 1, 'float');
   sh.user3 = fread(fid, 1, 'float');
   sh.user4 = fread(fid, 1, 'float');     
   sh.user5 = fread(fid, 1, 'float');
   sh.user6 = fread(fid, 1, 'float');
   sh.user7 = fread(fid, 1, 'float');
   sh.user8 = fread(fid, 1, 'float');
   sh.user9 = fread(fid, 1, 'float');     
   sh.dist = fread(fid, 1, 'float');
   sh.az = fread(fid, 1, 'float');
   sh.baz = fread(fid, 1, 'float');
   sh.gcarc = fread(fid, 1, 'float');
   sh.sb = fread(fid, 1, 'float'); 
   sh.sdelta = fread(fid, 1, 'float');
   sh.depmen = fread(fid, 1, 'float');
   sh.cmpaz = fread(fid, 1, 'float');
   sh.cmpinc = fread(fid, 1, 'float');
   sh.xminimum = fread(fid, 1, 'float');   
   sh.xmaximum = fread(fid, 1, 'float');
   sh.yminimum = fread(fid, 1, 'float');
   sh.ymaximum = fread(fid, 1, 'float');
   sh.unused6 = fread(fid, 1, 'float');
   sh.unused7 = fread(fid, 1, 'float');   
   sh.unused8 = fread(fid, 1, 'float');
   sh.unused9 = fread(fid, 1, 'float');
   sh.unused10 = fread(fid, 1, 'float');
   sh.unused11 = fread(fid, 1, 'float');
   sh.unused12 = fread(fid, 1, 'float');  
   %
   % Ints
   %
   sh.nzyear = fread(fid, 1, 'int');
   sh.nzjday = fread(fid, 1, 'int');
   sh.nzhour = fread(fid, 1, 'int');
   sh.nzmin = fread(fid, 1, 'int');
   sh.nzsec = fread(fid, 1, 'int');     
   sh.nzmsec = fread(fid, 1, 'int');
   sh.nvhdr = fread(fid, 1, 'int');
   sh.norid = fread(fid, 1, 'int');
   sh.nevid = fread(fid, 1, 'int');
   sh.npts = fread(fid, 1, 'int');      
   sh.nspts = fread(fid, 1, 'int');
   sh.nwfid = fread(fid, 1, 'int');
   sh.nxsize = fread(fid, 1, 'int');
   sh.nysize = fread(fid, 1, 'int');
   sh.unused15 = fread(fid, 1, 'int');  
   sh.iftype = fread(fid, 1, 'int');
   sh.idep = fread(fid, 1, 'int');
   sh.iztype = fread(fid, 1, 'int');
   sh.unused16 = fread(fid, 1, 'int');
   sh.iinst = fread(fid, 1, 'int');     
   sh.istreg = fread(fid, 1, 'int');
   sh.ievreg = fread(fid, 1, 'int');
   sh.ievtyp = fread(fid, 1, 'int');
   sh.iqual = fread(fid, 1, 'int');
   sh.isynth = fread(fid, 1, 'int');    
   sh.magtype = fread(fid, 1, 'int');
   sh.magsrc = fread(fid, 1, 'int');
   sh.unused19 = fread(fid, 1, 'int');
   sh.unused20 = fread(fid, 1, 'int');
   sh.unused21 = fread(fid, 1, 'int');  
   sh.unused22 = fread(fid, 1, 'int');
   sh.unused23 = fread(fid, 1, 'int');
   sh.unused24 = fread(fid, 1, 'int');
   sh.unused25 = fread(fid, 1, 'int');
   sh.unused26 = fread(fid, 1, 'int');  
   sh.leven = fread(fid, 1, 'int');
   sh.lpspol = fread(fid, 1, 'int');
   sh.lovrok = fread(fid, 1, 'int');
   sh.lcalda = fread(fid, 1, 'int');
   sh.unused27 = fread(fid, 1, 'int');  
   %
   % Strings
   %
   sh.kstnm = fscanf(fid,'%8c',1);
   sh.kevnm = fscanf(fid,'%16c',1);           
   sh.khole = fscanf(fid,'%8c',1);
   sh.ko = fscanf(fid,'%8c',1);
   sh.ka = fscanf(fid,'%8c',1);               
   sh.kt0 = fscanf(fid,'%8c',1);
   sh.kt1 = fscanf(fid,'%8c',1);
   sh.kt2 = fscanf(fid,'%8c',1);              
   sh.kt3 = fscanf(fid,'%8c',1);
   sh.kt4 = fscanf(fid,'%8c',1);
   sh.kt5 = fscanf(fid,'%8c',1);              
   sh.kt6 = fscanf(fid,'%8c',1);
   sh.kt7 = fscanf(fid,'%8c',1);
   sh.kt8 = fscanf(fid,'%8c',1);              
   sh.kt9 = fscanf(fid,'%8c',1);
   sh.kf = fscanf(fid,'%8c',1);
   sh.kuser0 = fscanf(fid,'%8c',1);           
   sh.kuser1 = fscanf(fid,'%8c',1);
   sh.kuser2 = fscanf(fid,'%8c',1);
   sh.kcmpnm = fscanf(fid,'%8c',1);           
   sh.knetwk = fscanf(fid,'%8c',1);
   sh.kdatrd = fscanf(fid,'%8c',1);
   sh.kinst = fscanf(fid,'%8c',1);            
   %
   % Populate the additional fields for consistency with previous code?
   %
   sh.picks(1) = sh.t0 ;
   sh.picks(2) = sh.t1 ;
   sh.picks(3) = sh.t2 ;
   sh.picks(4) = sh.t3 ;
   sh.picks(5) = sh.t4 ;
   sh.picks(6) = sh.t5 ;
   sh.picks(7) = sh.t6 ;
   sh.picks(8) = sh.t7 ;
   sh.picks(9) = sh.t8 ;
   sh.picks(10) = sh.t9 ;
   %
   sh.nz(1) = sh.nzyear ;
   sh.nz(2) = sh.nzjday ;
   sh.nz(3) = sh.nzhour ;
   sh.nz(4) = sh.nzmin ;
   sh.nz(5) = sh.nzsec ;
   sh.nz(6) = sh.nzmsec ;
   %
   sh.user(1) = sh.user0 ;
   sh.user(2) = sh.user1 ;
   sh.user(3) = sh.user2 ;
   sh.user(4) = sh.user3 ;
   sh.user(5) = sh.user4 ;
   sh.user(6) = sh.user5 ;
   sh.user(7) = sh.user6 ;
   sh.user(8) = sh.user7 ;
   sh.user(9) = sh.user8 ;
   sh.user(10) = sh.user9 ;
   %
   sh.beg = sh.b ;
   sh.dt = sh.delta ;
   %
   % read in the floating point values
   %
   status = fseek(fid, 632, 'bof');
   [sh.d, nread] = fread(fid, Inf, 'float'); 
   % build a time array - clear it if you are using lots of memory
   %
   sh.t = [sh.beg:sh.dt:sh.beg+sh.dt*(length(sh.d)-1)]';
   % compute some values of the min,max,mean
   sh.depmin = min(sh.d);
   sh.depmax = max(sh.d);
   sh.depmen = mean(sh.d);
   sh.filename = file; 
   sh.mytype = 'SAC_STRUCTURE';
   st = fclose(fid);     
else
   disp(['Error reading file ', file]);
   st = fclose(fid);     
  return
end
