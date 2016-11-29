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
function [flag, majority_class] = ibp_confidence_pruning(table, class_votes, use_prior)

num_classes = length(class_votes);
[sorted_votes, sorted_classes] = sort(class_votes, 'descend');
majority_class = sorted_classes(1) - 1;

if (use_prior)
    if (num_classes == 2)
        flag = table(class_votes(1) + 1, class_votes(2) + 1) == 1;
    elseif (num_classes == 3)
        flag = table(class_votes(1) + 1, class_votes(2) + 1, class_votes(3) + 1) == 1;
    end
else
    maximum = sorted_votes(1);
    if (num_classes == 2)
        minimum = sorted_votes(2);
        flag = maximum >= table(sorted_classes(2), minimum + 1);
    elseif (num_classes == 3)
        rest = sorted_votes(2:end);
        flag = maximum >= get_threshold(table, rest);
    end
end


end