%% a)

lambda = linspace(0, 3e-6);

options = optimset('TolX', 1e-10)

hold on
for T = [3000 4000 5000]
    plot(lambda, planck(lambda, T))
    lmax = fminbnd(@(lambda) -planck(lambda, T), 0, 1.5e-6, options);
	b = lmax * T
end

title('Emittansen som en funktion av lambda för fixt T.')
legend({'T = 3 000','T = 4 000', 'T = 5 000'}, 'Location', 'northeast')
hold off

%% b)

f = @(x) (5 - x) .* exp(x) - 5;
df = @(x) exp(x) .* (4 - x);
x = linspace(3, 6);
plot(x, f(x))

% Newton's teachings
x = 5; % Starting fucker
for i = 1:1000
	x = x - f(x) / df(x);
end
disp(['x is ', num2str(x)])

h=6.6256e-34;c=2.9979e8;k=1.3805e-23;
b = h * c / (k * x) % Solve the fucker for b

%% c)
Me = @(T) 5.67e-8 * T.^4; % All light

Ms = @(T) quadl(@(lambda) planck(lambda, T), 4e-7, 7e-7); % Visible light
q = @(T) Ms(T) ./ Me(T); % Le qvot
T = linspace(100, 10000); plot(T, arrayfun(q, T))
tic
for i = 1:100
	fminbnd(@(T) -q(T), 100, 10000); % Temp där kvoten mellan energin for synligt ljus och den totala energin som störst
end
toc

%% d)
q = @(T) Ms2(T) ./ Me(T); % Le qvot using ode45
T = linspace(100, 10000); plot(T, arrayfun(q, T))
tic
for i = 1:100
	fminbnd(@(T) -q(T), 100, 10000);
end
toc
fminbnd(@(T) -q(T), 100, 10000)

function e = Ms2(T)
	% Compute Ms using ode45
	[t, y] = ode45(@(t, y) planck(t, T), [4e-7 7e-7], 0);
	e = y(end);
end
