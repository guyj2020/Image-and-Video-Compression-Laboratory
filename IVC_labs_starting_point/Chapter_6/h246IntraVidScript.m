function [PSNR, BPP, I_rec] = h246IntraVidScript(img, QP, EoB)

lena_small = ictRGB2YCbCr(double(imread('lena_small.tif')));

[k_small, ~] = IntraEncodeH264(lena_small, QP, EoB);
[k, modesPred] = IntraEncodeH264(img, QP, EoB);

pmfqLenaSmall = stats_marg(k_small, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
[BinaryTree, ~, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);
% k_small_min = min(k_small);
off_set = 1000+1;%-min(k_small_min, min(k))+1;
bytestream = enc_huffman_new(k+off_set, BinCode, Codelengths);

k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(k(:)))), size(k)))-off_set;


BPP = (numel(bytestream)*8) / (numel(img));
% I_rec = IntraDecode(k_rec, size(img), qScale, EoB, 1);
I_recYCbCr = IntraDecodeH264(k_rec, size(img), modesPred, QP, EoB);
I_rec = ictYCbCr2RGB(I_recYCbCr);
PSNR = calcPSNR(ictYCbCr2RGB(img), I_rec);
end