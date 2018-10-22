%% a) Rita kurvan som implicit ges av ekvationen och beräkna längd
% x^2 + y^2 = 1 + 4.5 sin^2(xy)
% Insättning: 1 + 4.5 * (sin(r^2 * sin(2 * t) / 2))^2 - r^2 * (cos2(t) + sin2(t))

r = @(t) arrayfun(@(t) fzero(@(r) 1 + 4.5 * sin(r.^2 * sin(2 * t) / 2).^2 - r.^2, 1.1), t);
h = 2 * pi / 10000; T = 0:h:2 * pi;
X = r(T) .* cos(T); Y = r(T) .* sin(T);
plot(X, Y)
% Beräkna längden
% Få derivatan genom att interpolera approximation
drdt = [diff(r(T)) 0] / h; r_p = @(t) interp1(T, drdt, t);
l = integral(@(x) sqrt(r(x).^2 + r_p(x).^2), 0, 2 * pi)

%% b) Rita och beräkna längden av kurvan som på polär form ges av
r = @(theta) 2 + sin(5 * theta + 2.2 * cos(5 * theta));
r_p = @(theta) cos(5 * theta + 2.2 * cos(5 * theta)) .* (5 - 11 * sin(5 * theta));
T = linspace(0, 2 * pi);
X = r(T) .* cos(T); Y = r(T) .* sin(T);
plot(X, Y), axis equal
% Beräkna längden
l = integral(@(x) sqrt(r(x).^2 + r_p(x).^2), 0, 2 * pi)

%% c) Beräkna arean av rotationsytan som fås när y=f(x), 0<=x<=25, roterar runt x-axeln

f = @(x) 1.5 + sin(0.02 * x.^2);
dfdx = @(x) 0.04 * x .* cos(0.02 * x.^2);

% Mantelarea av avstympad kon: pi * (r1 + r2) * l, där l är sidlängden
area = 2 * pi * integral(@(x) f(x) .* sqrt(dfdx(x).^2 + 1), 0, 25)
volume = pi * integral(@(x) f(x).^2, 0, 25)
