function [PSNR, BPP, I_rec] = h246IntraVidScript(img, QP, EoB)

lena_small = ictRGB2YCbCr(double(imread('lena_small.tif')));

[k_small, ~, ~] = IntraEncodeH264(lena_small, QP, EoB);
[k, modesPredY, modesPredCbCr] = IntraEncodeH264(img, QP, EoB);

pmfqLenaSmall = stats_marg(k_small, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
[BinaryTree, ~, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);


pmfModePredY = stats_marg(modesPredY, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
[BinaryTreeModePredY, ~, BinCodeModePredY, CodelengthsModePredY] = buildHuffman(pmfModePredY);

pmfModePredCbCr = stats_marg(modesPredCbCr, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
[BinaryTreeModePredCbCr, ~, BinCodeModePredCbCr, CodelengthsModePredCbCr] = buildHuffman(pmfModePredCbCr);


% k_small_min = min(k_small);
off_set = 1000+1;%-min(k_small_min, min(k))+1;

bytestream = enc_huffman_new(k+off_set, BinCode, Codelengths);

bytestreamY = enc_huffman_new(modesPredY+off_set, BinCodeModePredY, CodelengthsModePredY);
bytestreamCbCr = enc_huffman_new(modesPredCbCr+off_set, BinCodeModePredCbCr, CodelengthsModePredCbCr);

k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(k(:)))), size(k)))-off_set;

modesPredY_rec = double(reshape(dec_huffman_new(bytestreamY, BinaryTreeModePredY, max(size(modesPredY(:)))), size(modesPredY)))-off_set;
modesPredCbCr_rec = double(reshape(dec_huffman_new(bytestreamCbCr, BinaryTreeModePredCbCr, max(size(modesPredCbCr(:)))), size(modesPredCbCr)))-off_set;


BPP1 = (numel(bytestream)*8) / (numel(img)/3);
BPP2 = (numel(bytestreamY)*8) / (numel(img)/3);
BPP3 = (numel(bytestreamCbCr)*8) / (numel(img)/3);

BPP = BPP1 + BPP2 + BPP3;
% I_rec = IntraDecode(k_rec, size(img), qScale, EoB, 1);
I_recYCbCr = IntraDecodeH264(k_rec, size(img), modesPredY_rec, modesPredCbCr_rec, QP, EoB);
I_rec = ictYCbCr2RGB(I_recYCbCr);
PSNR = calcPSNR(ictYCbCr2RGB(img), I_rec);
end