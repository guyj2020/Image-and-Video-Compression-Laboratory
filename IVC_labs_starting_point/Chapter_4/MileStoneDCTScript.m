lena_small = double(imread('lena_small.tif'));
Lena       = double(imread('lena.tif'));

scales = 1 : 0.6 : 1; % quantization scale factor, for E(4-1), we just evaluate scale factor of 1
for scaleIdx = 1 : numel(scales)
    qScale   = scales(scaleIdx);
    k_small  = IntraEncode(lena_small, qScale);
    k        = IntraEncode(Lena, qScale);
    %% use pmf of k_small to build and train huffman table
    %your code here
    pmfqLenaSmall = stats_marg(k_small, -128:1000);
    [BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman(pmfqLenaSmall);
    
    add_int = -min(k)+1;
    bytestream = enc_huffman_new(k+add_int, BinCode, Codelengths);
    
    k_rec = double(reshape(dec_huffman_new(bytestream, BinaryTree, max(size(k(:)))), size(k)))-add_int;

    %% use trained table to encode k to get the bytestream
    % your code here
    bitPerPixel(scaleIdx) = (numel(bytestream)*8) / (numel(Lena)/3);
    %% image reconstruction
    I_rec = IntraDecode(k_rec, size(Lena),qScale);
    PSNR(scaleIdx) = calcPSNR(Lena, I_rec);
    fprintf('QP: %.1f bit-rate: %.2f bits/pixel PSNR: %.2fdB\n', qScale, bitPerPixel(scaleIdx), PSNR(scaleIdx))
    plot(bitPerPixel(scaleIdx), PSNR(scaleIdx), 'x');
    text(bitPerPixel(scaleIdx), PSNR(scaleIdx), '  lena.tif - E4-2')

end

