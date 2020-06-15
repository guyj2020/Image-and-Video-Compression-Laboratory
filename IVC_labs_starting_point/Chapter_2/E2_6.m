%% read image
imageLena       = double(imread('lena.tif'));
imageLena_small = double(imread('lena_small.tif'));

[~, pmfResLenaSmall, ~, ~] = predictiveCod(imageLena_small, 1);
[resImageLena, ~, ~, ~] = predictiveCod(imageLena, 1);
[decResImageLena, ~, ~, decReconImageLena] = predictiveCod(resImageLena, 0);
rgb = ictYCbCr2RGB(decReconImageLena);

figure;
subplot(1, 2,1 )
imshow(uint8(imageLena))
subplot(1, 2,2 )
imshow(uint8(rgb))
%% Coding
% codebook construction
[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(pmfResLenaSmall);

%% Encoding
bytestream = enc_huffman_new(round(resImageLena(:))+255+1, BinCode, Codelengths);

%% Decoding
rec_image_dec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(resImageLena(:)))), size(resImageLena))) - 1 - 255;







%%
% ict and subsample
imageLenaYUV = ictRGB2YCbCr(imageLena);

Y = imageLenaYUV(:, :, 1);
Cb = imageLenaYUV(:, :, 2);
Cr = imageLenaYUV(:, :, 3);

Cb_pad = padarray(Cb, [4, 4], 'both', 'symmetric');
Cr_pad = padarray(Cr, [4, 4], 'both', 'symmetric') ;

Cb_sub = resample(resample(Cb_pad, 1, 2, 3)', 1, 2, 3)';
Cr_sub = resample(resample(Cr_pad, 1, 2, 3)', 1, 2, 3)';

Cb_crop = Cb_sub(3:end-2, 3:end-2);
Cr_crop = Cr_sub(3:end-2, 3:end-2);

imageLenaYUV_TMP = zeros(size(imageLenaYUV));
imageLenaYUV_TMP(:,:,1 ) = Y;
imageLenaYUV_TMP(1:size(Cb_crop, 1), 1:size(Cb_crop, 2), 2) = Cb_crop;
imageLenaYUV_TMP(1:size(Cr_crop, 1), 1:size(Cr_crop, 2), 3) = Cr_crop;
%% Residual calculation
% alpha_Y = [-1/2; 7/8; 5/8; 0];
% alpha_CbCr = [-1/4; 3/8; 7/8; 0];
% [reconImageY, resImageY] = predictiveCodingOneDim(Y, alpha_Y);
% [reconImageCb, resImageCb] = predictiveCodingOneDim(Cb_crop, alpha_CbCr);
% [reconImageCr, resImageCr] = predictiveCodingOneDim(Cr_crop, alpha_CbCr);
[resImageLena, pmfResLena, H_resLena, reconImageLena] = predictiveCod(imageLenaYUV_TMP);

%% Reconstruction

sz_yuv1 = (size(imageLenaYUV(:, :, 1), 1) * size(imageLenaYUV(:, :, 1), 2));
I_rec_yuv(:, :, 1) = reshape(rec_image_dec(1:sz_yuv1), size(imageLenaYUV(:, :, 1), 1), size(imageLenaYUV(:, :, 1), 2));
yuv_2 = reshape(rec_image_dec(sz_yuv1+1:sz_yuv1+size(Cb_crop(:),1)), size(Cb_crop, 1), size(Cb_crop, 2));
yuv_3 = reshape(rec_image_dec(sz_yuv1+size(Cb_crop(:),1)+1:end), size(Cb_crop, 1), size(Cb_crop, 2));

Cb_warp = padarray(yuv_2, [2, 2], 'both', 'symmetric');
Cr_warp = padarray(yuv_3, [2, 2], 'both', 'symmetric') ;

Cb_up = resample(resample(Cb_warp, 2, 1, 3)', 2, 1, 3)';
Cr_up = resample(resample(Cr_warp, 2, 1, 3)', 2, 1, 3)';

Cb_rec = Cb_up(5:end-4, 5:end-4);
Cr_rec = Cr_up(5:end-4, 5:end-4);

I_rec_yuv(:,:, 2) = Cb_rec;
I_rec_yuv(:,:, 3) = Cr_rec;

rec_image = ictYCbCr2RGB(I_rec_yuv);

%% evaluation and show results
figure
subplot(121)
imshow(uint8(imageLena)), title('Original Image')
subplot(122)

PSNR = calcPSNR(imageLena, rec_image);
imshow(uint8(rec_image)), title(sprintf('Reconstructed Image, PSNR = %.2f dB', PSNR))

BPP = numel(bytestream) * 8 / (numel(imageLena));
CompressionRatio = 24/BPP;

fprintf('Bit Rate         = %.2f bit/pixel\n', BPP);
fprintf('CompressionRatio = %.2f\n', CompressionRatio);
fprintf('PSNR             = %.2f dB\n', PSNR);

% Put all sub-functions which are called in your script here.
function [resImage, pmfRes, H_res, reconImage] = predictiveCod(imageLenaSmall, yuv)
    if yuv == 1
        yuvLena = ictRGB2YCbCr(imageLenaSmall);
    else 
        if yuv == 0
            yuvLena = imageLenaSmall;
        end
    end
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
