N = 10327589;

%% 1)
gamma = 1/4;
r = 0.01;
C = 1 + N - gamma / r * log(N);

Phi = @(S) gamma / (r * S) - 1;

I = @(S) gamma / r * log(S) - S + C;

S = linspace(1, 100);
% plot(S, arrayfun(Phi, S))
plot(S, I(S))

%% 2)
gamma = 1/4;
r = 0.001;
c = 1;
t = linspace(1, 10000);
plot(t, arrayfun(S, t))
