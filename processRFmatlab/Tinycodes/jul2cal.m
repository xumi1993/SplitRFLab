function [month,day] = jul2cal (year,jday)
%JUL2CAL        converts from Julian day to calender day
%
%    JUL2CAL converts a Julian day given in year to the
%    calendar month and day of that month.
%
%    USAGE:
%           [month,day] = jul2cal (year,jday)
%
%    INPUT:
%           year       = calendar year
%           jday        = Julian day
%
%    OUTPUT:
%           month    = number of the month
%           day         = day of the month
%
%    EXAMPLE:
%           [month, day] = jul2cal (2003,355);
%
%    Kevin C. Eagar
%    December 24, 2006
%    Last Updated: 08/15/2007

isleap = eomday(year,2);
if isleap == 28;
    if jday >= 1 & jday <= 31; month = 1; day = jday; end
    if jday >= 32 & jday <= 59; month = 2; day = jday - 31; end
    if jday >= 60 & jday <= 90; month = 3; day = jday - 59; end
    if jday >= 91 & jday <= 120; month = 4; day = jday - 90; end
    if jday >= 121 & jday <= 151; month = 5; day = jday - 120; end
    if jday >= 152 & jday <= 181; month = 6; day = jday - 151; end
    if jday >= 182 & jday <= 212; month = 7; day = jday - 181; end
    if jday >= 213 & jday <= 243; month = 8; day = jday - 212; end
    if jday >= 244 & jday <= 273; month = 9; day = jday - 243; end
    if jday >= 274 & jday <= 304; month = 10; day = jday - 273; end
    if jday >= 305 & jday <= 334; month = 11; day = jday - 304; end
    if jday >= 335 & jday <= 365; month = 12; day = jday - 334; end
end
if isleap == 29;
    if jday >= 1 & jday <= 31; month = 1; day = jday; end
    if jday >= 32 & jday <= 60; month = 2; day = jday - 31; end
    if jday >= 61 & jday <= 91; month = 3; day = jday - 60; end
    if jday >= 92 & jday <= 121; month = 4; day = jday - 91; end
    if jday >= 122 & jday <= 152; month = 5; day = jday - 121; end
    if jday >= 153 & jday <= 182; month = 6; day = jday - 152; end
    if jday >= 183 & jday <= 213; month = 7; day = jday - 182; end
    if jday >= 214 & jday <= 244; month = 8; day = jday - 213; end
    if jday >= 245 & jday <= 274; month = 9; day = jday - 244; end
    if jday >= 275 & jday <= 305; month = 10; day = jday - 274; end
    if jday >= 306 & jday <= 335; month = 11; day = jday - 305; end
    if jday >= 336 & jday <= 366; month = 12; day = jday - 335; end
end
