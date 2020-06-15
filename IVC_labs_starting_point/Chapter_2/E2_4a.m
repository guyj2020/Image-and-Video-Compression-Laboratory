% Read Image
imageLena = double(imread('lena.tif'));
% create the predictor and obtain the residual image
resImage  = imageLena;

for i = 1:size(imageLena, 3)
    resImage(:, 2:end, i) = imageLena(:, 2:end, i) - imageLena(:, 1:end-1, i);
end
% get the PMF of the residual image
pmfRes    = stats_marg(resImage, -255:255);
% calculate the entropy of the residual image
H_res     = calc_entropy(pmfRes);

fprintf('H_err_OnePixel   = %.2f bit/pixel\n',H_res);

% Put all sub-functions which are called in your script here.
function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = calc_entropy(pmf)
    H = -sum(nonzeros(pmf).*log2(nonzeros(pmf)));
end