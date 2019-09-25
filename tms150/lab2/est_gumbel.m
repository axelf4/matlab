function out = est_gumbel(data)
%EST_GUMBEL Maximum likelihood parameter estimates for Gumbel distribution
%
% CALL: out = est_gumbel(data)
%       beta = out(1)
%       mu   = out(2)

%make sure it is a column vector
data=data(:); 

start=6^(1/2)/pi*std(data); % Moment estimate of parameter beta
% Use the moment estimate of beta as a starting/temporary ok value for the optimization leading
% to maximum likelihood estimation of beta
beta = fzero(@(x) wgumbafit(x,data),start,optimset); % the max.lik.est. of beta
mu = -beta*log(mean(exp(-data/beta))); % the max.lik.est. of mu
out = [beta mu];

function l=wgumbafit(a,data)
l=a-mean(data)+mean(data.*exp(-data/a))/mean(exp(-data/a));


% Reference: page 3 in https://pdfs.semanticscholar.org/0f03/1de25c3b96b5328682dec5cc006d668b9465.pdf