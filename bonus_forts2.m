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