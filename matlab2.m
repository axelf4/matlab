% Uppgift 1
% help tan;

x = (-pi/2)+0.01:0.01:(pi/2)-0.01;
plot(x,tan(x)), grid on

%% Uppgift 2

d = linspace(2, 14, 5)

%% Uppgift 3
x = linspace(0, 8);
plot(x, x - x .* cos(7 * x))

%% Uppgift 4

t = linspace(0, 2 * pi);
subplot(1, 2, 1)
plot(cos(t) + cos(3 * t), sin(2 * t))
subplot(1, 2, 2)
plot(cos(t) + cos(4 * t), sin(2 * t))
axis equal

%% Uppgift 5

hold on
pos = [-1/2 -1/2 1 1];
rectangle('Position', pos, 'Curvature', [1 1], 'FaceColor', 'g')
rectangle('Position', pos .* sqrt(2) / 2, 'FaceColor', 'y')
hold off, axis equal

%% Uppgift 6, Skript FleraJävlaKast
x = linspace(0, 14);
plot([0 14], [0 0], 'g') % Grön jävla gräsmatta
hold on
var = [15, 1.6; 30, 3.2; 45, 4.6];

for i = 1:3
        theta = var(i, 1); th = var(i, 2);
        theta
plot(x, kastbana(x, theta)), text(6.4, th, sprintf('%d^o', theta))
end
hold off

title('Kastbana med v_0=10 m/s och olika \theta')
xlabel('äks'), ylabel('y av äks')
axis equal, axis([0 14 -2 6])

%% Uppgift 7
[X, Y] = meshgrid(linspace(-2, 2), linspace(-2, 2));
f = @(x, y) -x .* y .* exp(-2 * (x.^2 + y.^2));
surf(X, Y, f(X, Y))