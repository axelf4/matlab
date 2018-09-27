y = @(u) sin(u).^2 ./ u.^2;

x = linspace(-5, 5, 300);
plot(x, y(x));
fminbnd(y, -5, 5)
fminbnd(@(x) -y(x), -5, 5)
