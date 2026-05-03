function [U1,U2] = CFCMcck(data, cluster_n, num ,respimage,M, params)

if nargin < 6 || isempty(params)
    params = struct();
end
if ~isfield(params,'lambda_cont'); params.lambda_cont = 0.08; end
if ~isfield(params,'lambda_branch'); params.lambda_branch = 0.05; end
if ~isfield(params,'prior_resp_w'); params.prior_resp_w = 0.6; end
if ~isfield(params,'prior_phase_w'); params.prior_phase_w = 0.4; end

C = cluster_n;
P = num;
Y = double(data);
[N,~] = size(Y);

X = cell(1,P); L = cell(1,P); U = cell(1,P+1); V = cell(1,P+1);
for i = 1:P
    X{i} = Y(:,i); L{i} = size(X{i},2);
end
for i = 1:P
    [V{i},U{i},~] = fcm(X{i},C);
end
for a = 1:P-1
    for i = 1:C
        D = zeros(1,C);
        for j = 1:C
            D(j) = sum((U{a}(j,:) - U{a+1}(i,:)).^2);
        end
        [~,index] = min(D);
        U{P+1}(index,:) = U{a+1}(i,:); V{P+1}(index,:) = V{a+1}(i,:);
    end
    U{a+1} = U{P+1}; V{a+1} = V{P+1};
end

priorMap = mat2gray(double(respimage)) * params.prior_resp_w + mat2gray(double(M)) * params.prior_phase_w;
[r,c] = size(priorMap);
priorMap = imgaussfilt(priorMap, 0.8);
priorVec = priorMap(:)';

skel = bwmorph(priorMap > graythresh(priorMap), 'skel', Inf);
branch = bwmorph(skel, 'branchpoints');
branchW = imgaussfilt(double(branch), 1.0); branchW = branchW ./ max(max(branchW), eps); branchW = branchW(:)';
structWeight = 0.15 + 0.85 * priorVec;

lambda_cont = params.lambda_cont; lambda_branch = params.lambda_branch;

SSIGMA = 0;
for iteration = 1:100
    [neipos,wid] = fneighbor(respimage,15); G1 = myfcmstep(neipos,wid,U{1},2,2);
    [neipos,wid] = fneighbor(M,7); G2 = myfcmstep(neipos,wid,U{2},2,2);

    for ii = 1:P
        if ii == 1, aa = G2; else, aa = G1; end
        otherU = zeros(C,N);
        for jj = 1:P
            if jj ~= ii, otherU = otherU + U{jj}; end
        end

        temp2Mat = (P - 1) * aa; temp1Mat = aa .* otherU;
        Xii = X{ii}'; Vii = V{ii}; dist2 = zeros(C,N);
        for ci = 1:C
            delta = Xii - Vii(ci,:)'; dist2(ci,:) = sum(delta.^2,1);
        end
        dist2 = max(dist2, eps); temp3Mat = dist2 .* sum(1 ./ dist2, 1);
        temp4Base = sum(otherU,1); temp4Mat = (aa ./ (1 + temp2Mat)) .* temp4Base;
        Uii = temp1Mat ./ (1 + temp2Mat) + (1 - temp4Mat) ./ temp3Mat;

        Umap = reshape(Uii', r, c, C); priorSmooth = zeros(C, N);
        for ci = 1:C
            localAvg = imfilter(Umap(:,:,ci), fspecial('gaussian', [5 5], 1.0), 'replicate');
            priorSmooth(ci,:) = localAvg(:)';
        end
        Uii = Uii + lambda_cont * (ones(C,1) * structWeight) .* (priorSmooth - Uii);

        vesselScore = Uii * priorVec'; [~,vesselCls] = max(vesselScore);
        branchBoost = zeros(C,N); branchBoost(vesselCls,:) = branchW;
        Uii = Uii + lambda_branch * branchBoost;

        Uii = max(Uii, eps); Uii = Uii ./ max(sum(Uii,1), eps); U{ii} = Uii;

        penalty = zeros(C,N);
        for jj = 1:P
            if jj ~= ii, penalty = penalty + aa .* (U{ii} - U{jj}).^2; end
        end
        WV = U{ii}.^2 + penalty; denom = max(sum(WV,2), eps);
        for l = 1:L{ii}
            xrow = X{ii}(:,l)'; V{ii}(:,l) = sum(WV .* xrow,2) ./ denom;
        end
    end

    SIGMA(iteration) = sum(sum(abs(U{1} - U{2})))/(N*C);
    if abs(SSIGMA - SIGMA(iteration)) < 1e-5, break; else, SSIGMA = SIGMA(iteration); end
end

U1 = U{1}; U2 = U{2};
end
