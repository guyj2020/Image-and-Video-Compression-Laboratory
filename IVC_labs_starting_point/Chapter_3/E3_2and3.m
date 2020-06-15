%% DO NOT MODIFY THIS CODE
%% This code will call your function and should work without any changes
imageLena_small = double(imread('lena_small.tif'));
imageLena = double(imread('lena.tif'));

bits = 3;
epsilon = 0.001;
for bit = bits
    [qImage, clusters] = LloydMax(imageLena, bit, epsilon);
    [qImage_small, clusters_small] = LloydMax(imageLena_small, bit, epsilon);
end

recImage = InvLloydMax(qImage, clusters);
recImage_small = InvLloydMax(qImage_small, clusters_small);

PSNR = calcPSNR(imageLena, recImage);
PSNR_small = calcPSNR(imageLena_small, recImage_small);

fprintf("lena_small.tf - M/colorplane= %d  PSNR = %.2f dB\n", [bits, PSNR_small]);
fprintf("lena.tf - M/colorplane= %d  PSNR = %.2f dB\n", [bits, PSNR]);
