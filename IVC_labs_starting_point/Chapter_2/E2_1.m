imageLena     = double(imread('lena.tif'));
imageSail     = double(imread('sail.tif'));
imageSmandril = double(imread('smandril.tif'));

range = 0:255;

pmfLena       = stats_marg(imageLena, range);
HLena         = calc_entropy(pmfLena);

pmfSail       = stats_marg(imageSail, range);
HSail         = calc_entropy(pmfSail);

pmfSmandril   = stats_marg(imageSmandril, range);
HSmandril     = calc_entropy(pmfSmandril);

fprintf('--------------Using individual code table--------------\n');
fprintf('lena.tif      H = %.2f bit/pixel\n', HLena); % 7.7502
fprintf('sail.tif      H = %.2f bit/pixel\n', HSail); % 7.3230
fprintf('smandril.tif  H = %.2f bit/pixel\n', HSmandril); % 7.7624
% 
% Put all sub-functions which are called in your script here.
function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = calc_entropy(pmf)
    H = -sum(nonzeros(pmf).*log2(nonzeros(pmf)));
end