%% DO NOT MODIFY THIS CODE
%% SSD
clear;
clc;
tic
% image = double(imread('lena_small.tif'));

directory = fullfile('../../sequences', 'foreman20_40_RGB');
path(path, directory)
frames = dir(fullfile(directory,'*.bmp'));

image = double(imread(fullfile(directory, frames(1).name)));
image2  = double(imread(fullfile(directory, frames(2).name)));
reference_image = ictRGB2YCbCr(image2);
image = ictRGB2YCbCr(image);

% mv_indices = SSD(reference_image(:,:,1), image(:,:,1));

[MV_choice, mv_indices8x16, mv_indices16x8, mv_indices16x16, mv_indices8x8] = SSD_h264(reference_image(:, :, 1), image(:, :, 1));
% rec_image = SSD_rec(reference_image, mv_indices);
mv_indices = cut_motion_vect_mat(MV_choice, mv_indices16x16, mv_indices8x8, mv_indices8x16, mv_indices16x8);

rec_image = SSDRec_h264(reference_image, MV_choice, mv_indices16x16, mv_indices);

calcPSNR(reference_image, rec_image)
imshow(uint8(ictYCbCr2RGB(rec_image)))
toc
