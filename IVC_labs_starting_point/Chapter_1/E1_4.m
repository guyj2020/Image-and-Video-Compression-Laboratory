% image read
I_lena = double(imread('lena.tif'));
I_sail = double(imread('sail.tif'));

% Wrap Round
% YOUR CODE HERE
% 'replicate' potentiell needed
I_lena_pad = padarray(I_lena, [4, 4], 'both', 'symmetric');
I_sail_pad = padarray(I_sail, [4, 4], 'both', 'symmetric') ;

% Resample(subsample)
% YOUR CODE HERE
% I_lena_sub = I_lena_pad(1:2:end, 1:2:end, :);
% I_sail_sub = I_sail_pad(1:2:end, 1:2:end, :);
for i = 1:size(I_lena_pad, 3)
    tmp = resample(I_lena_pad(:,:,i), 1, 2, 3);
    tmp = resample(tmp', 1, 2, 2);
    I_lena_sub(:,:,i) = tmp';
end

for i = 1:size(I_sail_pad, 3)
    tmp = resample(I_sail_pad(:,:,i), 1, 2, 3);
    tmp = resample(tmp', 1, 2, 2);
    I_sail_sub(:,:,i) = tmp';
end
% Crop Back
% YOUR CODE HERE
I_lena_crop = I_lena_sub(3:end-2, 3:end-2, :);
I_sail_crop = I_sail_sub(3:end-2, 3:end-2, :);

% Wrap Round
% YOUR CODE HERE
I_lena_warp = padarray(I_lena_crop, [2, 2], 'both', 'symmetric');
I_sail_warp = padarray(I_sail_crop, [2, 2], 'both', 'symmetric') ;

% Resample (upsample)
% YOUR CODE HERE
% I_lena_up = zeros(size(I_lena_pad));
% I_sail_up = zeros(size(I_sail_pad));
% I_lena_up(1:2:end, 1:2:end, :) = I_lena_warp;
% I_sail_up(1:2:end, 1:2:end, :) = I_sail_warp;
for i = 1:size(I_lena_warp, 3)
    tmp = resample(I_lena_warp(:,:,i), 2, 1, 3);
    tmp = resample(tmp', 2, 1, 2);
    I_lena_up(:,:,i) = tmp';
end

for i = 1:size(I_sail_warp, 3)
    tmp = resample(I_sail_warp(:,:,i), 2, 1, 3);
    tmp = resample(tmp', 2, 1, 3);
    I_sail_up(:,:,i) = tmp';
end
% Crop back
% YOUR CODE HERE
I_rec_lena = I_lena_up(5:end-4, 5:end-4, :);
I_rec_sail = I_sail_up(5:end-4, 5:end-4, :);

% Distortion Analysis
PSNR_lena        = calcPSNR(I_lena, I_rec_lena);
PSNR_sail        = calcPSNR(I_sail, I_rec_sail);
fprintf('PSNR lena subsampling = %.3f dB\n', PSNR_lena)
fprintf('PSNR sail subsampling = %.3f dB\n', PSNR_sail)

bpp_lena = (numel(uint8(I_lena_crop)) * 8)/(size(I_rec_lena, 1)*size(I_rec_lena, 2));
bpp_sail = (numel(uint8(I_sail_crop)) * 8)/(size(I_rec_sail, 1)*size(I_rec_sail, 2));

plot(bpp_lena, PSNR_lena, 'x');
text(bpp_lena, PSNR_lena, '  lena.tif - E1-4')
hold on;

plot(bpp_sail, PSNR_sail, 'x');
text(bpp_sail, PSNR_sail, '  sail.tif - E1-4')
hold on;

% put all the sub-functions called in your script here
function MSE = calcMSE(Image, recImage)
% YOUR CODE HERE
Image = double(Image);
recImage = double(recImage);
dif_image = (Image-recImage).^2;
MSE = mean(dif_image(:));
end

function PSNR = calcPSNR(Image, recImage)
% YOUR CODE HERE
MSE = calcMSE(Image, recImage);
PSNR = 10 * log10((2^8-1)^2/MSE);
end