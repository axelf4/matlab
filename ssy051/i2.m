%% 1.
G = tf([16 8], [1 10 32 32 0]);

% The Kp factor only affects amplitude not phase,
% therefore we lookup ω st. ∠G(jω)= φ_m - 180° and let Kp=1/|G(jω)|.
Kp = 10^(14.2 / 20);

L = Kp .* G;

[mag, phase, wout] = bode(L, 0.1)

%% 2.
K = 1;
global G FPI L
s = tf('s');
G = tf(K * [-0.5 1], [0.5 1 0]);
FPI = @(Kp, Ki) tf(Ki, [1 0]) + tf(Kp);
L = @(Kp, Ki) G * FPI(Kp, Ki);

%% a)
results = table;
Kps = [0.1, 0.2, 0.4];
for i = 1:3
    Kp = Kps(i);
    Ki = getKiFromKpConstMargin(Kp);
    [~, ~, ~, wc] = margin(L(Kp, Ki));
    
    F = FPI(Kp, Ki);
    Gry = feedback(G * F, 1);
    
    [sv, w] = sigma(Gry);
    wb = interp1(sv, w, 1/sqrt(2)); % -3 dB
    
    % pause(5);
    
    [y, t] = step(Gry);
    S = lsiminfo(y, t, 1);
    
    result = struct('Kp', Kp, ...
        'Ki', Ki, ...
        'wc', wc, 'wb', wb, ...
        'SettlingTime', S.SettlingTime);
    results = [results; struct2table(result)];
end
results

subplot(2, 3, 1)
sigma(getGry(results.Kp(1), results.Ki(1)), getGry(results.Kp(2), results.Ki(2)), getGry(results.Kp(3), results.Ki(3)))
title('G_{ry}')
plotLabel = @(i) sprintf('K_p: %d, K_i: %d', results.Kp(i), results.Ki(i));
legend(plotLabel(1), plotLabel(2), plotLabel(3))
subplot(2, 3, 4)
step(getGry(results.Kp(1), results.Ki(1)), getGry(results.Kp(2), results.Ki(2)), getGry(results.Kp(3), results.Ki(3)))

subplot(2, 3, 2)
sigma(getGvy(results.Kp(1), results.Ki(1)), getGvy(results.Kp(2), results.Ki(2)), getGvy(results.Kp(3), results.Ki(3)))
title('G_{vy}')
plotLabel = @(i) sprintf('K_p: %d, K_i: %d', results.Kp(i), results.Ki(i));
legend(plotLabel(1), plotLabel(2), plotLabel(3))
subplot(2, 3, 5)
step(getGvy(results.Kp(1), results.Ki(1)), getGvy(results.Kp(2), results.Ki(2)), getGvy(results.Kp(3), results.Ki(3)))

subplot(2, 3, 3)
sigma(getGwu(results.Kp(1), results.Ki(1)), getGwu(results.Kp(2), results.Ki(2)), getGwu(results.Kp(3), results.Ki(3)))
title('G_{wu} = G_{ru}')
plotLabel = @(i) sprintf('K_p: %d, K_i: %d', results.Kp(i), results.Ki(i));
legend(plotLabel(1), plotLabel(2), plotLabel(3))
subplot(2, 3, 6)
step(getGwu(results.Kp(1), results.Ki(1)), getGwu(results.Kp(2), results.Ki(2)), getGwu(results.Kp(3), results.Ki(3)))

%% e) Pareto optimization of J_v/J_u
Kp = linspace(0.09, 0.8);
Ki = arrayfun(@(Kp) getKiFromKpConstMargin(Kp), Kp);
Ju = Kp; Jv = 1 ./ Ki;
pl = plot(Ju, Jv);
xlabel('J_u'), ylabel('J_v')
title('e) J_v vs J_u för konstant \phi_m = 45')
for i = 1:3
    datatip(pl, results.Kp(i), 1 ./ results.Ki(i))
end
text(0.2, 80, '\phi_m = 45')

function Gry = getGry(Kp, Ki)
    global G FPI
    F = FPI(Kp, Ki);
    Gry = feedback(G * F, 1);
end

function Gvy = getGvy(Kp, Ki)
    global G FPI
    F = FPI(Kp, Ki);
    Gvy = G / (1 + G * F);
end

function Gwu = getGwu(Kp, Ki)
    global G FPI
    F = FPI(Kp, Ki);
    Gwu = F / (1 + G * F);
end

function phim = getPhimFromKi(Kp, Ki)
    global L
    [~, phim] = margin(L(Kp, Ki));
end

function Ki = getKiFromKpConstMargin(Kp)
    Ki = fminbnd(@(Ki) (getPhimFromKi(Kp, Ki) - 45).^2, 1e-3, 1e2);
end