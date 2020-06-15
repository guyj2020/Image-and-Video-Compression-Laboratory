%% Matlab Introduction of IVC Lab WS19/20
% This document gives a brief introduction to Matlab basics
% as well as to how to handle images in Matlab. The examples
% in this document are used in the Matlab Introduction for
% the course Image and Video Compression Laboratory offered
% by the Chair of Media Technology (LMT) at 
% Technische Universitaet Muenchen (TUM).
%
% Created by: Yang Peng (yang.peng@mytum.de)
% WS19/20 Modified by : Kai Cui (kai.cui@tum.de) and Martin Oelsch (martin.oelsch@tum.de)

%% Matlab Introduction 1 of 3
% Matlab basics
clear all
close all
clc
% create a scalar variable and assign value to it
var    = 4
% create a matrix and assign value to it
matrix = [1 2 3;4 5 6;7 8 9]
matrix = [1 2 3;4 5 6;7 8 9];
% access a single element
matrix(2,1)
% matrix(0,0)	%error
% matrix(10,10)
% access a row or a column
matrix(:,1)
matrix(1,:) = 1
% access multiple rows or columns
matrix(:,1:2)
matrix(:,1:2:end)
% matrix operations (arithmetic operators)
% All the typical scalar arithmetic operators are available:
dummy = matrix * 2
dummy = matrix * matrix
dummy = matrix .* matrix
dummy = matrix ^2
dummy = matrix .^2
dummy = matrix'
% Matlab has many built-in commands to do both
% elementary mathematical operations and also
% complex scientific calculations. (see help)
sqrt(4)
sin(pi/2)
%help
% basic programming commands (flow control)
% if for while switch break continue (see help)
% m-file: a list of commands to be executed sequentially

%% Matlab Introduction 2 of 3
% workspace
whos
save myworkspace
load myworkspace
% % image processing related %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read a image from a file
%im = double(imread('lena.tif'));
im = double(imread('data/images/lena.tif'));
% size of the image
[height, width, cdim] = size(im)
% min/max sum mean
min_intensity         = min(im(:))
max_intensity         = max(im(:))
% display a color image
figure('Name', 'Color Image');
imagesc(uint8(im));
figure;
imshow(uint8(im));
colormap('default');
% display a grayscale image
im_gray = im(:,:,1);
figure('Name', 'Grayscale Image');
imagesc(uint8(im_gray));
colormap('gray');
% plot images in the same figure
figure('Name', 'Matlab Introduction');
subplot(1,2,1);
imagesc(uint8(im));
subplot(1,2,2);
imagesc(uint8(im_gray));
colormap('gray');
% plot the intensity values
figure('Name','Intensity Values');
plot(im(:));
% plot the histogram
figure('Name', 'Histogram of the Intensity Values');
img_hist = hist(im(:),0:255);
plot(img_hist);
% plot two signals on top of each other for comparison
hold
img_hist = hist(im_gray(:),0:255);
plot(img_hist,'r-');

%% Matlab Introduction 3 of 3
% % try to avoid for loops
% % example : creating a grayscale image from a color image
tic % measure the excution time, see also "profile"
%im_gray = zeros(height, width); % !!! don't forget initilization
for h = 1 : height
    for w = 1 : width
        im_gray(h,w) = (im(h,w,1)+im(h,w,2)+im(h,w,3))/3;
    end
end
t = toc
% better solutions for creating the gray scale image
tic
im_gray = (im(:,:,1)+im(:,:,2)+im(:,:,3))/3;
t = toc
tic
%im_gray = sum(im./3,3);
im_gray = mean(im,3);
t = toc
% Reduce the image resolution
im_sub = im(1:2:end,1:2:end,:);
figure('Name','Subsampled Image');
imagesc(uint8(im_sub));
% Evaluate the image quality
im2  = im;
MSE  = sum((im(:)-im2(:)).^2)/(height*width*cdim)
PSNR = 10*log10(255.^2/MSE)
% Save the image in different formats
fid = fopen('lena_gray.bin','wb');
fwrite(fid,uint8(im_gray),'uint8');
fclose(fid);
imwrite(uint8(im_gray),'lena_gray.tif');
% writting your own functions %%%%%%%%%%%%%%%%%%%%
PSNR = MyPSNR(im,im2)