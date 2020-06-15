imageLena       = double(imread('lena.tif'));
imageLena_small = double(imread('lena_small.tif'));

[resImage, ~, ~, ~] = predictiveCod(imageLena);

Y = resImage(:, :, 1);
Cb = resImage(:, :, 2);
Cr = resImage(:, :, 3);

Cb_pad = padarray(Cb, [4, 4], 'both', 'symmetric');
Cr_pad = padarray(Cr, [4, 4], 'both', 'symmetric') ;

tmp = resample(Cb_pad, 1, 2, 3);
tmp = resample(tmp', 1, 2, 3);
Cb_sub = tmp';

tmp2 = resample(Cr_pad, 1, 2, 3);
tmp2 = resample(tmp2', 1, 2, 3);
Cr_sub = tmp2';

Cb_crop = Cb_sub(3:end-2, 3:end-2);
Cr_crop = Cr_sub(3:end-2, 3:end-2);
subImg = zeros(size(resImage));
subImg(:, :, 1) = Y;
subImg(1:size(Cb_crop, 1), 1:size(Cb_crop, 2), 2) = Cb_crop;
subImg(1:size(Cr_crop, 1), 1:size(Cr_crop, 2), 3) = Cr_crop;

%% Codebook construction
[~, pmfResLenaSmall, ~, ~] = predictiveCod(imageLena_small);
[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(pmfResLenaSmall);

%% Encoding
bytestream = enc_huffman_new(round(subImg(:))+255+1, BinCode, Codelengths);

%% Decoding
rec_image_dec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(subImg(:)))), size(subImg))) - 1 - 255;
I_rec_yuv(:,:, 1) = rec_image_dec(:, :, 1);
dec_Cb = rec_image_dec(1:size(Cb_crop, 1), 1:size(Cb_crop, 2), 2);
dec_Cr = rec_image_dec(1:size(Cr_crop, 1), 1:size(Cr_crop, 2), 3);

%%
Cb_warp = padarray(dec_Cb, [2, 2], 'both', 'symmetric');
Cr_warp = padarray(dec_Cr, [2, 2], 'both', 'symmetric') ;

tmp3 = resample(Cb_warp, 2, 1, 3);
tmp3 = resample(tmp3', 2, 1, 3);
Cb_up = tmp3';

tmp4 = resample(Cr_warp, 2, 1, 3);
tmp4 = resample(tmp4', 2, 1, 3);
Cr_up = tmp4';

Cb_rec = Cb_up(5:end-4, 5:end-4);
Cr_rec = Cr_up(5:end-4, 5:end-4);

I_rec_yuv(:,:, 2) = Cb_rec;
I_rec_yuv(:,:, 3) = Cr_rec;

%% Reconstrunction
decReconImage = decPredictiveCoding(I_rec_yuv);
rec_image = ictYCbCr2RGB(decReconImage);

%% evaluation and show results
figure
subplot(121)
imshow(uint8(imageLena)), title('Original Image')
subplot(122)

PSNR = calcPSNR(imageLena, rec_image);
imshow(uint8(rec_image)), title(sprintf('Reconstructed Image, PSNR = %.2f dB', PSNR))

BPP = numel(bytestream) * 8 / (numel(imageLena)/3);
CompressionRatio = 24/BPP;

fprintf('Bit Rate         = %.2f bit/pixel\n', BPP);
fprintf('CompressionRatio = %.2f\n', CompressionRatio);
fprintf('PSNR             = %.2f dB\n', PSNR);

%% Predictive Coding

% Put all sub-functions which are called in your script here.
function [resImage, pmfRes, H_res, reconImage] = predictiveCod(imageLenaSmall)
    yuvLena = ictRGB2YCbCr(imageLenaSmall);

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
end


function decReconImage = decPredictiveCoding(resImage)
    decReconImage   = zeros(size(resImage));
    for resImage_dim = 1:3
        decReconImage(1, :, resImage_dim) = resImage(1, :, resImage_dim);
        decReconImage(:, 1, resImage_dim) = resImage(:, 1, resImage_dim);
    end

    alpha_Y = [-1/2; 7/8; 5/8; 0];
    alpha_CbCr = [-1/4; 3/8; 7/8; 0];

    for dim = 1:size(resImage, 3)
        if isequal(dim, 1)
            alpha = alpha_Y;
        else
            alpha = alpha_CbCr;
        end
        for x = 2:size(resImage, 1)
            for y = 2:size(resImage, 2)
                get_values = reshape(decReconImage(x-1:x, y-1:y, dim), [], 1);
                pred = sum(alpha .* get_values);
                decReconImage(x, y, dim) = pred + resImage(x, y, dim);
            end
        end
    end
end

%%
function yuv = ictRGB2YCbCr(rgb)
% Input         : rgb (Original RGB Image)
% Output        : yuv (YCbCr image after transformation)
yuv(:,:,1) = 0.299 * rgb(:,:,1) + 0.587*rgb(:,:,2) + 0.114*rgb(:,:,3);
yuv(:,:,2) = -0.169 * rgb(:,:,1) -0.331*rgb(:,:,2) + 0.5*rgb(:,:,3);
yuv(:,:,3) = 0.5*rgb(:,:,1) - 0.419*rgb(:,:,2) - 0.081*rgb(:,:,3);
end

function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function H = calc_entropy(pmf)
    H = -sum(nonzeros(pmf).*log2(nonzeros(pmf)));
end

function rgb = ictYCbCr2RGB(yuv)
rgb(:,:,1) = yuv(:,:,1) + 1.402*yuv(:,:,3);
rgb(:,:,2) = yuv(:,:,1) - 0.344*yuv(:,:,2) - 0.714*yuv(:,:,3);
rgb(:,:,3) = yuv(:,:,1) + 1.772*yuv(:,:,2);
end

function MSE = calcMSE(Image, recImage)
Image = double(Image);
recImage = double(recImage);
dif_image = (Image-recImage).^2;
MSE = mean(dif_image(:));
end

function PSNR = calcPSNR(Image, recImage)
MSE = calcMSE(Image, recImage);
PSNR = 10 * log10((2^8-1)^2/MSE);
end

