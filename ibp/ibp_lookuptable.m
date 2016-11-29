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
%IBP_LOOKUPTABLE Computes the lookup table as described in [1] using the
%            methodology developed and described in [2]. The format of
%            the output table is a cell array indexed by the minority classes
%            in descending order. The value of the cell is the minimum number
%            of votes that the majority class has to have in order to have
%            a confidence >= CONFIDENCE_PI that the final class of the ensemble
%            will not change after quering the remaining classifiers.
%   
%
%   ibp_lookuptable(T, CONFIDENCE_PI, NUMBER_OF_CLASSES_L) Computes the lookup table
%        for problems of NUMBER_OF_CLASSES_L classes and ensembles composed
%        of T classifiers with a confidence threshold of CONFIDENCE_PI.
%
%   Example: For an ensemble of 15 classifiers (T=15) and a problem of 3 classes
%            and a desired confidence values of 99% the lookup table is computed as
%
%                 lookup_table = ibp_lookuptable(15, 0.99, 3)
%
%             then if, for example, after quering 9 classifiers, you get the
%             following votes for the 3 classes {2, 7, 0}, you would have
%             to check in the cell corresponding to {2,0} of the lookup table 
%             if it is <= to 7, this is:
%
%                 tt_sorted = [7, 2, 0];
%
%                 if lookup_table{tt_sorted(2)+1}(tt_sorted(3)+1) <= tt_sorted(1)
%                     disp('We can stop querying with 99% confidence');
%                 end
%
%   ibp_lookuptable(T, CONFIDENCE_PI, NUMBER_OF_CLASSES_L, EXPECTED_CLASSES_K) 
%        Computes the lookup table for problems of NUMBER_OF_CLASSES_L classes and 
%        ensembles composed of T classifiers with a confidence threshold of 
%        CONFIDENCE_PI supposing that in test we are not going to find instances that 
%        get votes formore than EXPECTED_CLASSES_K classes.
%
%   Example: For an ensemble of 15 classifiers (T=15) and a problem of 6 classes,
%            a desired confidence values of 99% and EXPECTED_CLASSES_K=3
%            the lookup table is computed as
%
%                 lookup_table = ibp_lookuptable(15, 0.99, 6, 3)
%
%   [1] Statistical Instance-based Ensemble Pruning for Multi-class Problems
%       Gonzalo Martinez-Munoz, Daniel Hernandez-Lobato, Alberto Suarez
%       ICANN-2009 Limassol, Cyprus
%
%   [2] Statistical Instance-based Pruning in Ensembles of Independent Classifiers 
%       Daniel Hernandez-Lobato, Gonzalo Martinez-Munoz, Alberto Suarez
%       IEEE Transactions in Pattern Analysis and Machine Intelligence, 31(2), 364-369, 2009

function ttcc = ibp_lookuptable(T, confidence_pi, number_of_classes_l, expected_classes_k)
%   
% Original Author: Gonzalo Martinez Munoz (gonzalo.martinez@uam.es)
% Contributors: Daniel Hernadez-Lobato, Alberto Suarez 
% Changelog: 
%     Feb-2009: first version v1.0 
% 


if number_of_classes_l<=1
    ttcc=[];
    return;
elseif number_of_classes_l==2
    ttcc=ibp_2classes(T,confidence_pi);
    return;
end

if ~exist('expected_classes_k', 'var')
    expected_classes_k = number_of_classes_l;
elseif expected_classes_k < 3
    disp('expected_classes_k must be at least 3. Not implemented for 2 classes');
    ttcc=[];
	return;
end

if number_of_classes_l > 3
    tic;
end

% Prime factorization for numbers from 1 to T-number_of_classes_l-1
global ff pp;
pp = primes(T+number_of_classes_l-1);
ff = zeros(T+number_of_classes_l-1, length(pp));
for it=1:T+number_of_classes_l-1 
    f = factor(it);
    for i = 1:length(pp)
        ff(it,i) = sum(f==pp(i));
    end
end

% Precomputed prime powers from ^-sp to ^sp
sp = 100;
ppp = zeros(2*sp+1, size(pp,2));
for ip=-sp:sp  
    ppp(ip+sp+1,:) = pp.^ip;
end

