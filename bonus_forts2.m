c = 15;
[x, y] = meshgrid(linspace(0, 3, c), linspace(0, 3, c));
u = cos(x - y); v = sin(x .* y);
quiver(x, y, u, v), hold on

initial = [
    1 1
    0 0
    0 1
    2.3 1
    0 1.3
    1.5 3
    3 0.2
    ];
initial = [x(:) y(:)];
for i = 1 : length(initial)
    x0 = initial(i, 1); y0 = initial(i, 2);
    
    % y is [x, y]
    odefun = @(t, y) [cos(y(1) - y(2)); sin(y(1) * y(2))];
    
    tspan = [0 100];
    [t, y] = ode45(odefun, tspan, [x0 y0]);
    plot(y(:, 1), y(:, 2))
end

hold off, axis([0 3 0 3] + 0.25 * [-1 1 -1 1])

%%

a = 1; b = 1;
[x, y] = meshgrid(linspace(-1, 1), linspace(-1, 1));

ellipticParaboloid = @(x, y) x.^2 / a^2 + y.^2 / b^2;
hyperbolicParaboloid = @(x, y) x.^2 / a^2 - y.^2 / b^2;
f = @(x, y) x ./ y ./ (x.^2 + y.^2);

surf(x, y, ellipticParaboloid(x, y))
surf(x, y, hyperbolicParaboloid(x, y))
surf(x, y, f(x, y))