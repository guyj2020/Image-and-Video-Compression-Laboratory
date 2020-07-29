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

% clear global
clear 
clc

% global modesPred
% lena_small = ictRGB2YCbCr(double(imread('foreman0020.bmp')));
% lena_smallRGB = double(imread('foreman0020.bmp'));
% 
lena_smallRGB = double(imread('lena_small.tif'));
lena_small = ictRGB2YCbCr(double(imread('lena_small.tif')));
imgY = lena_small(:, :, 1);
QP = 1;
% [I_frame, modesPred] = Intra4x4Enc(imgY, QP);
% [I_frameCB, modesPredCb] = Intra4x4Enc(lena_small(:, :, 2), QP);
% [I_frameCr, modesPredCr] = Intra4x4Enc(lena_small(:, :, 3), QP);
% [I_frameCB, modesPredCb] = Intra8x8CbCrEnc(lena_small(:, :, 2), QP);
% [I_frameCr, modesPredCr] = Intra8x8CbCrEnc(lena_small(:, :, 3), QP);
I_frame = zeros(size(lena_small));
rec_I_frame = zeros(size(lena_small));
for depth = 1:3
    [I_frame(:, :, depth), modesPred(:, :, depth)] = Intra4x4Enc(lena_small(:, :, depth), QP);
end


% k_small  = IntraEncode(lena_small, qScale, EoB, 0, false);
% k        = IntraEncode(img, qScale, EoB, 0, false);
% pmfqLenaSmall = stats_marg(k_small, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
% [BinaryTree, ~, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);
% 
% % k_small_min = min(k_small);
% off_set = 1000+1;%-min(k_small_min, min(k))+1;
% bytestream = enc_huffman_new(k+off_set, BinCode, Codelengths);
% 
% k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(k(:)))), size(k)))-off_set;
% 
% BPP = (numel(bytestream)*8) / (numel(img)/3);
% I_rec = IntraDecode(k_rec, size(img), qScale, EoB, 0, false);
% PSNR = calcPSNR(img, I_rec);



% DECODE

for depth = 1:3
    rec_I_frame(:, :, depth) = Intra4x4Dec(I_frame(:, :, depth), QP, modesPred(:, :, depth));
end

% rec_I_frame = Intra4x4Dec(I_frame, QP, modesPred);
% rec_I_frameCb = Intra4x4Dec(I_frameCB, QP, modesPredCb);
% rec_I_frameCr = Intra4x4Dec(I_frameCr, QP, modesPredCr);
% rec_I_frameCb = Intra4x4Dec(I_frameCB, QP, modesPredCb);
% rec_I_frameCr = Intra4x4Dec(I_frameCr, QP, modesPredCr);


% EVALUATE

calcPSNR(lena_smallRGB, ictYCbCr2RGB(rec_I_frame))
imshow(uint8(ictYCbCr2RGB(rec_I_frame)))
% a = lena_small;
% a(:, :, 1) = rec_I_frame;
% calcPSNR(lena_smallRGB, ictYCbCr2RGB(a))
% imshow(uint8(ictYCbCr2RGB(a)))

% % Eval 2
% b(:, :, 1) = rec_I_frame;
% b(:, :, 2) = rec_I_frameCb;
% b(:, :, 3) = rec_I_frameCr;
% 
% calcPSNR(lena_smallRGB, ictYCbCr2RGB(b))
% figure;
% imshow(uint8(ictYCbCr2RGB(b)))











