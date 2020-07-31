scales = [0.07, 0.2, 0.4, 0.8, 1.0, 1.5, 2, 3, 4, 4.5];
EoB = 4000;

directory = fullfile('../../sequences', 'foreman20_40_RGB'); % path to src in the first part
path(path, directory)
frames = dir(fullfile(directory,'*.bmp'));

psnr = zeros(length(frames), 1);
rate = zeros(length(frames), 1);

final_rate = zeros(size(scales, 2), 1);
final_psnr = zeros(size(scales, 2), 1);

still_im_rate = zeros(length(frames), 1);
still_im_psnr = zeros(length(frames), 1);

final_still_rate = zeros(size(scales, 2), 1);
final_still_psnr = zeros(size(scales, 2), 1);

for s = 1:numel(scales)
    qScale = scales(s);
    for i = 1:length(frames)
        im = double(imread(fullfile(directory, frames(i).name)));
        im1 = ictRGB2YCbCr(im);
        [PSNR, BPP, ref_rgb_im, ~, ~, ~, k_small_min] = dctScript(im, qScale, EoB);
        still_im_rate(i) = BPP;
        still_im_psnr(i) = PSNR;

        if i == 1     % Encode and decode the 1st frame
            psnr(i) = PSNR;
            rate(i) = BPP;
            ref_im = ictRGB2YCbCr(ref_rgb_im);            
            continue;
        end
        mv_indices = SSD(ref_im(:,:,1), im1(:,:,1));
        rec_im = SSD_rec(ref_im, mv_indices);
        err_im = im1-rec_im;
        try
            zeroRun= IntraEncode(err_im, qScale, EoB, 0, true);
            if isequal(i, 2)
                pmfMV = stats_marg(mv_indices, min(mv_indices(:)):max(mv_indices(:)));
                [BinaryTreeMV, ~, BinCodeMV, CodelengthsMV] = buildHuffman(pmfMV);
            end

            pmfZR = stats_marg(zeroRun, min(zeroRun(:)):max(zeroRun(:)));
            [BinaryTreeZR, ~, BinCodeZR, CodelengthsZR] = buildHuffman(pmfZR);

            off_setZR = -min(zeroRun(:))+1;
            off_setMV = -min(mv_indices(:))+1;

            bytestream1 = enc_huffman_new(zeroRun+off_setZR, BinCodeZR, CodelengthsZR);
            bytestream2 = enc_huffman_new(mv_indices+off_setMV, BinCodeMV, CodelengthsMV);

            dec_bytestream1 = double(reshape(dec_huffman_new(bytestream1, BinaryTreeZR, max(size(zeroRun(:)))), size(zeroRun)))-off_setZR;
            dec_bytestream2 = double(reshape(dec_huffman_new(bytestream2, BinaryTreeMV, max(size(mv_indices(:)))), size(mv_indices)))-off_setMV;

            bpp1 = (numel(bytestream1)*8) / (numel(im)/3);
            bpp2 = (numel(bytestream2)*8) / (numel(im)/3);

            dec_err_im = IntraDecode(dec_bytestream1, size(err_im), qScale, EoB, 0, true);

        catch
            zeroRun= IntraEncode(err_im, qScale, EoB, 1, true);
            if isequal(i, 2)
                pmfMV = stats_marg(mv_indices, min(mv_indices(:)):max(mv_indices(:)));
                [BinaryTreeMV, ~, BinCodeMV, CodelengthsMV] = buildHuffman(pmfMV);
            end

            pmfZR = stats_marg(zeroRun, min(zeroRun(:)):max(zeroRun(:)));
            [BinaryTreeZR, ~, BinCodeZR, CodelengthsZR] = buildHuffman(pmfZR);

            off_setZR = -min(zeroRun(:))+1;
            off_setMV = -min(mv_indices(:))+1;

            bytestream1 = enc_huffman_new(zeroRun+off_setZR, BinCodeZR, CodelengthsZR);
            bytestream2 = enc_huffman_new(mv_indices+off_setMV, BinCodeMV, CodelengthsMV);

            dec_bytestream1 = double(reshape(dec_huffman_new(bytestream1, BinaryTreeZR, max(size(zeroRun(:)))), size(zeroRun)))-off_setZR;
            dec_bytestream2 = double(reshape(dec_huffman_new(bytestream2, BinaryTreeMV, max(size(mv_indices(:)))), size(mv_indices)))-off_setMV;

            bpp1 = (numel(bytestream1)*8) / (numel(im)/3);
            bpp2 = (numel(bytestream2)*8) / (numel(im)/3);
            dec_err_im = IntraDecode(dec_bytestream1, size(err_im), qScale, EoB, 1, true);

        end
        
        dec_rec_im = SSD_rec(ref_im, dec_bytestream2);

        ref_im = dec_err_im + dec_rec_im;%rec_im;
        img_rec = ictYCbCr2RGB(ref_im);
        
        rate(i) = bpp1 + bpp2;
        psnr(i) = calcPSNR(im, img_rec);
    end
    final_still_rate(s) = mean(still_im_rate);
    final_still_psnr(s) = mean(still_im_psnr);
    
    final_rate(s) = mean(rate);
    final_psnr(s) = mean(psnr);
    fprintf('Final Results: \n');
    fprintf('QP: %.1f bit-rate: %.3f bits/pixel PSNR: %.2fdB\n', qScale, final_rate(s), final_psnr(s))
    
