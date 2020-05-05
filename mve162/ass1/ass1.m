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

%% 2) Estimate r and solve model
T = readtable('FolkhalsomyndighetenCovid19.csv');
global cumCases
cumCases = cumsum(1 / 0.05 * T.Fall);

r = fminsearch(@(r) cost(r, gamma), 1e-7)
[t, y] = solveSIR(r, gamma, [0 25]);
fprintf('diff in removals: %d\n', (N - interp1(t, y(:, 1), 86 / 7)) - cumCases(end))
fprintf('some info:\n\ttotal number of infected: %f\n\ttotal number of dead people: %f\n', ...
    y(end, 2), y(end, 3))
% plot(t, y(:, 1)) % Plot S
writetable(array2table([t y], 'VariableNames', {'t', 'S', 'I', 'R'}), ...
    'sirResult.csv') % Export model result

%% Varying the parameters?
[R, Gamma] = meshgrid(linspace(0, r + 2e-7, 30), ...
    linspace(0, 10 * gamma, 30));
result = [R(:) Gamma(:) arrayfun(@calcInfectedRatio, R(:), Gamma(:))];
writematrix(result, 'paramHeatmap.txt')

%% Calculate 70+ age percentage
global Agedist percOver70 Casesdist pInfected70
Agedist = readtable('populationDist.csv');
percOver70 = sum(Agedist{15:end, vartype('numeric')}) / sum(Agedist{:, 2});

Casesdist = readtable('casesPerAge.csv');
Casesdist = addvars(Casesdist, Casesdist.Diseased ./ Casesdist.Infections, ...
    'NewVariableNames', 'Mortality');
pInfected70 = sum(Casesdist{8:end, 2}) / sum(Casesdist{:, 2});

r2 = fminsearch(@(r2) cost2(r, gamma, r2, p70), r / 5)
r1 = r1FromR2(r, r2)
[t, y] = solveS1S2IR1R2(r1, r2, gamma, p70, [0 30]);

%% 9)
I = 1:9;
[infected, dead] = arrayfun(@(i) calc(r1, r2, gamma, i), I);
writetable(array2table([I' infected' dead'], 'VariableNames', {'i', 'Infected', 'Dead'}), ...
    'isolationVals.csv')

function [infected, dead] = calc(r1, r2, gamma, i)
    % i=0 means all isolated
    global Agedist Casesdist
    avgMortality = @(C) mean(C.Infections / sum(C.Infections) .* C.Mortality);
    
    notIsolated = Casesdist(1:i,:); isolated = Casesdist(i + 1:end,:);
    
    percIsolated = sum(Agedist{2 * i + 1:end,2}) / sum(Agedist{:,2});
    [~, y] = solveS1S2IR1R2(r1, r2, gamma, percIsolated, [0 30]);
    
    infected = sum(y(end, 4:5));
    dead = avgMortality(notIsolated) * sum(y(end, 4)) ...
        + avgMortality(isolated) * sum(y(end, 5));
end

function [t, y] = solveSIR(r, gamma, tspan)
    % Return numerical solution to the SIR model.
    global N
    [t, y] = ode45(@(t, y) [
        -r * y(1) * y(2)
        r * y(1) * y(2) - gamma * y(2)
        gamma * y(2)
        ], tspan, [N; 1; 0]);
end

function [t, y] = solveS1S2IR1R2(r1, r2, gamma, percIsolated, tspan)
    global N
    [t, y] = ode45(@(t, y) [
        -r1 * y(1) * y(3)
        -r2 * y(2) * y(3)
        (r1 * y(1) + r2 * y(2)) * y(3) - gamma * y(3)
        r1 / (r1 + r2) * gamma * y(3)
        r2 / (r1 + r2) * gamma * y(3)
        ], tspan, [(1 - percIsolated) * N; percIsolated * N; 1; 0; 0]);
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
    [~, y] = solveSIR(r, gamma, [0, 200]);
    z = (N - y(end, 1)) / N;
end

function C = cost2(r, gamma, r2, p)
    global pInfected70
    r1 = r1FromR2(r, r2);
    [t, y] = solveS1S2IR1R2(r1, r2, gamma, p, [0 13]);
    S = interp1(t, y(:, [1, 2]), 13);
    C = (S(2) / sum(S) - pInfected70)^2;
end

function r1 = r1FromR2(r, r2)
    global percOver70
    r1 = r + (r - r2) * percOver70 / (1 - percOver70);
end