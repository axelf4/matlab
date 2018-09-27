nearestNumbers([30 46 16 -46 35 44 18 26 25 -10])

function [index1, index2] = nearestNumbers(a)
	f = @(f, i) f(f, a(i + 1:end));
	arrayfun(@(i) f(f, i), 1:length(a))
	index1 = 1;
	index2 = 2;
end