end

% figure;
hold on
plot(final_rate, final_psnr, 'bx-')
xlabel("bpp");
ylabel('PSNR [dB]');

hold on;
plot(final_still_rate, final_still_psnr, 'rx-')
set(gca,'XTick', 0.0:0.5:6);

%% All Functions

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

function dst = IntraDecode(image, img_size , qScale, EoB, zr_setter, ycbcr)
%  Function Name : IntraDecode.m
%  Input         : image (zero-run encoded image, 1xN)
%                  img_size (original image size)
%                  qScale(quantization scale)
%  Output        : dst   (decoded image)

if isequal(zr_setter, 1)
    enc_dec = reshape(ZeroRunDec(image), [img_size(1)*8, prod(img_size)/(img_size(1)*8)]);
else
    enc_dec = reshape(ZeroRunDec_EoB(image, EoB), [img_size(1)*8, prod(img_size)/(img_size(1)*8)]);
end
enc_zigzag = blockproc(enc_dec, [64, 1], @(block_struct) DeZigZag8x8(block_struct.data));

% reshape
enc_zigzag_reshaped = zeros(img_size);
int_im1 = [];
int_im2 = [];
int_im3 = [];
for j = 0:7
    int_im1 = [int_im1, (1:img_size(3)*8:prod(img_size)/img_size(1))+j];
    int_im2 = [int_im2, (9:img_size(3)*8:prod(img_size)/img_size(1))+j];
    int_im3 = [int_im3, (17:img_size(3)*8:prod(img_size)/img_size(1))+j];
end
enc_zigzag_reshaped(:, :, 1) = enc_zigzag(:, sort(int_im1));
enc_zigzag_reshaped(:, :, 2) = enc_zigzag(:, sort(int_im2));
enc_zigzag_reshaped(:, :, 3) = enc_zigzag(:, sort(int_im3));

rec_imageYCbCr_dequant = blockproc(enc_zigzag_reshaped, [8, 8], @(block_struct) DeQuant8x8(block_struct.data, qScale));
rec_imageYCbCr_Idct = blockproc(rec_imageYCbCr_dequant, [8, 8], @(block_struct) IDCT8x8(block_struct.data));
if ~ycbcr
    dst = ictYCbCr2RGB(rec_imageYCbCr_Idct);
else
    dst = rec_imageYCbCr_Idct;
end

end

function dst = IntraEncode(image, qScale, EoB, zr_setter, ycbcr)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, 1xN)

if ~ycbcr
    imageYCbCr = ictRGB2YCbCr(image);
