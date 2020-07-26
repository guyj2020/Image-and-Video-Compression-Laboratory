% clc
% clear
% 
% errim = [48, 210, 255, 241; 50, 193, 200, 203; ...
%          54 198, 180, 172; 50, 208, 215, 180];
%      
% QStep = 0.6250;
% QP = 1;
% 
% int_errim = IntTrafoQuant4x4(errim, QP);
% rec_errim = InvIntTrafoQuant4x4(int_errim, QP);
% 
%      
% errim == rec_errim   
% errim
% rec_errim

clear global
clear 
clc

global modesPred

lena_smallRGB = double(imread('lena_small.tif'));
lena_small = ictRGB2YCbCr(double(imread('lena_small.tif')));
imgY = lena_small(:, :, 1);
QP = 1;
[I_frame] = Intra4x4Enc(imgY, QP);
rec_I_frame = Intra4x4Dec(I_frame, QP, modesPred);


a = lena_small;
a(:, :, 1) = rec_I_frame;
calcPSNR(lena_smallRGB, ictYCbCr2RGB(a))




