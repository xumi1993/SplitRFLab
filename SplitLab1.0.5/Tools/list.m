function c = list(searchstr)
% list files in directory and output as cell array
% same on each platform
% in contrast to Matlab build-in function DIR, list can handle the ?
% wildcard

qmark = findstr(searchstr, '?');
if isempty(qmark)
    %we can use the build-in function, which is faster
    d = dir(searchstr);
    c = {d.name}';
else
    if ispc
        commandstr = ['dir ' searchstr ' /B'];
    else
        % perhaps you have to locate the "ls" command on your machine
        % /usr/bin is the standart location
        commandstr = ['/usr/bin/ls '  searchstr ' -1'];
    end
    [dummy, F] = system(commandstr);

    d = uint8(F);
    rows = find(d==10);% find newline character
    c = cell(length(rows), 1);



    c{1} = F(1:rows(1)-1);
    path = fileparts(searchstr);
    file = fullfile(path,c{1});
    if exist(file, 'file') == 2
        for i=2:length(rows)
            m = rows(i-1)+1;%start of line, without newline character
            n = rows(i)-1;  %end of line, without newline character
            c{i} = F(m:n);
        end
    else
        c = {};
    end
end