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
function smoothed = smooth_matrix(matrix, np)
% Smooths 2-dim matrix. Uses a mean filter over a
% rectangle of size (2*np+1)-by-(2*np+1). NaN
% elements are ignored in the averaging.
% 
% matrix: two-dimensional array data.
% np: radius used to smooth points.



% L and R are the left and right matrices used
% to compute running sums. 
[num_rows, num_cols] = size(matrix);
L = spdiags(ones(num_rows, 2*np+1), (-np:np), num_rows, num_rows);
R = spdiags(ones(num_cols, 2*np+1), (-np:np), num_cols, num_cols);

A = isnan(matrix);
matrix(A) = 0;

normalize = L*(~A)*R;
normalize(A) = NaN;

smoothed = L*matrix*R;
smoothed = smoothed./normalize;

