global N
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
T = readtable('FolkhalsomyndighetenCovid19.csv');
global cumCases
cumCases = cumsum(1 / 0.05 * T.Fall);
cumCases(end)

r = fminsearch(@(r) cost(r, gamma), 1e-7)
[t, y] = solveSIR(r, gamma, [0 25]);
fprintf('diff in removals: %d\n', (N - interp1(t, y(:, 1), 86 / 7)) - cumCases(end))
fprintf('some info:\n\ttotal number of infected: %f\n\ttotal number of dead people: %f\n', ...
    y(end, 2), y(end, 3))
% plot(t, y(:, 1)) % Plot S
% Export model result
writetable(array2table([t, y], ...
    'VariableNames', {'t', 'S', 'I', 'R'}), ...
    'sirResult.csv')

%% Varying the parameters?
[R, Gamma] = meshgrid(linspace(0, r + 2e-7, 30), ...
    linspace(0, 10 * gamma, 30));
params = [R(:) Gamma(:)];
Z = arrayfun(@calcInfectedRatio, R(:), Gamma(:));
result = [R(:) Gamma(:) Z(:)];
writematrix(result, 'paramHeatmap.txt')

function [t, y] = solveSIR(r, gamma, tspan)
    % Return numerical solution to the SIR model.
    global N
    [t, y] = ode45(@(t, y) [
        -r * y(1) * y(2)
        r * y(1) * y(2) - gamma * y(2)
        gamma * y(2)
        ], tspan, [N; 1; 0]);
end

function C = cost(r, gamma)
    global N cumCases
    tq = (38 / 7):0.5:12; % Weeks to query
    % tq = 2:0.5:6; % Vec of weeks
    realSvals = N - cumCases(floor(7 * tq));
    
    [t, y] = solveSIR(r, gamma, [0, tq(end)]);
    Svals = interp1(t, y(:, 1), tq);
    
    C = norm(realSvals - Svals);
end

function z = calcInfectedRatio(r, gamma)
    global N
    [t, y] = solveSIR(r, gamma, [0, 200]);
    z = (N - y(end, 1)) / N;
end