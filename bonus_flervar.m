% Bonusuppgift MVE035

%% a) Solve non-linear system of equations
c = 10;
[X, Y] = meshgrid(linspace(-c, c), linspace(-c, c));
root2d = @(x) [
    x(1) * x(2) + exp(x(1)) + x(1) - 3
    x(1) * sin(x(1)) + x(2)^2 - 2
    ];

% Plot 'zero'-countour lines
n = numel(X);
Z1 = zeros(n, 1); Z2 = zeros(n, 1);
for i = 1:n
	y = root2d([X(i), Y(i)]);
	Z1(i) = y(1); Z2(i) = y(2);
end
Z1 = reshape(Z1, size(X)); Z2 = reshape(Z2, size(X));
hold on
contour(X, Y, Z1, [0 0])
contour(X, Y, Z2, [0 0])
hold off

% Solve the system of equations starting at the 4 points closest to origin
coords = [
	-3.5 -1.9
	-6.2 -1.5
	0.5 1.3
	1.1 -1.1
	];
for x0 = coords', fsolve(root2d, x0), end

%% b) Calculate extrema
f = @(x, y) (sin(x + y) + 3 * (x - 1/2 * y).^2) .* exp(-(x.^2 + y.^2));
[X, Y] = meshgrid(linspace(-5, 5), linspace(-5, 5));
Z = f(X, Y);
subplot(2, 1, 1), surf(X, Y, Z)
subplot(2, 1, 2), contour(X, Y, Z)

f2 = @(x) f(x(1), x(2)); nf2 = @(x) -f2(x);
fminunc(nf2, [-0.85 0.55])
fminunc(f2, [-0.35 -0.55])
fminunc(nf2, [0.96 -0.25])

%% c) Evaluate double interal
% D is {(x,y); 0 <= y <= 1 - x^2}
fun = @(x, y) y .* sin(y + x.^2);
ymax = @(x) 1 - x.^2;
integral2(fun, 0, 1, 0, ymax)
