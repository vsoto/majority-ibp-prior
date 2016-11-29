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
function count = histogram2d(x,y,center)
% HIST2D calculates a 2-dimensional histogram
%    N = HIST2D(X,Y,C) bins the data with centers
%    specified C.
%
%    X and Y are vectors containing the X-axis and
%    Y-axis values of the (X, Y) coordinates.
%    CENTER is a vector of the bin centers used to
%    compute the histogram.
%    COUNT is the histogram matrix of the (X, Y) data
%    COUNT(center(i), center(j)) contains the number
%    of data points (x, y) binned in (center(i), center(j))


if length(x) ~= length(y)
   error(sprintf('x and y must be same size ( %g ~= %g )',length(x), length(y)));
end
   
count = zeros(length(center));

for i = 1:length(center)
   if i == 1
      lbound = -Inf;
   else
      lbound = (center(i-1) + center(i)) / 2;
   end
   if i == length(center)
      ubound = Inf;
   else
      ubound = (center(i) + center(i+1)) / 2;
   end
   count(i, :) = hist(x((y >= lbound) & (y < ubound)), center);
end

