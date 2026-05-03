function stats = extract_image_stats(img_green, respimage, phase_map, vessel_mask)
% Extract interpretable image statistics for adaptive lambda generation.

ig = double(img_green);
if nargin < 4 || isempty(vessel_mask)
    vessel_mask = true(size(ig));
else
    vessel_mask = vessel_mask ~= 0;
end

pix = ig(vessel_mask);
if isempty(pix)
    pix = ig(:);
end

% C: local/global contrast proxy (std normalized by dynamic range)
dyn_range = max(pix) - min(pix);
if dyn_range < eps
    C = 0;
else
    C = std(pix) / dyn_range;
end

% N: noise proxy via high-frequency residual energy
h = fspecial('average', [5 5]);
low = imfilter(ig, h, 'replicate');
hf = ig - low;
N = mean(abs(hf(vessel_mask)));

% V: weak vessel candidate density from responses
resp = double(respimage);
ph = double(phase_map);
score = 0.5 * mat2gray(resp) + 0.5 * mat2gray(ph);
t = prctile(score(vessel_mask), 65);
weak = score >= t;
V = nnz(weak & vessel_mask) / max(nnz(vessel_mask), 1);

% B: branch complexity from skeleton branch points ratio
bw = weak & vessel_mask;
sk = bwmorph(bw, 'skel', Inf);
branch = bwmorph(sk, 'branchpoints');
B = nnz(branch) / max(nnz(sk), 1);

stats = struct('C', C, 'N', N, 'V', V, 'B', B);
end
