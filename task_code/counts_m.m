function lgt = counts_m(array, sign)
d = diff([0, array'==sign, 0]);
startidx = find(d==1);
lgt = find(d==-1)-startidx;
end
