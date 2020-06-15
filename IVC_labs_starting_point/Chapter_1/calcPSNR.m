function PSNR = calcPSNR(Image, recImage)
% Input         : Image    (Original Image)
%                 recImage (Reconstructed Image)
%
% Output        : PSNR     (Peak Signal to Noise Ratio)
MSE = calcMSE(Image, recImage);
PSNR = 10 * log10((2^8-1)^2/MSE);
end