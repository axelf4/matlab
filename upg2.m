r = @(x) (2 + sin(3 * x)) ./ sqrt(1 + exp(cos(x)));

theta = linspace(-5, 5 * pi);
x = r(theta) .* cos(theta);
y = r(theta) .* sin(theta);
hold on
plot(x, y)
plot(cos(theta), sin(theta))
hold off
axis equal

while 1
	[x, y, button] = ginput(1);
	if button ~= 1
		break;
	end
	[theta, rho] = cart2pol(x, y);
	theta
	fzero(@(x) r(x) - 1, theta)
end
