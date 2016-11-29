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
%ibp_2classes See ibp_lookuptable fuction for usage 
% 
function table = ibp_2classes(TT, alpha)
%
% Original Author: Gonzalo Martinez Munoz (gonzalo.martinez@uam.es)
% Contributors: Daniel Hernandez-Lobato, Alberto Suarez 
% Changelog: 
%     Feb-2009: first version v1.0  
% 

pp = primes(TT+1);
ff = zeros(TT+1, length(pp));

for t=1:TT+1
    f = factor(t);
    for i = 1:length(pp)
        ff(t,i) = sum(f==pp(i));
    end
end

fff = zeros(length(pp), TT+2,TT+1);
for iT=0:TT
    fff(:, TT+2, iT+1) = sum(ff(TT-iT:-1:1,:), 1) - sum(ff(iT+2:TT+1,:), 1);
    for it=0:iT
        fff(:, iT+1, it+1) = sum(ff(iT-it:-1:1,:), 1) - sum(ff(it+1:iT,:), 1);
    end
end

table = -ones(1, ceil(TT/2));

for tt=5:ceil(TT/2)-1
    for t1=table(tt-1)+1:tt-1
        t = [tt t1];
        p = 0;
        for TT1=ceil(TT/2):TT-tt
            T = [TT-TT1 TT1];
            p0 = p_T_t_v2(T,t, fff, pp');
            p = p + p0;
        end
        if p >= 1 - alpha
            table(tt) = t1 - 1;
            break;
        end
    end
end

% Indexing by minority class
table(ceil(TT/2)) = TT - ceil(TT/2);
table2 = zeros(size(table));
for i=1:length(table)
    table2(i)=find(table>=i-1,1);
end
table=table2;



function p = p_T_t_v2(T, t, ff, pp)

if length(T) ~= length(t)
    error('Not the same length');
end

TT=sum(T);
tt=sum(t);
l=length(t);

numers = ff(:,TT+2,tt+1);

for i=1:l
    numers = numers - ff(:,T(i)+1, t(i)+1);
end

p = prod(pp.^numers);

