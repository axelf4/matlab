% Wavelet-analysis for data compression
%
% http://www.math.chalmers.se/Math/Grundutb/CTH/tma671/1819/bonus/bonus2.pdf

f = @(x) exp(x) .* cos(pi * x);

v = [37 33 6 16 26 28 18 4]';
le_wavelet(v, 3);

cases = {{16, 1.5}, {32, 1.0}, {64, .5}};
for i = 1:length(cases)
    [n, epsilon] = cases{i}{:};
    
    X = linspace(0, 3, n)';
    v = f(X);
    [v_tilde, compression_ratio] = le_wavelet(v, epsilon);
    
    subplot(3, 1, i), stairs(X, [v, v_tilde])
    title(sprintf('n=%d, eps = %.2f', n, epsilon))
    
    fprintf(1, 'n=%d, eps = %.1f: Error is %f and the compression ratio is %f\n', ...
        n, epsilon, ...
        norm(v - v_tilde) / n, compression_ratio)
end

legend('$f(x)$', '$\tilde{v}$', 'Location', 'southwest', 'Interpreter', 'LaTeX')
sgtitle('The function $f(x)$ versus the approximation $\tilde{v}$', ...
    'Interpreter', 'LaTeX')

function [v_tilde, compression_ratio] = le_wavelet(v, epsilon)
    % Wavelet-approximation.
    % v is the data column-vector
    
    n = length(v); p = log2(n);
    assert(mod(p, 1) == 0, 'Data is of bad size.')
    
    A = cell(1, p); w = v;
    for i = 1:p
        M = eye(n);
        c = 2^(p - i + 1) / 2;
        % Set A:s
        M(1:c, 1:2:n) = 1/2 * eye(c, n / 2);
        M(1:c, 2:2:n) = 1/2 * eye(c, n / 2);
        % Set B:s
        M((1:c) + c, 1:2:n) = 1/2 * eye(c, n / 2);
        M((1:c) + c, 2:2:n) = -1/2 * eye(c, n / 2);
        
        A{i} = M;
        w = A{i} * w;
    end
    
    w_tilde = w;
    w_tilde([false; abs(w(2:end)) <= epsilon]) = 0; % Zero out small distance values
    compression_ratio = nnz(w_tilde) / nnz(w);
    
    v_tilde = w_tilde;
    for i = p:-1:1, v_tilde = A{i} \ v_tilde; end
end
