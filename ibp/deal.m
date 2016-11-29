% Instance-Based Pruning. Copyright (C) 2009 Gonzalo Martinez Munoz,
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
% DEAL See ibp_lookuptable fuction for usage
%
function [c, n] = deal(N, nclases, tt, max_value, class_from_which_to_reduce)
% Original Author: Gonzalo Martinez Munoz (gonzalo.martinez@uam.es)
% Contributors: Daniel Hernandez-Lobato, Alberto Suarez
% Changelog: 
%     Feb-2009: first version v1.0 
%

if nclases == 1
    c = uint8(N+tt(1));
    n = 1;
    if c > max_value
        error('This cannot be!!!');
    end
    return;
elseif nclases == 2
    if max_value >= tt(1) + N
        c = [(tt(1):tt(1)+N)' (tt(2)+N:-1:tt(2))'];
    elseif max_value >= tt(2) + N
        c = [(tt(1):max_value)' (tt(2)+N:-1:tt(2)+tt(1)+N-max_value)'];
    else
        c = [(tt(1)+tt(2)+N-max_value:max_value)' (max_value:-1:tt(2)+tt(1)+N-max_value)'];
    end
    if class_from_which_to_reduce == nclases - 1
        c = uint8(c(:,1));
    else
        c = uint8(c);
    end
    n = ones(size(c,1),1);
    return;
end

if class_from_which_to_reduce == nclases - 1
    n = ones(0,1);
    c = zeros(0, 1, 'uint8');
else
    n = ones(0,1);
    c = zeros(0, nclases - class_from_which_to_reduce, 'uint8');
end

max_value = min(max_value, tt(1) + N);
tt_other = sum(tt(2:end));

if ~exist('class_from_which_to_reduce', 'var')
    class_from_which_to_reduce = 0;
end

for ni = 0:max_value-tt(1)
    if ceil((N - ni + tt_other)/(nclases-1)) > max_value
        continue;
    end
    if class_from_which_to_reduce == nclases - 1
        n(end+1,1) = count(N-ni, nclases-1, max_value);
        c(end+1,1) = ni;
    else
        [all ns] = deal(N-ni, nclases-1, tt(2:end), max_value, class_from_which_to_reduce);
        s = size(ns, 1);
        c(end+1:end+s, :) = [ni*ones(s,1)+tt(1) all];
        n(end+1:end+s, 1) = ns;
    end
end

