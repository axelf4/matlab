function A = polyarea(x, y)
	n = length(x);
	A = abs(sum((x(2:n) + x(1:n-1)) .* (y(2:n) - y(1:n-1)))) / 2;
