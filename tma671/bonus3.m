% Bonus problem 3: Computation of eigenvalues - orthogonal iteration
%
%

%% a) Generate the matrix to test on

A = delsq(numgrid('S', 13));

%% b) Implement orthogonal iteration

tic
[lambda, numIter] = orthoIter(A)
toc

%% c) Calculate the six smallest eigenvalues instead

tic
[lambda, numIter] = invOrthoIter(A)
toc

function [lambda, numIter] = orthoIter(A)
    p = 6; [rows, ~] = size(A); X = eye(rows, p);
    % The p largest *exact* eigenvalues
    exact = subsref(flip(eig(A)), struct('type', '()', 'subs', {num2cell(1:p, 2)}));
    
    numIter = 0;
    while true
        [Q, R] = qr(X, 0);
        
        lambda = diag(R); % The eigenvalues end up on the diagonal of R
        if all(abs(lambda - exact) <= tol), return, end
        
        X = A * Q;
        numIter = numIter + 1;
    end
end

function [lambda, numIter] = invOrthoIter(A)
    p = 6; [rows, ~] = size(A); X = eye(rows, p);
    % The p smallest *exact* eigenvalues
    exact = subsref(eig(A), struct('type', '()', 'subs', {num2cell(1:p, 2)}));
    
    C = chol(A); % A = C' * C
    
    numIter = 0;
    while true
        [Q, R] = qr(X, 0);
        
        lambda = 1 ./ diag(R); % The eigenvalues end up on the diagonal of R
        if all(abs(lambda - exact) <= tol), return, end
        
        X = C \ (C' \ Q);
        numIter = numIter + 1;
    end
end

function y = tol
    % Returns the absolute tolerance to be used.
    y = 1e-6;
end