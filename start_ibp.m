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
function results = start_ibp(train_directory, test_directory, alpha, ensemble_size, use_hypergeometric_prior)
% START_IBP  Loads filenames of train and test voting data, number of 
%   classes of the classification problem and calls RUN_IBP to execute
%   the Statistical Instance-Based Algorithm pruning scheme on the dataset.
%   Returns results from RUN_IBP:
%   Columns 1-2: Average and Std. Dev. error rate of the full ensemble.
%   Columns 3-4: Average and Std. Dev. error rate of the pruned ensemble.
%   Columns 5-6: Average and Std. Dev. disagreement between the full
%   ensemble and the pruned ensemble predictions.
%   Columns 7-8: Average and Std. Dev. number of classifiers queried by the
%   full ensemble (not necessarily the size of the ensemble, since querying
%   can halted earlier depending on the trend of the voting process).
%   Columns 9-10: Average and Std. Dev. number of classifiers queried by
%   the pruned ensemble.
%   Column 11-12: Average and Std. Dev speed-up rate calculated as the
%   number of classifiers queried by the full ensemble divided by the
%   number of classifiers queried by the pruned ensemble.
%   Column 13-14: Average and std. dev number of classifiers accoring to a
%   monte-carlo simulation.
%
% Obtains train and test fold filenames.
train_folds = dir(strcat(train_directory, '*.txt'));
test_folds = dir(strcat(test_directory, '*.txt'));

% Loads in memory votes from train and test folds.
for i = 1:size(train_folds)
    train_folds(i).name = strcat(train_directory, train_folds(i).name);
    test_folds(i).name = strcat(test_directory, test_folds(i).name);
end

% Assume that labels are always 0 to (num_classes - 1).
num_classes = max(max(load(train_folds(1).name))) + 1;
results = run_ibp(train_folds, test_folds, alpha, num_classes, ensemble_size, use_hypergeometric_prior);    

end