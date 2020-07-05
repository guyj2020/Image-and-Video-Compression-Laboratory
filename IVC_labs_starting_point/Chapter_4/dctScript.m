function [PSNR, BPP, I_rec, BinCode, Codelengths, BinaryTree, k_small] = dctScript(img, qScale, EoB)

lena_small = (double(imread('lena_small.tif')));

k_small  = IntraEncode(lena_small, qScale, EoB, 0, false);
k        = IntraEncode(img, qScale, EoB, 0, false);
%% use pmf of k_small to build and train huffman table
%your code here
pmfqLenaSmall = stats_marg(k_small, -1000:4000);%min(min(k_small), min(k)):max(max(k_small), max(k)));
[BinaryTree, ~, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);

% k_small_min = min(k_small);
off_set = 1000+1;%-min(k_small_min, min(k))+1;
bytestream = enc_huffman_new(k+off_set, BinCode, Codelengths);

k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(k(:)))), size(k)))-off_set;

%% use trained table to encode k to get the bytestream
% your code here
BPP = (numel(bytestream)*8) / (numel(img)/3);
%% image reconstruction
I_rec = IntraDecode(k_rec, size(img), qScale, EoB, 0, false);
PSNR = calcPSNR(img, I_rec);
end

