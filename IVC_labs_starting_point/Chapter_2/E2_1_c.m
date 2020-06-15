imageLena     = double(imread('lena.tif'));
imageSail     = double(imread('sail.tif'));
imageSmandril = double(imread('smandril.tif'));
test = double(imread('test.jpeg'));

range = 0:255;

pmfLena       = stats_marg(imageLena, range);
pmfSail       = stats_marg(imageSail, range);
pmfSmandril   = stats_marg(imageSmandril, range);
pmfTest   = stats_marg(test, range);


mergedPMF     = pmfLena + pmfSail + pmfSmandril;
mergedPMF     = mergedPMF/sum(mergedPMF);

minCodeLengthLena     = min_code_length(mergedPMF, pmfLena);
minCodeLengthSail     = min_code_length(mergedPMF, pmfSail);
minCodeLengthSmandril = min_code_length(mergedPMF, pmfSmandril);
minCodeLengthSmandril = min_code_length(mergedPMF, pmfTest);

fprintf('--------------Using merged code table--------------\n');
fprintf('lena.tif      H = %.2f bit/pixel\n', minCodeLengthLena); % 7.81 bit/pixel passt
fprintf('sail.tif      H = %.2f bit/pixel\n', minCodeLengthSail);
fprintf('smandril.tif  H = %.2f bit/pixel\n', minCodeLengthSmandril);

% Put all sub-functions which are called in your script here.
function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = min_code_length(pmf_table, pmf_image)
%     nnz_pmf = nonzeros
    H = -sum(pmf_image.*log2(pmf_table));
end
