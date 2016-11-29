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
%COUNT Count the number of combinations
% 

function c = count(N, nclases, max_value, TT)
% Original Author: Gonzalo Martinez Munoz (gonzalo.martinez@uam.es)
% Contributors: Daniel Hernandez-Lobato, Alberto Suarez 
% Changelog: 
%     Feb-2009: first version v1.0 
% 

global ff pp;

if nargin > 3 && length(pp) < TT+nclases-1
    pp = primes(TT+nclases-1);
    ff = zeros(TT+nclases-1, length(pp));
    for it=1:TT+nclases-1 
        f = factor(it);
        for i = 1:length(pp)
            ff(it,i) = sum(f==pp(i));
        end
    end
end

if ceil(N/nclases) > max_value
    c = 0;
    return;
end

if max_value*nclases-N <= N
   N =max_value*nclases-N;
end

if nclases == 1
    c = 1;
    if c > max_value
        error('no puede ser');
    end
elseif nclases == 2
    if max_value >= N
        c = N+1;
    else
        c = 1 - N + max_value + max_value;
    end
elseif N <= max_value
   c = sum(ff(1:N+nclases-1, :),1) - sum(ff(2:N, :),1) - sum(ff(2:nclases-1, :),1);
   c = prod(pp.^c);
else
    c = 0;
    for i=floor(N/(max_value+1)):-1:0
        dd = sum(ff(2:nclases,:),1) - sum(ff(2:i,:),1) - sum(ff(2:nclases-i,:),1);
        v = N - i*(max_value+1)+nclases-1;
        d = N - i*(max_value+1);
        dd = dd + sum(ff(2:v,:),1) - sum(ff(2:d,:),1) - sum(ff(2:v-d,:),1);
        %Slower!!! %dd = nchoosek(nclases, i)*nchoosek(v+nclases-1, v);  
        if mod(i,2)==0
            c = c + prod(pp.^dd);
        else
            c = c - prod(pp.^dd);
        end
    end
    if c < 0
        c = -c;
    end
end
