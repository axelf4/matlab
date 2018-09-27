clf

x = linspace(-1, 1);
plot(x, f(x));
hold on

approx = [-1, -0.5, 0.3];
for i = 1:length(approx)
	x = findroot(approx(i))
	y = f(x)
	circle(x, y);
end

axis equal
hold off

function x = findroot(x)
	f = @(x) x.^3 - cos(4 * x);
	Df = @(x) 3 * x.^2 + 4 * sin(4 * x);


	kmax = 10; tol = 0.5e-8;
	for k = 1:kmax
		h = -f(x) / Df(x);
		x = x + h;
		disp([x h])
		if abs(h) < tol, break, end
	end
end

function circle(x, y)
	r = .1;
	rectangle('Position', [x - r / 2, y - r / 2, r, r], 'Curvature', [1 1]);
end
