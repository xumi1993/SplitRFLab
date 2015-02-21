function word = getwords(s,delimiter)
if nargin==1
    delimiter = ' ';   
end
clear word; i=0;
while(any(s))
    i = i+1;
    [word{i},s]=strtok(s,delimiter);
end
