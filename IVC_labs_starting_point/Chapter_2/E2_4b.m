% Read Image
% imageLena = double(imread('lena.tif'));
imageLena = double(imread('lena_small.tif'));
% create the predictor and obtain the residual image
yuvLena = ictRGB2YCbCr(imageLena);

reconImage = zeros(size(yuvLena));
resImage   = zeros(size(yuvLena));

for yuv_dim = 1:3
    reconImage(1, :, yuv_dim) = yuvLena(1, :, yuv_dim);
    resImage(1, :, yuv_dim) = yuvLena(1, :, yuv_dim);
    reconImage(:, 1, yuv_dim) = yuvLena(:, 1, yuv_dim);
    resImage(:, 1, yuv_dim) = yuvLena(:, 1, yuv_dim);
end

alpha_Y = [-1/2; 7/8; 5/8; 0];
alpha_CbCr = [-1/4; 3/8; 7/8; 0];

for dim = 1:size(yuvLena, 3)
    if isequal(dim, 1)
        alpha = alpha_Y;
    else
        alpha = alpha_CbCr;
    end
    for x = 2:size(yuvLena, 1)
        for y = 2:size(yuvLena, 2)
            get_values = reshape(reconImage(x-1:x, y-1:y, dim), [], 1);
            pred = sum(alpha .* get_values);
            resImage(x, y, dim) = round(yuvLena(x, y, dim) - pred);
            reconImage(x, y, dim) = pred + resImage(x, y, dim);
        end
    end
end
% % get the PMF of the residual image
pmfRes    = stats_marg(resImage, -255:255);
% calculate the entropy of the residual image
H_res     = calc_entropy(pmfRes); 

fprintf('H_err_OnePixel   = %.2f bit/pixel\n',H_res);

[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(pmfRes);
fprintf('Number of codewords   = %.2f\n', length(Codelengths));
fprintf('Max. codewordlength   = %.2f\n', max(Codelengths));
fprintf('Min. codewordlength   = %.2f\n', min(Codelengths));

plot(Codelengths)


% Put all sub-functions which are called in your script here.
function yuv = ictRGB2YCbCr(rgb)
% Input         : rgb (Original RGB Image)
% Output        : yuv (YCbCr image after transformation)
% YOUR CODE HERE
r = rgb(:,:,1);
g = rgb(:,:,2);
b = rgb(:,:,3);
yuv(:,:,1) = 0.299 * r + 0.587*g + 0.114*b;
yuv(:,:,2) = -0.169 * r -0.331* g + 0.5*b;
yuv(:,:,3) = 0.5*r - 0.419*g - 0.081*b;
end

function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = calc_entropy(pmf)
    H = -sum(nonzeros(pmf).*log2(nonzeros(pmf)));
end