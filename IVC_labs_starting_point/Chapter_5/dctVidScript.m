function [PSNR, BPP, I_rec, BinCode, Codelengths, BinaryTree, k_small_min] = dctVidScript(img, qScale, EoB, BinCode, Codelengths, BinaryTree)


lena_small = (double(imread('lena_small.tif')));

k_small  = IntraEncode(lena_small, qScale, EoB, 1);
k        = IntraEncode(img, qScale, EoB, 1);

k_small_min = min(k_small);
off_set = -min(k_small_min, min(k))+1;
bytestream = enc_huffman_new(k+off_set, BinCode, Codelengths);

k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(k(:)))), size(k)))-off_set;


BPP = (numel(bytestream)*8) / (numel(img)/3);
I_rec = IntraDecode(k_rec, size(img), qScale, EoB, 1);
PSNR = calcPSNR(img, I_rec);
end
