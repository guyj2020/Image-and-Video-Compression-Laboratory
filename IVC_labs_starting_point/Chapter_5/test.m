%% DO NOT MODIFY THIS CODE
%% This code will call your function and should work without any changes
% load('image_ycbcr');
% load('ref_image_ycbcr');
% clear;
% clc;
image = double(imread('lena_small.tif'));
reference_image = ictRGB2YCbCr(image);

mv_indices = SSD(reference_image(:,:,1), image(:,:,1));
