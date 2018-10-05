axis([0 1 0 1]), hold on
[x,y] = ginput(1);
plot(x, y, 'o')
xpol = x;
ypol = y;
while 1
	[x, y, knapp] = ginput(1);
	if knapp ~= 1, break; end
	xpol=[xpol; x];
	ypol=[ypol; y];
	plot(xpol(end-1:end),ypol(end-1:end),'o-')
end
xpol = [xpol; xpol(1)];
ypol = [ypol; ypol(1)];
plot(xpol(end-1:end),ypol(end-1:end),'o-')
hold off
axis equal

fill(xpol, ypol, 'g')

polylen(xpol, ypol)
polyarea(xpol, ypol)
