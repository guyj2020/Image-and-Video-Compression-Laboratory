%% DO NOT MODIFY THIS CODE
%% This code will call your function and should work without any changes
%% Main
bits         = 8;
epsilon      = 0.1;
block_size   = 2;
M            = 2^bits;
%% lena small for VQ training
image_small  = double(imread('lena_small.tif'));
[clusters, Temp_clusters] = VectorQuantizer(image_small, bits, epsilon, block_size);
qImage_small              = ApplyVectorQuantizer(image_small, clusters, block_size);
%% Huffman table training
pmfqLenaSmall = stats_marg(qImage_small, 1:M);
[BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);

%% 
image  = double(imread('lena.tif'));
qImage = ApplyVectorQuantizer(image, clusters, block_size);
%% Huffman encoding
bytestream = enc_huffman_new(qImage(:), BinCode, Codelengths);

%%
bpp  = (numel(bytestream) * 8) / (numel(image)/3);
%% Huffman decoding
qReconst_image = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(qImage(:))) ), size(qImage)));

%%
reconst_image  = InvVectorQuantizer(qReconst_image, clusters, block_size);
PSNR = calcPSNR(image, reconst_image);

fprintf("lena.tif - Bit/pixel = %.2f; PSNR = %.2f dB\n", [bpp, PSNR]);


plot(bpp, PSNR, 'x');
text(bpp, PSNR, ' lena - VQ')

% imageLena_small = double(imread('lena_small.tif'));
% imageLena = double(imread('lena.tif'));
% bits         = 8;
% epsilon      = 0.1;
% block_size   = 2;
% bsize = block_size;
% 
% [clusters, Temp_clusters] = VectorQuantizer(imageLena_small, bits, epsilon, block_size);
% 
% qImage_small = ApplyVectorQuantizer(imageLena_small, clusters, block_size);
% qImage = ApplyVectorQuantizer(imageLena, clusters, block_size);
% 
% reconst_image = InvVectorQuantizer(qImage, clusters, block_size);
% 
% PSNR = calcPSNR(imageLena, reconst_image);
% fprintf("lena.tif -  PSNR = %.2f dB\n", PSNR);
