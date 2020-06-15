% Image_lena = imread('lena.tif');
% Image_lena_compressed = imread('lena_compressed.tif');
% Image_monarch = imread('monarch.tif');
% Image_monarch_compressed = imread('monarch_compressed.tif');
% 
% % YOUR CODE HERE
% % do NOT change the name of variables (PSNR_lena, PSNR_monarch), the assessment code will check these values with our reference answers, same for all the script assignment.
% PSNR_lena = calcPSNR(Image_lena, Image_lena_compressed);
% PSNR_monarch = calcPSNR(Image_monarch, Image_monarch_compressed);
% 
% fprintf('PSNR of lena.tif is %.3f dB\n', PSNR_lena)
% fprintf('PSNR of monarch.tif is %.3f dB\n', PSNR_monarch)
% 
% 
% bpp_elna = (numel(uint8(Image_lena_compressed)) * 8)/(size(Image_lena, 1)*size(Image_lena, 2));

bpp_elna = 8;
plot(bpp_elna, 15.460, 'x');
text(bpp_elna, 15.460, '  lena - E1-1')
hold on;
axis([0 24 10 50]);


bpp_mon = 8;

plot(bpp_mon, 17.021, 'x');
text(bpp_mon, 17.021, '  monarch - E1-1')
hold on;
axis([0 24 10 50]);

% subplot(221), imshow(Image_lena), title('Original Image Lena')
% subplot(222), imshow(Image_lena_compressed), title('Compressed Image Lena')
% subplot(223), imshow(Image_monarch), title('Original Image Monarch')
% subplot(224), imshow(Image_monarch_compressed), title('Compressed Image Monarch')

% put all the sub-functions called in your script here
function MSE = calcMSE(Image, recImage)
% Input         : Image    (Original Image)
%                 recImage (Reconstructed Image)
% Output        : MSE      (Mean Squared Error)
Image = double(Image);
recImage = double(recImage);

dif_image = (Image-recImage).^2;
MSE = mean(dif_image(:));
end

function PSNR = calcPSNR(Image, recImage)
% Input         : Image    (Original Image)
%                 recImage (Reconstructed Image)
%
% Output        : PSNR     (Peak Signal to Noise Ratio)
MSE = calcMSE(Image, recImage);
PSNR = 10 * log10((2^8-1)^2/MSE);
end