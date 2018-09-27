% Uppgift 1

% h=6; n=40; m=20;
c = 2; d = 3;
% [S, T] = meshgrid(linspace(0, h, m), linspace(0, 2 * pi, n));
[S, T] = meshgrid(linspace(-d, d), linspace(0, 2 * pi));

% R = 1+sin(0.1*S.^2).^2;
R = sqrt(S.^2 / c^2 + 1); % Hyperboloid
% R = sqrt(S.^2 / c^2); % Kon
% R = S.^2 / c^2;

X = R .* cos(T); Y = R .* sin(T); Z = S;
surf(X, Y, Z);
axis equal, axis([-2 2 -2 2 -d d])

%% Uppgift 3 måla sfärer

% [S, T] = meshgrid(linspace(0, 3 / 2 * pi, 40), linspace(0, 3 / 2 * pi, 40));
[S, T] = meshgrid(linspace(0, pi, 40), linspace(0, 2 * pi, 40));
% r = 1;
% r = S .* T;
r = 1 ./ (1 + exp(-(T - pi))) ./ 2.^S;
X = r .* cos(T) .* sin(S);
Y = r .* sin(T) .* sin(S);
Z = r .* cos(S);

surf(X, Y, Z)
axis equal, axis([-1 1 -1 1 -1 1] * 1)