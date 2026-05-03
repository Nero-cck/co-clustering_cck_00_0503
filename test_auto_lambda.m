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

disp('test_auto_lambda passed');
