%SL_checkversion
global config
if not(ispref('Splitlab'))
    SL_preferences([])
    SplitlabConfiguration = getpref('Splitlab','Configuration')
    SplitlabAssociations  = getpref('Splitlab','Associations')
    SplitlabHistory       = getpref('Splitlab','History')
    disp(' **** Splitlab Preferences sucessfully created ****')
end

if isempty(config)
    evalin('base','global eq thiseq config rf');
    config = getpref('Splitlab', 'Configuration');   
    d=datevec(now);
    config.twin = [3 1 1976 d([3 2 1])];
end


default  = SL_defaultconfig;
N    = fieldnames(default) ;

updated=struct([]);
%set non existing fields to default values
for k = 1:length(N)
    thisfield = N{k};
    if ~strcmp(thisfield,'version')

        if ~isfield(config, thisfield)
            config.(thisfield)     = default.(thisfield);
            updated(1).(thisfield) = default.(thisfield);
        end
    end
end
if ~isempty(updated)
    disp(' ')
    disp('Project version does not match the current splitlab version!')
    disp('The following fields are added to or updated in your configuration:')
    disp(' ')
    disp(updated)
end

%% check preferences
% this is necessary on multiuser environments. 
if ~ispref('Splitlab')
    SL_preferences(SL_defaultconfig)
end
if ~ispref('Splitlab','History')
    addpref('Splitlab','History', {})
end
