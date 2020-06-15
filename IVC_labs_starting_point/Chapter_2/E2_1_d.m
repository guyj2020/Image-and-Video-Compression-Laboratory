% imageLena     = double(imread('lena.tif'));
imageSail     = double(imread('sail.tif'));
imageSmandril = double(imread('smandril.tif'));
mageLena     = double(imread('lena.png'));
test = double(imread('test.jpg'));
noise = double(imread('noise.jpg'));
% noise = noise2(1:512, 1:512, :);
% test = test2(1:512, 1:512, :);

range = 0:255;

pmfLena       = stats_marg(imageLena, range);
HLena         = calc_entropy(pmfLena);

pmfTest       = stats_marg(test, range);
HTest         = calc_entropy(pmfTest);

pmfNoise      = stats_marg(noise, range);
HNoise         = calc_entropy(pmfNoise);



pmfSail       = stats_marg(imageSail, range);
HSail         = calc_entropy(pmfSail);

pmfSmandril   = stats_marg(imageSmandril, range);
HSmandril     = calc_entropy(pmfSmandril);

mergedPMF     = pmfLena + pmfSail + pmfSmandril;
mergedPMF     = mergedPMF/sum(mergedPMF);

minCodeLengthLena     = min_code_length(mergedPMF, pmfLena);
minCodeLengthSail     = min_code_length(mergedPMF, pmfSail);
minCodeLengthSmandril = min_code_length(mergedPMF, pmfSmandril);

deltaH_lena = HLena - minCodeLengthLena;
deltaH_sail = HSail - minCodeLengthSail;
deltaH_smandril = HSmandril - minCodeLengthSmandril;

fprintf('--------------Entropy Comparison --------------\n');
fprintf('lena.tif      %cH = %.2f bit/pixel\n', 916, deltaH_lena); % 7.81 bit/pixel passt
fprintf('sail.tif      %cH = %.2f bit/pixel\n', 916, deltaH_sail);
fprintf('smandril.tif  %cH = %.2f bit/pixel\n', 916, deltaH_smandril);

fprintf('lena  H = %.2f bit/pixel\n', HLena);
fprintf('ramp  H = %.2f bit/pixel\n', HTest);
fprintf('randomdot  H = %.2f bit/pixel\n', HNoise);

% Put all sub-functions which are called in your script here.
function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = calc_entropy(pmf)
    H = -sum(nonzeros(pmf).*log2(nonzeros(pmf)));
end

function H = min_code_length(pmf_table, pmf_image)
%     nnz_pmf = nonzeros
    H = -sum(pmf_image.*log2(pmf_table));
end