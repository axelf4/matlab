% FTF140/FYP300 Termodynamik och statistisk mekanik, 2020
% Inlämningsuppgifter I2, Uppgift 3 (c)
global k a b N P V
k = 1.38064852e-23; % Boltzmann constant
a = 1.370 * 2.7577e-49; b = 0.0387 * 1.6640e-27;
N = 6e23;

% Values at the critical point
Vc = 3 * N * b;
Pc = 1/27 * a / b^2;
Tc = 1/k * 8/27 * a/b;

P = @(V, T) N * k * T ./ (V - N * b) - a * N^2 ./  V.^2;
V = linspace(1.3 * N * b, 10 * Vc, 500);

%% Plot the isotherm
figure
T = 100;
plot(V, P(V, T))

%% Plot phase diagram
figure
T = linspace(82, Tc, 300);
plot(T, arrayfun(@getPv, T))
title('Phase diagram for N_2')
xlabel('Temperature [K]'), ylabel('Pressure [Pa]')
annotation('textbox', ...
    [0.3 0.7 0.04 0.03], ...
    'String', 'Vätska', 'FitBoxToText', 'on');
annotation('textbox', ...
    [0.6 0.4 0.03 0.03], ...
    'String', 'Gas', 'FitBoxToText', 'on');

function A = getArea(Pv, T)
    % Returns the area of the Maxwell construction.
    global k a b N P
    r = sort(roots([Pv, -N * (k * T + b * Pv), a * N^2, -a * b * N^3]));
    Vmin = r(1); Vmax = r(3);
    A = integral(@(V) P(V, T) - Pv, Vmin, Vmax);
end

function Pv = getPv(T)
    % Returns the vapor pressure as a function of temperature.
    global P V
    Ps = P(V, T);
    Pmin = min(Ps); Pmax = max(Ps);
    
    Pv = fminbnd(@(Pv) abs(getArea(Pv, T)), Pmin, Pmax);
end