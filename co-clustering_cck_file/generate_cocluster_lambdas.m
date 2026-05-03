function [lambda_cont, lambda_branch, stats] = generate_cocluster_lambdas(img_green, respimage, phase_map, vessel_mask)
% Image-adaptive lambda generation with explainable linear mapping.

stats = extract_image_stats(img_green, respimage, phase_map, vessel_mask);

% Normalize noise term to [0,1]-like range for stability.
Nn = stats.N / (stats.N + 10);

% Linear mappings centered around baseline (0.12, 0.02).
lambda_cont = 0.12 + 0.08 * stats.C - 0.05 * Nn + 0.03 * stats.V;
lambda_branch = 0.02 + 0.10 * stats.B + 0.03 * Nn - 0.04 * stats.C;

% Clip to reasonable ranges for numerical stability.
lambda_cont = min(max(lambda_cont, 0.04), 0.20);
lambda_branch = min(max(lambda_branch, 0.005), 0.08);
end
