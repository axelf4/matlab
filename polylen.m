function L = polylen(x, y)
	L = sum(sqrt(diff(x).^2 + diff(y).^2));
