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
function results = run_ibp(list_train_folds, list_test_folds, alpha, num_classes, ensemble_size, use_hypergeometric_prior)
% RUN_IBP  Executes Statistical Instance-Based Algorithm pruning scheme on 
%   each fold of the dataset and returns average and std. dev of the
%   following quantities:
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
if (use_hypergeometric_prior)
    % If incorporating prior knowledge, the priors are computed now and the
    % SIBA pruning table is updated for each fold prior.
    prior = get_hypergeometric_prior(list_train_folds, ensemble_size, num_classes);
else
    % If not, the SIBA pruning table is static and needs to be loaded
    % just once.
    table = ibp_table(ensemble_size, alpha, num_classes);
end

results_per_fold = zeros(size(list_test_folds, 1), 7);
% Run pruning scheme on each test fold.
for fold_idx = 1:(size(list_test_folds, 1))
    % Pruning table changes for each fold because the prior changes.
    if (use_hypergeometric_prior)
        if (num_classes == 2)
            table = ibp_table(ensemble_size, alpha, num_classes, use_hypergeometric_prior, prior(fold_idx, :));
        elseif (num_classes == 3)
            table = ibp_table(ensemble_size, alpha, num_classes, use_hypergeometric_prior, prior(:, :, fold_idx));
        end
    end
    
    test_votes = int8(load(list_test_folds(fold_idx).name));
    number_examples = size(test_votes, 1);
    results_per_example = zeros(number_examples, 5);
    
    % For each test example
    for example_idx = 1:number_examples
        class_votes = zeros(num_classes, 1);
        gold_class = test_votes(example_idx, end);
        results_per_example(example_idx, 4) = gold_class;
        
        classifier_idx = 1;
        % Query classifiers sequentially.
        full_conf_flag = false;
        ibp_flag = false;
        while (~full_conf_flag || ~ibp_flag)
            predicted_class = test_votes(example_idx, classifier_idx);
            class_votes(predicted_class + 1) = class_votes(predicted_class + 1) + 1;
   
            [sorted_votes, sorted_classes] = sort(class_votes, 'descend');
            majority_class = sorted_classes(1) - 1;
            
            % Case: statistical pruning
            if((~ibp_flag) && ((classifier_idx == ensemble_size) || ibp_confidence_pruning(table, class_votes, use_hypergeometric_prior)))
                ibp_flag = true;
                results_per_example(example_idx, 1) = classifier_idx;
                results_per_example(example_idx, 2) = majority_class;
            end
            % Case: 100% confidence pruning
            if ((~full_conf_flag) && ((classifier_idx == ensemble_size) || full_confidence_pruning(sorted_votes, num_classes, ensemble_size, classifier_idx)))
                full_conf_flag = true;
                results_per_example(example_idx, 5) = classifier_idx;
                results_per_example(example_idx, 3) = majority_class;
            end
            classifier_idx = classifier_idx + 1;
        end
    end
    if (use_hypergeometric_prior)
        if (num_classes == 2)
            results_per_fold(fold_idx, :) = compute_stats(results_per_example, num_classes, table, prior(fold_idx, :), use_hypergeometric_prior);
        elseif (num_classes == 3)
            results_per_fold(fold_idx, :) = compute_stats(results_per_example, num_classes, table, prior(:, :, fold_idx), use_hypergeometric_prior);
        end
    else
        results_per_fold(fold_idx, :) = compute_stats(results_per_example);
    end
end
%Compute average and std. dev statistics
results(1, 1:2:13) = mean(results_per_fold(:, 1:7));
results(1, 2:2:14) = std(results_per_fold(:, 1:7));

end

function flag = full_confidence_pruning(sorted_votes, num_classes, ensemble_size, step)
if (num_classes == 2)
    % If the majority class has already received votes from more than half 
    % of the ensemble, the querying process can be halted.
    flag = sorted_votes(1) > ensemble_size/2;
elseif (num_classes == 3)
    % If the difference between the two most voted classes is larger
    % than the number of votes still to be cast, the querying process
    % can be halted.
    flag = (sorted_votes(1) - sorted_votes(2)) > (ensemble_size - step);
end
end