else
    imageYCbCr = image;
end
imageYCbCr_dct = blockproc(imageYCbCr, [8, 8], @(block_struct) DCT8x8(block_struct.data));
imageYCbCr_quant = blockproc(imageYCbCr_dct, [8, 8], @(block_struct) Quant8x8(block_struct.data, qScale));
imageYCbCr_zigzag = blockproc(imageYCbCr_quant, [8, 8], @(block_struct) ZigZag8x8(block_struct.data));
if isequal(zr_setter, 0)
    dst = ZeroRunEnc_EoB(imageYCbCr_zigzag, EoB);
else
    dst = ZeroRunEnc(imageYCbCr_zigzag(:));
end
end

function dst = ZeroRunEnc(src)
    % place your function code here
    index = 1;
    symbol(index) = src(1);
    magnitude(index) = 1;
    for i = 2:1:length(src)
        if eq(src(i),0)
            if eq(src(i), src(i-1))
                magnitude(index) = magnitude(index) + 1;
            else
                index = index + 1;
                symbol(index) = src(i);
                magnitude(index) = 1;
            end
        else
            index = index + 1;
            symbol(index) = src(i);
            magnitude(index) = 1;
        end
    end
    dst = [];

    for i = 1:length(symbol)
        if symbol(i) == 0 
            codeTemp = [0 magnitude(i)];
        else
            codeTemp = symbol(i);
        end
        dst = [dst codeTemp];
    end


end

function zze = ZeroRunEnc_EoB(zz, EOB)
%  Input         : zz (Zig-zag scanned sequence, 1xN)
%                  EOB (End Of Block symbol, scalar)
%
%  Output        : zze (zero-run-level encoded sequence, 1xM)
 %
    zz = reshape(zz, [64, numel(zz)/64]);
    counter = 1;
    for idx = 1:size(zz, 2)
        zz_idx = zz(:, idx);
        index = 1;
        symbol = [];
        magnitude = [];
        
        symbol(index) = zz_idx(1);
        magnitude(index) = 0;
        for i = 2:1:length(zz_idx)
            if eq(zz_idx(i),0)
                if eq(zz_idx(i), zz_idx(i-1))
                    magnitude(index) = magnitude(index) + 1;
                else
                    index = index + 1;
                    symbol(index) = zz_idx(i);
                    magnitude(index) = 0;
                end
            else
                index = index + 1;
                symbol(index) = zz_idx(i);
                magnitude(index) = 0;
            end
        end

        for i = 1:length(symbol)
            if symbol(i) == 0 
                if i == length(symbol)
                    codeTemp = EOB;
                else
                    codeTemp = [0 magnitude(i)];
                end
            else
                codeTemp = symbol(i);
            end
            if length(codeTemp) == 2
                zze(counter:counter+1) = codeTemp;
                counter = counter + 2;
            else
                zze(counter) = codeTemp;
                counter = counter + 1;
            end
        end
    end
    
   
end

function yuv = ictRGB2YCbCr(rgb)
    yuv(:,:,1) = 0.299*rgb(:,:,1) + 0.587*rgb(:,:,2) + 0.114*rgb(:,:,3);
    yuv(:,:,2) = -0.169*rgb(:,:,1) - 0.331*rgb(:,:,2) + 0.5*rgb(:,:,3);
    yuv(:,:,3) = 0.5*rgb(:,:,1) - 0.419*rgb(:,:,2) - 0.081*rgb(:,:,3);
end

function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end

function rgb = ictYCbCr2RGB(yuv)
    rgb(:,:,1) = yuv(:,:,1) + 1.402*yuv(:,:,3);
    rgb(:,:,2) = yuv(:,:,1) - 0.344*yuv(:,:,2) - 0.714*yuv(:,:,3);
    rgb(:,:,3) = yuv(:,:,1) + 1.772*yuv(:,:,2);
end
    
function PSNR = calcPSNR(Image, recImage)
mse = calcMSE(Image, recImage);
PSNR = 20*log10(255/sqrt(mse));
end

