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
function table = ibp_hyperg_2classes(TT, alpha, prior)
% IBP_HYPERG_2CLASSES Computes an IBP table for a binary problem,
% for an ensemble of size TT, confidence alpha and prior knowledge of the
% voting process.
% The resulting table is indexed by the votes received for class 0 and 1,
% and contains ones or zeros depending if the voting process can be halted
% or not with confidence alpha.
% For example : table(3, 45) will return a 1 if the voting process can be
% halted when 2 votes (2 + 1) have been cast for class 0, and 44 (44 + 1)
% votes have been cast for class 1.
%
pp = primes(TT);
ff = zeros(TT, length(pp));

for t=1:TT
    f = factor(t);
    for i = 1:length(pp)
        ff(t,i) = sum(f==pp(i));
    end
end

fff = zeros(length(pp), TT+1,TT+1);
for iT=0:TT
    for it=0:iT
        fff(:, iT+1, it+1) = sum(ff(iT-it+1:iT,:), 1);
    end
end

table=zeros(TT+1);
for t1 = 0:TT
    for t2 = 0:TT-t1
        t = [t1, t2];
        [num, dem] = compute_num_and_dem(TT,t,fff,pp',prior);
        table(t1+1, t2+1) = (num >= alpha * dem);
    end 
end

function [num, dem] = compute_num_and_dem(TT, t, fff, pp, prior)
num = 0.0;
dem = 0.0;

T1 = t(1);
T2 = TT - T1;

[~, i] = min(t);
[~, j] = max(t);

while ((T1 <= (TT-t(2))) && (T2 >= t(2)))
    T = [T1, T2];
    aux = fff(:, T1+1, t(1)+1) + fff(:, T2+1, t(2)+1);
    q = prior(T1+1) * prod(pp.^aux);
    dem = dem + q;
    if (T(i) < T(j))
        num = num + q;
    end
    T1 = T1+1;
    T2 = T2-1;
end

