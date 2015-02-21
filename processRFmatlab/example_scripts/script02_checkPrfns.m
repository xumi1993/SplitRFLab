function script02_checkPrfns(isAuto)
% Open all SAC files containing a receiver functions in a
% directory. Check whether it falls into a number of criteria, then
% decide whether or not to keep it.
% 
% IN (optional):
% isAuto = true to do the checking automatically, false to check manually

%--- checkPRfn.m ---
%
% Filename: checkPRfn.m
%
% Author: Iain W Bailey
% Maintainer:
% Created: Wed Oct 20 15:16:39 2010 (-0700)
% Version: 1
% Last-Updated: Mon Jun 18 22:29:14 2012 (-0400)
%           By: Iain W. Bailey
%     Update #: 140
%
%- Change Log:
%
% 18 June 2012 Removed adding paths in the first part of the
% script. This is now done by a script in the root directory. /
% Made some commands more windows friendly by taking out unix stuff
% /
%
%- Code:

if( nargin < 1 ), isAuto = false; end

DIR = fullfile('prfns','prfns_iter_2.50'); % directory for in/output data
if( ~exist(DIR, 'dir')),
    error('Directory: %s doesn''t exist.',DIR)
end


if( isAuto ),
    fprintf(['Automatically checking receiver function quality in directory ' ...
        '%s\n'], DIR);
else
    fprintf(['Manually checking receiver function quality in directory ' ...
        '%s\n'], DIR);
end

% make a log of all the outputs
logfile = fullfile( DIR,'prf_check.log' );
if( exist( logfile, 'file' ) == 2 ),
  delete( logfile );
end
fprintf('Saving terminal output to %s\n', logfile)
diary(logfile);

% PARAMETERS
MAXRMS = 0.3; % Don't allow any RMS values greater than this
PSEARCH = 5; % Largest spike must be +ve within this many seconds of zero
MAXSPIKE2 = 0.5; % 2nd max spike cannot be > this much times max spike

STATION_PREFIX='TA';
PSUFFIX='PRF.sac';
TSUFFIX='TRF.sac';
pausetime = 0.5;

% directories for unwanted RFs
REJDIR = fullfile( DIR, 'rejected/');
if( ~exist(REJDIR,'dir') ),
  mkdir(REJDIR);
end
fprintf('Putting bad receiver functions in %s\n',REJDIR);

% get station directories
dirlist = dir( fullfile( DIR, [STATION_PREFIX,'_*']) );
fprintf('Number of station directories: %i\n', numel(dirlist));

% loop through directories
for di = 1:numel(dirlist),

    fprintf('DIR # = %i\n',di);

    % P Rfn file list
    files1 = dir( fullfile( DIR, dirlist(di).name,['*.',PSUFFIX] ));

    % T Rfn file list
    files2 = dir( fullfile( DIR, dirlist(di).name,['*.',TSUFFIX] ));

    fprintf('Number of PRF files: %i\n', numel(files1));
    fprintf('Number of TRF files: %i\n', numel(files2));

    % loop through files in directory
    for fi = 1:numel(files1),

        fprintf('File # = %i\n',fi);

        % Open files
        try
            filename = fullfile( DIR, dirlist(di).name, files1(fi).name );
            [t, seis, hdr] = sac2mat(filename);
        catch ME
            error(ME.message)
            continue;
        end

        % Flag for checking whether we keep the receiver function
        isOk = true;
        
        rayp = hdr.user(1).data;
        baz = hdr.evsta.baz;
        
        % Get and check the RMS from the deconvolution
        rms = hdr.user(7).data;
        fprintf('\tDeconvolution RMS = %f\n',rms);
        if( rms > MAXRMS ),
            fprintf( ['\tLarger than defined threshold, indicating ',...
                'deconvolution didnt work\n'] );
            isOk=false;            
            if( isAuto ), fprintf('\t\tREJECTED\n'); end
        else

        end

        % Get and check the maximum peak
        [ a, ~, tmax ] = getAbsMaxSeisTime( seis, t );
        fprintf('\tMax abs peak at t=%.3f\n',tmax);
        if( abs(tmax) > PSEARCH ),
            fprintf('\tGreater than threshold indicating no strong p-wave signal\n')
            fprintf( 'Note this logic only works for R/Z receiver functions\n');
            isOk=false;
            if( isAuto ), fprintf('\t\tREJECTED\n'); end
        end

        % check size of maximum peak isn't too large
        fprintf('\tMax amplitude = %f\n',a);
        if( a > 1 ),
            fprintf('\tGreater than 1, indicating deconvolution didn''t work\n');
            isOk=false;
            if( isAuto ), fprintf('\t\tREJECTED\n'); end            
        end

        % get size of second largest spike
        a2 = max( getAbsMaxSeisTime( seis, t , PSEARCH ), ...
            getAbsMaxSeisTime( seis, t , t(1), ...
            -PSEARCH) );
        fprintf('\tSize of the second largest spike: %f\n',a2)
        if( abs(a2)/a > MAXSPIKE2 ),
            fprintf(['\t2nd largest spike > %f x max spike ', ...
                'indicating another phase or noise is contaminating the ',...
                'signal\n'], MAXSPIKE2 )
            isOk=false;
            if( isAuto ), fprintf('\t\tREJECTED\n'); end
        end


        if( ~isAuto ),
            isOk = true;
            
            % Plot the receiver function
            clf;
            plot( t, seis, '-b', 'linewidth', 2 ); hold on;

            % alter axis dimensions to weed out excessive RFs
            axis([ min(t), max(t), -0.3, 1.0 ])

            title(sprintf('p = %f / baz=%f\n', rayp, baz ))

            % get user input
            fprintf('Keep with L click. Reject with R click...\n');
            [~,~,keepoption] = ginput(1);
            
            % process
            if( keepoption == 3),
                isOk = false;
            end
        end
        
        if( isOk )
            fprintf('keeping\n')
            plot( t, seis, '-g', 'linewidth', 2 ); 
            pause(pausetime);
        else
            fprintf('rejecting\n')
            plot( t, seis, '-r', 'linewidth', 2 ); 
            pause(pausetime);

            % directory for rejected rfn depends on current directory
            rejdir2 = fullfile( REJDIR,dirlist(di).name );
            
            % Make it if it doesn't exist
            if( ~exist( rejdir2,'dir') ), mkdir(rejdir2); end
            
            % Move the files
            movefile( filename, rejdir2 );
            fprintf('Moved %s to %s\n',filename, rejdir2);
        end

    end % END file loop
end % end directory loop

%---------------------------------------------------------------------------
%--- checkPRfn.m ends here
