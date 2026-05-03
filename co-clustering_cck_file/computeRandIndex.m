function RandIndex=computeRandIndex(U0, U)
% 根据U0和U，计算RandIndex的值
% U0和U均为cxn矩阵
% Last modified: 2009.07.06    19:22:00

[cluster_n0, data_n0] = size(U0);
[cluster_n, data_n] = size(U);

if (data_n0~=data_n)
    fprintf('RandIndex: 两矩阵大小不同\n');
    FMeasure = 0;
    return;
end

if cluster_n < cluster_n0
    zeroM = zeros(cluster_n0-cluster_n, data_n);
    U = [U; zeroM];
else
    if cluster_n > cluster_n0
        zeroM = zeros(cluster_n-cluster_n0, data_n);
        U0 = [U0; zeroM];
    end
end

mask = triu(ones(data_n0, data_n0))-eye(data_n0);
% 计算M0
M0 = (U0'*U0).*mask;
% 计算M
M = (U'*U).*mask;
% 计算agreement
agreement = sum(sum((M0==M)))-data_n0*(data_n0+1)/2;
% 计算RandIndex
RandIndex=2*agreement/(data_n0*(data_n0-1));