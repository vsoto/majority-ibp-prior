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
function [t, cl] = ibp_rule_2classes(votes, ibtable)
% Returns the vote index t when the pruning rule is fulfilled.
% cl is the predicted class label in a two-way problem (0, 1)
tn = zeros(2,1);
T = length(votes);

for j = 1:T
    c = votes(j);
    tn(c+1) = tn(c+1) + 1;
    [tns, indexSort] = sort(tn, 'descend');            
    imax = indexSort(1);           
	% Pruning rule
    if (j == T) || (ibtable(tns(1)+1, tns(2)+1) == 1)
        t = j;
        cl = imax - 1;
        break;
    end
end

