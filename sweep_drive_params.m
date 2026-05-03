% Small-scale parameter sweep for structural-prior CFCM clustering.
clear; clc;
addpath(genpath('co-clustering_cck_file'));
addpath(genpath('cosfire'));
addpath(genpath('phasecongruency_file'));

imgIdx = 1; % quick sweep on DRIVE test 01
img0 = imread(['DRIVE\test\images\',num2str(imgIdx,'%02d'),'_test.tif']);
mask = imread(['DRIVE\test\mask\',num2str(imgIdx,'%02d'),'_test_mask.gif']);
man = imread(['DRIVE\test\2nd_manual\',num2str(imgIdx,'%02d'),'_manual2.gif']);
if size(man,3) == 3, man = rgb2gray(man); end

[img_pre,mask] = preProcessing(img0,mask);
[output, ~] = Bcosfire(img0);
output.respimage(mask==0)=0;
respimage=normalize(output.respimage,mask);
[M, ~ , ~ , ~ , ~, ~]=phasecong(img_pre);
M(mask==0)=0; M=normalize(M,mask);

features=[reshape(respimage,1,[]);reshape(M,1,[])]';
features=double(features);
cluster_n =2;

lambda_cont_list = [0.04, 0.08, 0.12];
lambda_branch_list = [0.02, 0.05, 0.08];

k = 0;
results = zeros(numel(lambda_cont_list)*numel(lambda_branch_list), 7);
for lc = lambda_cont_list
    for lb = lambda_branch_list
        k = k + 1;
        params = struct('lambda_cont', lc, 'lambda_branch', lb, 'prior_resp_w', 0.6, 'prior_phase_w', 0.4);
        [U1,U2] = CFCMcck(features, cluster_n, 2 ,respimage,M,params);
        U = sqrt(U1.*U2);

        % adaptive vessel class mapping
        prior = mat2gray(double(respimage)) * 0.6 + mat2gray(double(M)) * 0.4;
        priorVec = prior(:);
        vesselScore = U * priorVec;
        [~, vesselCls] = max(vesselScore);

        if vesselCls == 1
            vesselMask = reshape(U(1,:)>U(2,:), size(respimage));
        else
            vesselMask = reshape(U(2,:)>U(1,:), size(respimage));
        end

        % polarity self-check (same rule as final.m)
        fgScore = mean(prior(vesselMask));
        bgScore = mean(prior(~vesselMask));
        if fgScore < bgScore
            vesselMask = ~vesselMask;
        end

        out_img = uint8(vesselMask) * 255;
        bw2_img = renovesmallarea(out_img,20,4);
        bw2_img(mask==0)=0;

        man_eval = man; man_eval(man_eval==255)=1;
        mask_eval = mask; mask_eval(mask_eval~=0)=1;
        [acc,sn,sp,F1,MCC]=evolution(bw2_img,man_eval,mask_eval);
        results(k,:) = [lc, lb, acc, sn, sp, F1, MCC];
        fprintf('lc=%.3f lb=%.3f | acc=%.5f sn=%.5f sp=%.5f F1=%.5f MCC=%.5f\n', lc, lb, acc, sn, sp, F1, MCC);
    end
end

T = array2table(results, 'VariableNames', {'lambda_cont','lambda_branch','acc','sn','sp','F1','MCC'});
T = sortrows(T, {'MCC','F1','sn'}, {'descend','descend','descend'});
disp('===== Sweep ranking (top first) =====');
disp(T);
writetable(T, 'result_file/Drive/Drive1/sweep_results_drive01.csv');
