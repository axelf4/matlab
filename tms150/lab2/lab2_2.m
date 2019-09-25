data = importdata('atlantic.txt'); n = length(data); % Load the atlantic data

% Estimate Gumbel parameters
[beta, mu] = subsref(num2cell(est_gumbel(data)), struct('type', '{}', 'subs', {{':'}}));

%% a) Using the inversion cdf method: Derive formula to gen random draws from a Gumbel dist
Finv = @(y) mu - beta * log(-log(y));
sample_Gumbel = @(n) Finv(rand(n, 1));

%% b) Simulate a sample of Gumbel of size n and do qqplot
X = sample_Gumbel(n);
qqplot(data, X) % Check that the distributions of the atlantic and simulated data agree

%% c) Provide parametric bootstrapped 95% CIs for parameters using the percentile method
rng(123) % For reproducibility
% B = 10000; % Number of simulations
B = 10; % Number of simulations
alpha = 1 - .95;

deal2 = @(x) deal(x(1), x(2)); % To work around est_gumbel not returning two outputs
[beta_star, mu_star] = arrayfun(@(x) deal2(est_gumbel(sample_Gumbel(n))), 1:B);

beta_CI = prctile(beta_star, [100 * alpha / 2, 100 * (1 - alpha / 2)])
mu_CI = prctile(mu_star, [100 * alpha / 2, 100 * (1 - alpha / 2)])
