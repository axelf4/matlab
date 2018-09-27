% Uppgift 1

[x, y] = cirkel(0, 0, 2);
plot(x, y)
axis equal
hold on
hold off

%function [x, y] = cirkel(a, b, r)
% CIRKEL, Jimmie Hendrix var bättre än Dr Wattson
	%t = linspace(0, 2 * pi);
	%x = a + r * cos(t);
	%y = b + r * sin(t);
%end

%% Uppgift 2

[x, y] = ginput;
x = [x; x(1)]; y = [y; y(1)];
fill(x, y, 'g')

%%

