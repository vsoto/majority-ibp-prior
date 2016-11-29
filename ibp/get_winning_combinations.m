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
% 
% GET_WINNING_COMBINATIONS See ibp_lookuptable fuction for usage
% 
function [c, n] = get_winning_combinations(tt, T, expected_classes_k)
% Original Author: Gonzalo Martinez Munoz (gonzalo.martinez@uam.es)
% Contributors: Daniel Hernandez-Lobato, Alberto Suarez 
% Changelog: 
%     Feb-2009: first version  v1.0 
% 

t = sum(tt);
nclases = size(tt,2);

if ~exist('expected_classes_k', 'var')
    expected_classes_k = nclases;
end

if nargout == 0
    save_data = true;
else
    save_data = false;
end

N = T - t;
%c = 0;
c = zeros(0, expected_classes_k, 'uint8');
n = ones(0, 1, 'uint8');
limit = intmax('uint8');

if expected_classes_k < nclases && all( tt(expected_classes_k:end) == tt(end) ) 
    class_from_which_to_reduce = nclases - expected_classes_k;
else
    class_from_which_to_reduce = 0;
end

if save_data
    f=fopen(['TT_' num2str(nclases) '_' num2str(expected_classes_k) '.bin'], 'w');
    if nclases > expected_classes_k+1
        f2=fopen(['nTT_' num2str(nclases) '_' num2str(expected_classes_k) '.txt'], 'w');
    end
end
for T1=ceil(T/nclases):tt(1)+T-t
    if T1 < tt(1)
        continue;
    end
    [combs ns] = deal(N-(T1-tt(1)), nclases-1, tt(2:end), T1-1, class_from_which_to_reduce);
    s = size(combs, 1);
    if save_data
        combs = [T1*ones(s,1) combs]';
        fwrite(f, combs, 'uint8');
    else
        c(end+1:end+s, :) = [T1*ones(s,1) combs];
    end
    
    if nclases > expected_classes_k+1
        if save_data
            fprintf(f2, '%d ', ns);
        else
            m = max(ns);
            if m > limit
                if m <= intmax('uint16')
                    n = uint16(n);
                    limit = intmax('uint16');
                    disp('Going to 16 bits integer');
                elseif m <= intmax('uint32')
                    n = uint32(n);
                    limit = intmax('uint32');
                    disp('Going to 32 bits integer');
                else
                    n = double(n);
                    limit = inf;
                    disp('Going to double');
                end
            end
            
            n(end+1:end+s,1) = ns;
        end
    end
end
if save_data
    fclose(f);
    if nclases > expected_classes_k+1
        fclose(f2);
    end
end

if isempty(n) || all(n==1)
    n = 1;
end




