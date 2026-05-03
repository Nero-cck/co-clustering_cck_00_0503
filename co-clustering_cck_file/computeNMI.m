function NMI = computeNMI(U0, U)
% 计算NMI，U0为参考划分矩阵
% U为聚类结果
% Ref: S. Zhong and J. Ghosh, A Comparative Study of Generative Models for
% Document Clustering
% last modified: 2009.11.25    10:51:00

zero_cluster = find(sum(U')==0);
U(zero_cluster,:) = [];

class_n = size(U0, 1);
[cluster_n data_n] = size(U);
if cluster_n <= 1 || class_n == 1
    NMI = 0;
    fprintf('computeNMI：类别数为%d\n', cluster_n);
    return;
end

% nhl: the number samples in class h as well as in cluster l.
for h = 1: class_n
    M = (ones(cluster_n,1)*U0(h,:)).*U;
    nhl(h,:) = sum(M>0, 2);
end

% nh: the number of data samples in class h
nh = sum(U0, 2);

% nl: the number of data samples in cluster l
nl = sum(U, 2);

M1 = data_n*nhl;
% M2 = (ones(cluster_n,1)*nl').*(nh*ones(1,class_n));
M2 = nh*nl';
M3 = M1./M2;
for h = 1: class_n
    for l = 1: cluster_n
        if M3(h,l)==0
            M3(h,l)=1;
        end
    end
end
sum_h = sum(nh.*log(nh/data_n));
sum_l = sum(nl.*log(nl/data_n));
NMI = sum(sum(nhl.*log(M3)))/sqrt(sum_h*sum_l);