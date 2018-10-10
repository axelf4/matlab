function m = min_median(v)
% MIN_MEDIAN Beräknar medianen av elementen i vektorn v
s = sort(v)
c = (length(v) + 1) / 2;
m = (s(floor(c)) + s(ceil(c))) / 2;
