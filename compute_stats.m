% Instance-Based Pruning. Copyright (C) 2016 Victor Soto,
%     Escuela Politecnica Superior, Madrid, UAM
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
function results = compute_stats(results_per_example, num_classes, table, prior, use_hypergeometric_prior)
% COMPUTE_STATS  Returns matrix with the following aggregated values
%   Column 1: Average ensemble error rate.
%   Column 2: Average SIBA-pruned ensemble error rate.
%   Column 3: Average disagreement rate between full ensemble and
%   SIBA-pruned ensemble.
%   Column 4: Average number of queried trees by the full ensemble.
%   Column 5: Average number of queried trees by the SIBA-pruned ensemble.
%   Column 6: Average speed-up of the SIBA-pruned ensemble with respect to
%   the full ensemble.
%   Column 7: Monte carlo estimate of average number of queried trees.
%
%   results = compute_stats(results_per_example) computes columns 1-6.
%   results = compute_stats(results_per_example, test_votes, table, prior,
%                           use_hypergeometric_prior) computes columns 1-7.
%
results = zeros(1, 7);
if (nargin >= 1)
    %ErrorRate
    results(1, 1) = mean((results_per_example(:, 4)~=results_per_example(:, 3)))*100;
    %ErrorRate IB-Boosting
    results(1, 2) = mean((results_per_example(:, 4)~=results_per_example(:, 2)))*100;
    %Disagreement Boosting vs IB-Boosting
    results(1, 3) = mean((results_per_example(:, 3)~=results_per_example(:, 2)))*100;
    %Number of trees alpha=100%
    results(1, 4) = mean(results_per_example(:, 5));
    %Number of trees with prune
    results(1, 5) = mean(results_per_example(:, 1));
    %Total Speed Up
    results(1, 6) = sum(results_per_example(:, 5))/sum(results_per_example(:, 1));
end
if (nargin > 1 && use_hypergeometric_prior)
    results(1, 7) = montecarlo_queries_estimate(num_classes, table, prior);
end
end