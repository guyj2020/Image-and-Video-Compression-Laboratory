% read original RGB image 
I_ori = double(imread('sail.tif'));
I_yuv = ictRGB2YCbCr(I_ori);
% YOUR CODE HERE for chroma subsampling 
I_rec_yuv = ictRGB2YCbCr(I_ori);

Cb = I_rec_yuv(:, :, 2);
Cr = I_rec_yuv(:, :, 3);

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

Cb_warp = padarray(Cb_crop, [2, 2], 'both', 'symmetric');
Cr_warp = padarray(Cr_crop, [2, 2], 'both', 'symmetric') ;

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

I_rec = ictYCbCr2RGB(I_rec_yuv);
% Evaluation
% I_rec is the reconstructed image in RGB color space
PSNR = calcPSNR(I_ori, I_rec);
fprintf('PSNR is %.2f dB\n', PSNR);

bpp = (numel(uint8(I_yuv(:,:,1))) * 8 + 8 * numel(uint8(Cb_crop)) + 8 * numel(uint8(Cr_crop)))/(size(I_rec, 1)*size(I_rec, 2));

plot(bpp, PSNR, 'x');
text(bpp, PSNR, '  sail.tif - E1-6')
hold on;
axis([0 24 10 50]);

% put all the sub-functions called in your script here
function rgb = ictYCbCr2RGB(yuv)
rgb(:,:,1) = yuv(:,:,1) + 1.402*yuv(:,:,3);
rgb(:,:,2) = yuv(:,:,1) - 0.344*yuv(:,:,2) - 0.714*yuv(:,:,3);
rgb(:,:,3) = yuv(:,:,1) + 1.772*yuv(:,:,2);
end

function yuv = ictRGB2YCbCr(rgb)
r = rgb(:,:,1);
g = rgb(:,:,2);
b = rgb(:,:,3);
yuv(:,:,1) = 0.299 * r + 0.587*g + 0.114*b;
yuv(:,:,2) = -0.169 * r -0.331* g + 0.5*b;
yuv(:,:,3) = 0.5*r - 0.419*g - 0.081*b;
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