%% DO NOT MODIFY THIS CODE
%% SSD
clear;
clc;
tic
image = double(imread('lena_small.tif'));
reference_image = ictRGB2YCbCr(image);

mv_indices = SSD(reference_image(:,:,1), image(:,:,1));

rec_image = SSD_rec(reference_image, mv_indices);
toc