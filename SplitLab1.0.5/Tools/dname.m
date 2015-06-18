function newname = dname(yyyy, mm, dd, hh, mimi, ss)
datename = datenum(yyyy,mm,dd,hh,mimi,ss);
year = datestr(datename,10);
jjj = dayofyear(yyyy,mm,dd);
hour = datestr(datename,'HH');
min = datestr(datename,'MM');
sec = datestr(datename,'SS');
if jjj < 10
    newname = [year '.00' num2str(jjj) '.' hour '.' min '.' sec];
elseif jjj < 100
    newname = [year '.0' num2str(jjj) '.' hour '.' min '.' sec];
else
    newname = [year '.' num2str(jjj) '.' hour '.' min '.' sec];
end
return