% Look for all .m files one directory below this and run them
clear
dirlist = dir('test_*');
dirlist = dirlist( [dirlist.isdir] );
output = '';

for i=1:numel(dirlist),
    % save the current directory
    wd = cd;
    
    % Go to sub directory
    cd(dirlist(i).name);
    
    % Get list of all .m files
    scriptlist = dir('*.m');
    scriptlist = {scriptlist.name};
    
    % Loop through all scripts and run them
    for j = 1:numel(scriptlist),
        scriptname = char(scriptlist{j}(1:end-2));
        fprintf('Running %s\n', scriptname);
        try 
            eval( scriptname );
            output = sprintf('%s%s/%s ... PASS\n', output, dirlist(i).name, ...
                scriptname);
        catch ME
            cd(wd);
            error(ME.getReport)
        end
    end
    
    % Go back
    cd(wd);
end

fprintf(output)

%-----------------------------------------------------------------
