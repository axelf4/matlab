%% Uppgift 4

f = @(x) x .* sin(x);

n = 100;
a = 0; b = 1;
h = (b - a) / n;
x = linspace(a, b, n + 1);

fprintf('högerregel: %f\n', sum(h * f(x(2:n + 1))));
fprintf('vänsterregel: %f\n', sum(h * f(x(1:n))));

fprintf('mittpunkt: %f\n', sum(h * f((x(1:n) + x(2:n + 1)) ./ 2)));

fprintf('trapetsfan: %f\n', sum(h / 2 * (f(x(1:n)) + f(x(2:n + 1)))));

%% Uppgift 5

g = @(x) exp(-x.^2 / 2);
h = @(x) x.^2 - 3 * x + 2;
hold on
x = linspace(0, 3, 1000);
plot(x, g(x));
plot(x, h(x));
hold off

f = @(x) g(x) - h(x);
a = fzero(f, 0.5)
b = fzero(f, 2.1)
q = integral(f, a, b)

%% Uppgift 6

[t, U] = ode45(@(t, u) cos(3 .* t) - sin(5 .* t) .* u, [0 15], 2)
plot(t, U)

%% Uppgift 7

L = 0.1;
theta = pi * [30 45 60] / 180;
g = 9.82;
start = [30, 45, 60];

for i = (1:length(start))
    subplot(length(start), 1, i);
    y0 = [start(i) * pi / 180, 0];
    ode45(@(t, y) [y(2); -g .* sin(y(1)) ./ L], [0 2], y0)
end
axis equal