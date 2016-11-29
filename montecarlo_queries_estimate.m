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
function nq = montecarlo_queries_estimate(num_classes, ibtable, prior)
% MONTECARLO_QUERIES_ESTIMATE  Computes a monte-carlo estimate for the
%   number of queried trees by generating ten thousand voting vectors that
%   follow the voting distribution given by the prior.
%
if (num_classes == 2)
    nq = queries_estimate_2classes(ibtable, prior);
elseif (num_classes == 3)
    nq = queries_estimate_3classes(ibtable, prior);
end

function nq = queries_estimate_2classes(ibtable, prior)

T = length(prior)-1;
N = 10000;
votes = [zeros(1,T); tril(ones(T))];

iib = randsample(T+1, N, true, prior);

nq = 0;
for i=1:N
    ivotes = votes(iib(i),randperm(T));
    t = ibp_rule_2classes(ivotes, ibtable);
    nq = nq + t;
end

nq = nq/N;
stdq = 1;



function nq = queries_estimate_3classes(ibtable, prior)

T = length(prior) - 1;
N = 10000;
iib2 = randsample(T+1, N, true, sum(prior));
priorn = prior./repmat(sum(prior), size(prior, 1), 1);
iib1 = ones(N, 1);
for i = 1:N
    iib1(i) = randsample(T+1, 1, true, priorn(:, iib2(i)));
end
iib3 = T - iib1 - iib2 + 2 + 1;

nq = 0;
for i = 1:N
    ivotes = [zeros(1, iib1(i) - 1), ones(1, iib2(i) - 1), 2*ones(1, iib3(i) - 1)];
    ivotes = ivotes(1, randperm(T));
    t = ibp_rule_3classes(ivotes, ibtable);
    nq = nq + t;
end

nq = nq/N;
stdq = 1;