% Precomputed prime factors for factorial divided by pochamer symbols (aka rising
% factorials)
fff = zeros(length(pp), T+2,T+1);
fff2 = zeros(T+2,T+1);
for iT=0:T 
    fff(:, T+2, iT+1) = sum(ff(T-iT:-1:1,:), 1) - sum(ff(iT+number_of_classes_l:T+number_of_classes_l-1,:), 1);
    fff2(T+2, iT+1) = prod(pp.^(fff(:, T+2, iT+1)'));
end
for iT=0:T 
    for it=0:iT
        fff(:, iT+1, it+1) = sum(ff(iT-it:-1:1,:), 1) - sum(ff(it+1:iT,:), 1);
        fff2(iT+1, it+1) = prod(pp.^(fff(:, iT+1, it+1)'));
    end
end

ttcc = cell(1,ceil(T/2));

minority_classes = zeros(1, number_of_classes_l-1);
tt = [1 minority_classes];

%Retrieve all winning combinations, valid for first cell of the table, 
%As the process goes on the winning combinations that are no longer
% possible are removed. TT contains the combinations, nTT contains
% the counts of equivalent combinations when expected_classes_k < number_of_classes_l
starrrr = 0;
[TT nTT] = get_winning_combinations([1 minority_classes], T, expected_classes_k);
TT=TT+1;

if length(nTT)==1
    is_vector_of_counts = false;
else
    is_vector_of_counts = true;
end

%This loop computes the expected_classes_k-1 dimensional lookup table
for t2=starrrr:ceil(T/2)-1
    if is_vector_of_counts
        nTT(TT(:, 2)<=t2) = [];
    end
    TT(TT(:, 2)<=t2,:) = [];
    minority_classes(1) = t2;
    if number_of_classes_l > 5
        disp(['Combs: ' num2str(size(TT))]);
        toc;
    end
    ttcc{t2+1} = main_loop(3, TT, nTT);
end

    function table = main_loop(n, combs, ncombs)
        if expected_classes_k == n
            minority_classes(n-1) = 0;
            combs0 = combs;
            ncombs0 = ncombs;

            lim_buc = min(minority_classes(n-2), T-sum(minority_classes)-minority_classes(1)-1);
            table = zeros(1,lim_buc+1);
            if is_vector_of_counts
                base0 = double(ncombs);
            else
                base0 = 1;
            end
            for iii=1:n-2
                if minority_classes(iii)>0
                    base0 = base0 ./ fff2(combs(:,iii+1), minority_classes(iii)+1);
                end
            end
            for ti=0:lim_buc
                minority_classes(n-1) = ti;
                tt = [get_t0() minority_classes];
                indx = combs0(:,n)>ti;
                if is_vector_of_counts
                    ncombs = ncombs0(indx);
                end
                if size(base0,1)>1
                    base = base0(indx);
                else
                    base = 1;
                end
                combs = combs0(indx,:);
                if combs(1, 1) <= tt(1)
                    indx1 = find(combs(:, 1)>tt(1),1);
                    if is_vector_of_counts
                        ncombs(1:indx1-1) = [];
                    end
                    if size(base,1)>1
                        base(1:indx1-1) = [];
                    end
                    combs(1:indx1-1,:) = [];
                end
                if isempty(combs)
                    disp('Going out this way');
                    break;
                end
                trtr = tt + 1;
                while true
                    t = sum(tt);
                    numers = fff2(T+2,t+1) ./ fff2(combs(:,1), trtr(1));
                    numers = numers .* base;
                    if trtr(n)>1
                        numers = numers ./ fff2(combs(:,n), trtr(n));
                    end

                    p = sum(numers);
                    
                    if p + eps >= confidence_pi
                        table(ti+1) = tt(1);
                        if p > 1 + 2*eps
                            disp(['Prob > 1 for: ' num2str([p tt t])]);
                        end
                        break;
                    else
                        tt(1) = tt(1) + 1;
                        trtr(1) = trtr(1) + 1;
                        if combs(1, 1) <= tt(1)
                            indx1 = find(combs(:, 1)>tt(1),1);
                            if is_vector_of_counts
                                ncombs(1:indx1-1) = [];
                            end
                            if size(base,1)>1
                                base(1:indx1-1) = [];
                            end
                            combs(1:indx1-1,:) = [];
                        end
                    end
                end
            end
        else
            minority_classes(n-1:end) = 0;
            lim_buc = min(minority_classes(n-2), T-sum(minority_classes)-minority_classes(1)-1);
            table = cell(1,lim_buc+1);
            for ti=0:lim_buc
                minority_classes(n-1) = ti;
                if is_vector_of_counts
                    ncombs(combs(:, n)<=ti) = [];
                end
                combs(combs(:, n)<=ti,:) = [];
                table(ti+1) = {main_loop(n+1, combs, ncombs)};
            end
        end

    end

    function t0 = get_t0
        t0 = max(minority_classes(1)+1,1);
        if minority_classes(1)~=0
            ttt0 = ttcc{minority_classes(1)};
            for it0=2:expected_classes_k-1-1
                if length(ttt0)>=minority_classes(it0)+1
                    ttt0 = ttt0{minority_classes(it0)+1};
                else
                    return;
                end
            end
            if length(ttt0)>=minority_classes(expected_classes_k-1)+1
                t0 = ttt0(minority_classes(expected_classes_k-1)+1);
            end
        end
    end
end
