clear 
clc

qScale = 1.0;
EoB = 4000;

lena_small = (double(imread('lena_small.tif')));
img = double(imread('lena.tif'));

% TODO: Set true to false wenn ende

% TODO: Encode with Integer Trafo -> inv works only with right quantization

k_small  = IntraEncodeInt(lena_small, qScale, EoB, 0, false);
k        = IntraEncodeInt(img, qScale, EoB, 0, false);



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
% I_rec = IntraDecodeInt(k_rec, size(img), qScale, EoB, 0, false);
I_rec = IntraDecode(k_rec, size(img), qScale, EoB, 0, false);

PSNR = calcPSNR(img, I_rec)