function MSE = calcMSE(Image, recImage)
[height, width, cdim] = size(Image);
MSE = sum(sum((double(Image) - double(recImage)).^2))/(height*width*cdim);
MSE = sum(MSE(:));
end

function coeff = DCT8x8(block)
%  Input         : block    (Original Image block, 8x8x3)
%
%  Output        : coeff    (DCT coefficients after transformation, 8x8x3)
%     coeff = zeros(size(block));
%     for depth = 1:size(block, 3)
%         coeff(:, :, depth) = dct(dct(block(:, :, depth)).').';
%     end
    coeff = permute(dct(permute(dct(block),[2 1 3])), [2, 1, 3]);
end

function dct_block = DeQuant8x8(quant_block, qScale)
%  Function Name : DeQuant8x8.m
%  Input         : quant_block  (Quantized Block, 8x8x3)
%                  qScale       (Quantization Parameter, scalar)
%
%  Output        : dct_block    (Dequantized DCT coefficients, 8x8x3)
    L = qScale*[16, 11, 10, 16, 24, 40, 51, 61;
                12, 12, 14, 19, 26, 58, 60, 55;
                14, 13, 16, 24, 40, 57, 69, 56;
                14, 17, 22, 29, 51, 87, 80, 62;
                18, 55, 37, 56, 68, 109, 103, 77;
                24, 35, 55, 64, 81, 104, 113, 92;
                49, 64, 78, 87, 103, 121, 120, 101;
                72, 92, 95, 98, 112, 100, 103, 99];
    
    C =  qScale*[17, 18, 24, 47, 99, 99, 99, 99;
                 18, 21, 26, 66, 99, 99, 99, 99;
                 24, 13, 56, 99, 99, 99, 99, 99;
                 47, 66, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99; ];

    dct_block = zeros(size(quant_block));
    for depth = 1:size(quant_block, 3)
        if depth == 1
            quantMat = L;
        else
            quantMat = C;
        end
        dct_block(:, :, depth) =  quant_block(:, :, depth).*quantMat;
    end
end


function coeffs = DeZigZag8x8(zz)
%  Function Name : DeZigZag8x8.m
%  Input         : zz    (Coefficients in zig-zag order)
%
%  Output        : coeffs(DCT coefficients in original order)
    ZigZag8x8_Mat = [1     2    6    7    15   16   28   29;
                     3     5    8    14   17   27   30   43;
                     4     9    13   18   26   31   42   44;
                     10    12   19   25   32   41   45   54;
                     11    20   24   33   40   46   53   55;
                     21    23   34   39   47   52   56   61;
                     22    35   38   48   51   57   60   62;
                     36    37   49   50   58   59   63   64];
    
    coeffs = zeros([sqrt(size(zz, 1)), sqrt(size(zz, 1)), size(zz, 2)]);
    for depth = 1:size(zz, 2)
        zzVec = zz(:, depth);
        coeffs(:, :, depth) = reshape(zzVec(ZigZag8x8_Mat(:)), sqrt(size(zz, 1)), sqrt(size(zz, 1)));
    end
end


function block = IDCT8x8(coeff)
%  Function Name : IDCT8x8.m
%  Input         : coeff (DCT Coefficients) 8*8*3
%  Output        : block (original image block) 8*8*3
%     block = zeros(size(coeff));
%     for depth = 1:size(coeff, 3)
%         block(:, :, depth) = idct(idct(coeff(:, :, depth)).').';
%     end
    block = permute(idct(permute(idct(coeff),[2 1 3])), [2, 1, 3]);
end


function quant = Quant8x8(dct_block, qScale)
%  Input         : dct_block (Original Coefficients, 8x8x3)
%                  qScale (Quantization Parameter, scalar)
%
%  Output        : quant (Quantized Coefficients, 8x8x3)

    L = qScale*[16, 11, 10, 16, 24, 40, 51, 61;
                12, 12, 14, 19, 26, 58, 60, 55;
                14, 13, 16, 24, 40, 57, 69, 56;
                14, 17, 22, 29, 51, 87, 80, 62;
                18, 55, 37, 56, 68, 109, 103, 77;
                24, 35, 55, 64, 81, 104, 113, 92;
                49, 64, 78, 87, 103, 121, 120, 101;
                72, 92, 95, 98, 112, 100, 103, 99];
    
    C =  qScale*[17, 18, 24, 47, 99, 99, 99, 99;
                 18, 21, 26, 66, 99, 99, 99, 99;
                 24, 13, 56, 99, 99, 99, 99, 99;
                 47, 66, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99;
                 99, 99, 99, 99, 99, 99, 99, 99; ];

    quant = zeros(size(dct_block));
    for depth = 1:size(dct_block, 3)
        if depth == 1
            quantMat = L;
        else
            quantMat = C;
        end
        quant(:, :, depth) =  round(dct_block(:, :, depth)./quantMat);
    end
end

function zz = ZigZag8x8(quant)
%  Input         : quant (Quantized Coefficients, 8x8x3)
%
%  Output        : zz (zig-zag scaned Coefficients, 64x3)
    ZigZag8x8_Mat = [1     2    6    7    15   16   28   29;
                     3     5    8    14   17   27   30   43;
                     4     9    13   18   26   31   42   44;
                     10    12   19   25   32   41   45   54;
                     11    20   24   33   40   46   53   55;
                     21    23   34   39   47   52   56   61;
                     22    35   38   48   51   57   60   62;
                     36    37   49   50   58   59   63   64];
    zz = zeros([size(quant, 1)*size(quant, 2), size(quant, 3)]);
    for depth = 1:size(quant, 3)
        quantImg = quant(:, :, depth);
        zz(ZigZag8x8_Mat(:), depth) = quantImg(:);
    end
    
end

function dst = ZeroRunDec_EoB(src, EoB)
%  Function Name : ZeroRunDec1.m zero run level decoder
%  Input         : src (zero run encoded sequence 1xM with EoB signs)
%                  EoB (end of block sign)
%
%  Output        : dst (reconstructed zig-zag scanned sequence 1xN)

%%
EOB_idx = find(src == EoB);
if isempty(EOB_idx)
    EOB_idx = length(src);
end

dst = [];
for idx = 1:length(EOB_idx)
    if idx == 1
        src_64 = src(1:EOB_idx(idx));
    else
        src_64 = src(EOB_idx(idx-1)+1:EOB_idx(idx));
    end
    dst_64 = ZeroRunDec8x8_EoB(src_64, EoB);
    dst(1, end+1:end+size(dst_64, 2)) = dst_64;
end
end


function dst_64 = ZeroRunDec8x8_EoB(src_64, EoB)
%%
    index = 1;
%     dst_64 = zeros(1, 64);
    dst_64 = [];
    for i = 1:length(src_64)
        if eq(src_64(i),EoB)
%             %% Comment out for faster version but expect possibility to have a bug
            if size(src_64, 2) == 1
                dst_64 = zeros(1, 64);
            else
                mult = ceil(size(dst_64, 2)/64);
                dst_64(1, end+1:end+mult*64-size(dst_64(1:end-1), 2)-1) = zeros(1, mult*64-size(dst_64(1:end), 2));
            end
            %%
            break;
        end
        if eq(src_64(i),0) 
            if i == 1 || (i > 1 && ~eq(src_64(i-1),0))
                count = src_64(i+1)+1;
                dst_64(1, index:(index+count-1)) = zeros(count,1);
                index = index + count;
            end
        else
            if (i-1) < 1 || ~eq(src_64(i-1),0)
                dst_64(1, index) = src_64(i);
                index = index + 1;
            else
                if i > 2 && and(eq(src_64(i-1),0), eq(src_64(i-2),0))
                    dst_64(1, index) = src_64(i);
                    index = index + 1;
                end
            end
        end
    end
   
end

function motion_vectors_indices = SSD(ref_image, image)
%  Input         : ref_image(Reference Image, size: height x width)
%                  image (Current Image, size: height x width)
%
%  Output        : motion_vectors_indices (Motion Vector Indices, size: (height/8) x (width/8) x 1 )

ref_image = padarray(ref_image, [4, 4], 'both', 'replicate');
motion_vectors_indices = blockproc(image, [8, 8], @(block_struct) BlockSSD(block_struct.data, block_struct.location, ref_image));

end

function motion_vector_indices = BlockSSD(block, loc, ref_image)

loc = loc + size(block)/2;
sse_min = inf;
best_loc = loc;
for x = -size(block, 1)/2:size(block, 1)/2
    for y = -size(block, 2)/2:size(block, 2)/2
        sse = sum(sum( (block-ref_image(loc(1)+x:loc(1)+x+size(block, 1)-1, loc(2)+y:loc(2)+y+size(block, 2)-1)).^2 ));
        if sse_min > sse
            best_loc(1) = x+5;
            best_loc(2) = y+5;
            sse_min = sse;
        end
    end
end
motion_vector_indices = sub2ind(size(block)+1, best_loc(2), best_loc(1));
end

function rec_image = SSD_rec(ref_image, motion_vectors)
%  Input         : ref_image(Reference Image, YCbCr image)
%                  motion_vectors
%
%  Output        : rec_image (Reconstructed current image, YCbCr image)


    rec_image = zeros(size(ref_image));
    ref_image = padarray(ref_image, [4, 4], 'both', 'replicate');
    
    for x = 1:size(motion_vectors, 1)
        for y = 1:size(motion_vectors, 2)
            [mvY, mvX] = ind2sub(8+1, motion_vectors(x, y));
            
            ref_XStart = (x-1)*8+mvX;
            ref_XEnd = x*8+mvX-1;
            ref_YStart = (y-1)*8+mvY;
            ref_YEnd = y*8+mvY-1;
            
                        
            rec_image(ref_XStart-mvX+1:ref_XEnd-mvX+1, ref_YStart-mvY+1:ref_YEnd-mvY+1, :) = ...
                ref_image(ref_XStart:ref_XEnd, ref_YStart:ref_YEnd, :);
        end 
    end
 
end

function dst = ZeroRunDec(src)
    % place your function code here
    index = 1;
    for i = 1:1:length(src)
        if eq(src(i),0)
            count = src(i+1);
            dst(index:(index+count-1),1) = zeros(count,1);
            index = index + count;
        elseif (i-1) < 1 || ~eq(src(i-1),0)
            dst(index,1) = src(i);
            index = index + 1;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Huffman %%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------
%
%
%
%           %%%    %%%       %%%      %%%%%%%%
%           %%%    %%%      %%%     %%%%%%%%%            
%           %%%    %%%     %%%    %%%%
%           %%%    %%%    %%%    %%%
%           %%%    %%%   %%%    %%%
%           %%%    %%%  %%%    %%%
%           %%%    %%% %%%    %%%
%           %%%    %%%%%%    %%%
%           %%%    %%%%%     %%% 
%           %%%    %%%%       %%%%%%%%%%%%
%           %%%    %%%          %%%%%%%%%   BUILDHUFFMAN.M
%
%
% description:  creatre a huffman table from a given distribution
%
% input:        PMF               - probabilty mass function of the source
%
% returnvalue:  BinaryTree        - cell structure containing the huffman tree
%               HuffCode          - Array of integers containing the huffman tree
%               BinCode           - Matrix containing the binary version of the code
%               Codelengths       - Array with number of bits in each Codeword
%
% Course:       Image and Video Compression
%               Prof. Eckehard Steinbach
%
% Author:       Dipl.-Ing. Ingo Bauermann 
%               02.01.2003 (created)
%
%-----------------------------------------------------------------------------------


function [ BinaryTree, HuffCode, BinCode, Codelengths] = buildHuffman( p );

global y

p=p(:)/sum(p)+eps;              % normalize histogram
p1=p;                           % working copy

c=cell(length(p1),1);			% generate cell structure 

for i=1:length(p1)				% initialize structure
   c{i}=i;						
end

while size(c)-2					% build Huffman tree
	[p1,i]=sort(p1);			% Sort probabilities
	c=c(i);						% Reorder tree.
	c{2}={c{1},c{2}};           % merge branch 1 to 2
    c(1)=[];	                % omit 1
	p1(2)=p1(1)+p1(2);          % merge Probabilities 1 and 2 
    p1(1)=[];	                % remove 1
end

%cell(length(p),1);              % generate cell structure
getcodes(c,[]);                  % recurse to find codes
code=char(y);

[numCodes maxlength] = size(code); % get maximum codeword length

% generate byte coded huffman table
% code

length_b=0;
HuffCode=zeros(1,numCodes);
for symbol=1:numCodes
    for bit=1:maxlength
        length_b=bit;
        if(code(symbol,bit)==char(49)) HuffCode(symbol) = HuffCode(symbol)+2^(bit-1)*(double(code(symbol,bit))-48);
        elseif(code(symbol,bit)==char(48))
        else 
            length_b=bit-1;
            break;
        end;
    end;
    Codelengths(symbol)=length_b;
end;

BinaryTree = c;
BinCode = code;

clear global y;

return
end

%----------------------------------------------------------------
function getcodes(a,dum)       
global y                            % in every level: use the same y
if isa(a,'cell')                    % if there are more branches...go on
         getcodes(a{1},[dum 0]);    % 
         getcodes(a{2},[dum 1]);
else   
   y{a}=char(48+dum);   
end
end

%--------------------------------------------------------------
%
%
%
%           %%%    %%%       %%%      %%%%%%%%
%           %%%    %%%      %%%     %%%%%%%%%
%           %%%    %%%     %%%    %%%%
%           %%%    %%%    %%%    %%%
%           %%%    %%%   %%%    %%%
%           %%%    %%%  %%%    %%%
%           %%%    %%% %%%    %%%
%           %%%    %%%%%%    %%%
%           %%%    %%%%%     %%%
%           %%%    %%%%       %%%%%%%%%%%%
%           %%%    %%%          %%%%%%%%%   BUILDHUFFMAN.M
%
%
% description:  creatre a huffman table from a given distribution
%
% input:        data              - Data to be encoded (indices to codewords!!!!
%               BinCode           - Binary version of the Code created by buildHuffman
%               Codelengths       - Array of Codelengthes created by buildHuffman
%
% returnvalue:  bytestream        - the encoded bytestream
%
% Course:       Image and Video Compression
%               Prof. Eckehard Steinbach
%
%-----------------------------------------------------------------------------------

function [bytestream] = enc_huffman_new( data, BinCode, Codelengths)

a = BinCode(data(:),:)';
b = a(:);
mat = zeros(ceil(length(b)/8)*8,1);
p  = 1;
for i = 1:length(b)
    if b(i)~=' '
        mat(p,1) = b(i)-48;
        p = p+1;
    end
end
p = p-1;
mat = mat(1:ceil(p/8)*8);
d = reshape(mat,8,ceil(p/8))';
multi = [1 2 4 8 16 32 64 128];
bytestream = sum(d.*repmat(multi,size(d,1),1),2);

end

function [output] = dec_huffman_new (bytestream, BinaryTree, nr_symbols)

output = zeros(1,nr_symbols);
ctemp = BinaryTree;

dec = zeros(size(bytestream,1),8);
for i = 8:-1:1
    dec(:,i) = rem(bytestream,2);
    bytestream = floor(bytestream/2);
end

dec = dec(:,end:-1:1)';
a = dec(:);

i = 1;
p = 1;
while(i <= nr_symbols)&&p<=max(size(a))
    while(isa(ctemp,'cell'))
        next = a(p)+1;
        p = p+1;
        ctemp = ctemp{next};
    end;
    output(i) = ctemp;
    ctemp = BinaryTree;
    i=i+1;
end;
end

