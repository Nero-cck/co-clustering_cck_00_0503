% Test script: verify fixed baseline and image-adaptive lambda generation.
addpath(genpath('co-clustering_cck_file'));

img0 = imread('DRIVE/test/images/01_test.tif');
mask = imread('DRIVE/test/mask/01_test_mask.gif');
[img_pre, mask] = preProcessing(img0, mask);

[output, ~] = Bcosfire(img0);
output.respimage(mask==0)=0;
respimage = normalize(output.respimage, mask);

[M, ~ , ~ , ~ , ~, ~] = phasecong(img_pre);
M(mask==0)=0;
M = normalize(M, mask);

% Fixed baseline from sweep
a_fixed = 0.12;
b_fixed = 0.02;

% Adaptive generation
[a_auto, b_auto, stats] = generate_cocluster_lambdas(img_pre, respimage, M, mask);

fprintf('fixed lambda | lc=%.4f lb=%.4f\n', a_fixed, b_fixed);
fprintf('auto  lambda | lc=%.4f lb=%.4f\n', a_auto, b_auto);
fprintf('stats | C=%.4f N=%.4f V=%.4f B=%.4f\n', stats.C, stats.N, stats.V, stats.B);

assert(a_auto >= 0.04 && a_auto <= 0.20, 'lambda_cont out of range');
assert(b_auto >= 0.005 && b_auto <= 0.08, 'lambda_branch out of range');

% Explainability-oriented monotonic checks for linear mapping design.
base = struct('C', 0.12, 'N', 6.0, 'V', 0.30, 'B', 0.10);
[lc0, lb0] = local_map(base);

p = base; p.B = 0.20; [~, lb_highB] = local_map(p);
assert(lb_highB > lb0, 'lambda_branch should increase with branch complexity B');

p = base; p.C = 0.20; [lc_highC, lb_highC] = local_map(p);
assert(lc_highC > lc0, 'lambda_cont should increase with contrast C');
assert(lb_highC < lb0, 'lambda_branch should decrease with contrast C');

disp('test_auto_lambda passed');

function [lambda_cont, lambda_branch] = local_map(stats)
Nn = stats.N / (stats.N + 10);
lambda_cont = 0.12 + 0.08 * stats.C - 0.05 * Nn + 0.03 * stats.V;
lambda_branch = 0.02 + 0.10 * stats.B + 0.03 * Nn - 0.04 * stats.C;
lambda_cont = min(max(lambda_cont, 0.04), 0.20);
lambda_branch = min(max(lambda_branch, 0.005), 0.08);
end
