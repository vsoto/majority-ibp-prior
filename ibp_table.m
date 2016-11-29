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
function table = ibp_table(ensemble_size, alpha, num_classes, use_prior, prior)
% IBP_TABLE  Returns the IBP table in the proper format for a
% classification problem of two or three classes with or without prior
% voting knowledge.
%
if (num_classes == 2)
    if (nargin == 5 && use_prior)
        table = ibp_hyperg_2classes(ensemble_size, alpha, prior);
    else
        table0 = ibp_2classes(ensemble_size, alpha);
        table = [table0; table0];    
    end
elseif (num_classes == 3)
    if (nargin == 5 && use_prior)
        table = ibp_hyperg_3classes(ensemble_size, alpha, prior);
    else
        table = ibp_lookuptable(ensemble_size, alpha, 3);
    end
end
end