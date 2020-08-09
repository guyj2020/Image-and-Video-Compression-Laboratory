clear 
% clc

% global modesPred
% lena_small = ictRGB2YCbCr(double(imread('foreman0020.bmp')));
% lena_smallRGB = double(imread('foreman0020.bmp'));
% 

% lena_smallRGB = double(imread('lena_small.tif'));
lena_smallRGB = double(imread('lena.tif'));

lena_small = ictRGB2YCbCr(lena_smallRGB);
imgY = lena_small(:, :, 1);
QP = 1;
EoB = 4000;
% [I_frame, modesPred] = Intra4x4Enc(imgY, QP);
% [I_frameCB, modesPredCb] = Intra4x4Enc(lena_small(:, :, 2), QP);
% [I_frameCr, modesPredCr] = Intra4x4Enc(lena_small(:, :, 3), QP);
% [I_frameCB, modesPredCb] = Intra8x8CbCrEnc(lena_small(:, :, 2), QP);
% [I_frameCr, modesPredCr] = Intra8x8CbCrEnc(lena_small(:, :, 3), QP);
I_frame = zeros(size(lena_small));
rec_I_frame = zeros(size(lena_small));
modesPred = cell(3);
for depth = 1:1
    [I_frame(:, :, depth), modesPred{depth}] = Intra4x4Enc(lena_small(:, :, depth), QP);
end

[I_frame(:, :, 2), modesPredCB] = Intra8x8CbCrEnc(lena_small(:, :, 2), QP);
[I_frame(:, :, 3), modesPredCR] = Intra8x8CbCrEnc(lena_small(:, :, 3), QP);


I_frame_zigzag = blockproc(I_frame(:, :, 1), [4, 4], @(block_struct) ZigZag4x4(block_struct.data));
dst = ZeroRunEnc_EoB(I_frame_zigzag, EoB);
% dst = ZeroRunEnc(I_frame_zigzag(:));
pmfqLenaSmall = stats_marg(dst, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
[BinaryTree, ~, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);
off_set = 1000+1;%-min(k_small_min, min(k))+1;
bytestream = enc_huffman_new(dst+off_set, BinCode, Codelengths);
k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(dst(:)))), size(dst)))-off_set;
BPP = (numel(bytestream)*8) / (numel(lena_smallRGB)/3)

% DECODE

for depth = 1:1
    rec_I_frame(:, :, depth) = Intra4x4Dec(I_frame(:, :, depth), QP, modesPred{depth});
end
% rec_I_frame(:, :, 2) = lena_small(:, :, 2);
% rec_I_frame(:, :, 3) = lena_small(:, :, 3);
rec_I_frame(:, :, 2) = Intra8x8CbCrDec(I_frame(:, :, 2), QP, modesPredCB);
rec_I_frame(:, :, 3) = Intra8x8CbCrDec(I_frame(:, :, 3), QP, modesPredCR);


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











