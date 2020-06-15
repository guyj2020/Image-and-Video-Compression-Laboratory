image     = double(imread('lena.tif'));

range = 0:255;
pmfLena       = stats_marg(imageLena, range);

mergedPMF     = pmfLena + pmfSail + pmfSmandril;

minCodeLengthLena     = min_code_length(mergedPMF, pmfLena);

fprintf('--------------Using merged code table--------------\n');
fprintf('lena.tif      H = %.2f bit/pixel\n', minCodeLengthLena); % 7.81 bit/pixel passt

% Put all sub-functions which are called in your script here.
function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = min_code_length(pmf_table, pmf_image)
%     nnz_pmf = nonzeros
    H = -sum(pmf_image.*log2(pmf_table));
end
