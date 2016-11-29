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
function prior = get_hypergeometric_prior(list_train_folds, ensemble_size, num_classes)

if (num_classes == 2)
    prior = get_hyperprior_2classes(list_train_folds, ensemble_size);
elseif(num_classes == 3)
    prior = get_hyperprior_3classes(list_train_folds, ensemble_size);
end

function T = get_hyperprior_2classes(train_folds, ensemble_size)
% GET_HYPERPRIOR_2CLASSES computes the hypergeometric prior for each
% training fold. Output matrix T is size num_folds x (ensemble_size + 1).
%
num_folds = size(train_folds, 1);
T = zeros(num_folds, ensemble_size + 1);
resolution = ensemble_size + 1;

for k = 1:num_folds    
    train = load(train_folds(k).name);    
    % Reminder: a -1 vote in a fold from training data indicates that this
    % example was present in the bootstrap sample for this specific tree.
    % Thus, it cannot be used in an out-of-bag prior estimation.
    top = sum(train(:, 1:ensemble_size) ~= -1, 2);
    t0 = round(ensemble_size * (sum(train(:, 1:ensemble_size) == 0, 2)./top));
    % The histogram prior is smoothed.
    hh0 = smooth(hist(t0, resolution));
    T(k, :) = hh0/(sum(hh0));
end


function T = get_hyperprior_3classes(train_folds, ensemble_size)
% GET_HYPERPRIOR_3CLASSES computes the hypergeometric prior for each
% training fold. Output matrix T is size  (ensemble_size + 1) x (ensemble_size + 1) x num_folds.
%
num_folds = size(train_folds, 1);
T = zeros(ensemble_size + 1, ensemble_size + 1, num_folds);

for k = 1:num_folds    
    train = load(train_folds(k).name);    
    % Reminder: a -1 vote in a fold from training data indicates that this
    % example was present in the bootstrap sample for this specific tree.
    % Thus, it cannot be used in an out-of-bag prior estimation.
    top = sum(train(:, 1:ensemble_size) ~= -1, 2);
    r = rand(length(top), 1)*0.01-0.005;
    t0 = round(ensemble_size*((sum(train(:, 1:ensemble_size) == 0, 2) + r)./top));
    t1 = round(ensemble_size*((sum(train(:, 1:ensemble_size) == 1, 2) - r)./top));
    
    hh0 = histogram2d(t1, t0, 0:ensemble_size);    
    
    % The histogram prior is smoothed.
    hh0(~rot90(tril(ones(ensemble_size + 1)), -1)) = NaN;
    hh0 = smooth_matrix(hh0, 2); % 1 is a square of 3x3
    hh0(isnan(hh0)) = 0;
    T(:, :, k)=hh0/(sum(sum(hh0)));        
end

