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
function table = ibp_hyperg_3classes(TT, alpha, prior)
% IBP_HYPERG_3CLASSES Computes an IBP table for a ternary problem,
% for an ensemble of size TT, confidence alpha and prior knowledge of the
% voting process.
% The resulting table is indexed by the votes received for classes 0, 1 and
% 2, and contains ones or zeros depending if the voting process can be
% halted or not with confidence alpha.
% For example : table(3, 45, 27) will return a 1 if the voting process can
% be halted when 2 votes (2 + 1) have been cast for class 0, and 44
% (44 + 1) votes have been cast for class 1 and 26 votes (26 + 1) have been
% cast for class 2.
%
pp = primes(TT);
ff = zeros(TT, length(pp));
for t=1:TT
    f = factor(t);
    for i = 1:length(pp)
        ff(t,i) = sum(f==pp(i));
    end
end

fff = zeros(length(pp), TT+1,TT+1);
for iT=0:TT
    for it=0:iT
        fff(:, iT+1, it+1) = sum(ff(iT-it+1:iT,:), 1);
    end
end

tic
table = zeros(TT+1);

for t1=0:TT
    for t2=0:TT-t1
        for t3=0:TT-t1-t2
            t = [t1, t2, t3];
            [p, q] = compute_num_and_dem(TT, t, fff, pp', prior);
            table(t1+1, t2+1, t3+1) = (p >= alpha*q);
        end
    end
end
toc

% table = zeros(TT+1);
% for t1=0:TT
%     for t2=0:TT-t1
%         for t3=0:TT-t1-t2
%             t = [t1, t2, t3];
%             q = p_t(TT,t,fff,pp',prior);
%             
%             p=0;
%             [~, index] = sort(t,'descend');
%             for T1=t1:TT-t2-t3
%                 for T2=t2:TT-T1-t3
%                     T3=TT-T1-T2;
%                     T=[T1, T2, T3];
%                     % This if is key: we only add this quantity if the 
%                     % class predicted by T is the same class predicted by 
%                     % t.
%                     if T(index(1)) > T(index(2)) && T(index(1)) > T(index(3))
%                         p = p + p_T_t(T,t,fff,pp',prior);
%                     end
%                 end
%             end
%             table(t1+1,t2+1,t3+1) = p/q;
%         end
%     end
% end
% table(:,:,:) = table(:,:,:) >= alpha;
% toc

function [num, dem] = compute_num_and_dem(TT, t, fff, pp, prior)
dem = 0.0;
num = 0.0;
[~, index] = sort(t,'descend');
for T1 = t(1):(TT-t(2)-t(3))
    for T2 = t(2):(TT-T1-t(3))
        T3 = TT-T1-T2;
        T = [T1, T2, T3];
        q = p_T_t(T, t, fff, pp, prior);
        dem = dem + q;
        if T(index(1)) > T(index(2)) && T(index(1)) > T(index(3))
            num = num + q;
        end
    end
end

function q = p_t(TT, t, fff, pp, prior)
q=0;
for T1=t(1):(TT-t(2)-t(3))
    for T2=t(2):(TT-T1-t(3))
        T3=TT-T1-T2;
        q = q + p_T_t([T1, T2, T3], t, fff, pp, prior);
    end
end


function p = p_T_t(T, t, fff, pp, prior)
numers = fff(:,T(1)+1, t(1)+1)+fff(:,T(2)+1, t(2)+1)+fff(:,T(3)+1, t(3)+1);
p = (prior(T(1)+1,T(2)+1)*prod(pp.^numers));

