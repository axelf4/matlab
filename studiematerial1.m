% Welcome my dude

%% Uppgift 5
sum((1:5).^2)

%% Uppgift 6
% Hitta alla nollställen till f(x) = x^2 - cos x
f = @(x) x.^2 - cos(x);
x = linspace(-1.0, 1.0);
plot(x, f(x))
grid on
fzero(f, -0.8)
fzero(f, 0.8)
