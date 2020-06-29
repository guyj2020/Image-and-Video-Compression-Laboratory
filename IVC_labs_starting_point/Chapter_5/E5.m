clear
clc
close

qScale = 1;

directory = fullfile('sequences', 'foreman20_40_RGB');
path(path, directory)
frames = dir(fullfile(directory,'*.bmp'));

psnr = zeros(length(frames));
rate = zeros(length(frames));

for i = 1:length(frames)
    im = double(imread(fullfile(directory, frames(i).name)));
    if i == 1     % Encode and decode the 1st frame
        [PSNR, BPP, img_rec, ~, ~, ~, k_small_min] = dctScript(im, qScale);
        fprintf('First Frame: \n');
        fprintf('QP: %.1f bit-rate: %.2f bits/pixel PSNR: %.2fdB\n', qScale, BPP, PSNR)
        psnr(i) = PSNR;
        rate(i) = BPP;
        continue;
    end
    ref_im = ictRGB2YCbCr(img_rec); %in YCbCr form
    im1 = ictRGB2YCbCr(im);
    mv_indices = SSD(ref_im(:,:,1), im1(:,:,1));
    rec_im = SSD_rec(ref_im, mv_indices);
    err_im = rec_im - ref_im;
    zeroRun= IntraEncode(err_im, qScale);
    
    pmfMV = stats_marg(mv_indices, min(mv_indices(:)):max(mv_indices(:)));
    [BinaryTreeMV, ~, BinCodeMV, CodelengthsMV] = buildHuffman(pmfMV);

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
     
    dec_err_im = IntraDecode(zeroRun, size(err_im), qScale);
    decoded_frame = dec_err_im + rec_im;
    img_rec = ictYCbCr2RGB(decoded_frame);

    rate(i) = bpp1 + bpp2;
    psnr(i) = calcPSNR(im, img_rec);
    
    if i == 2
        fprintf('2nd Frame: \n');
    else
        if i == 3
            fprintf('3rd Frame: \n');
        else
            fprintf('%ith Frame: \n', i);
        end
    end
    fprintf('QP: %.1f bit-rate: %.2f bits/pixel PSNR: %.2fdB\n', qScale, rate(i), psnr(i))

end

final_rate = mean(rate);
final_psnr = mean(psnr);
fprintf('Final Results: \n');
fprintf('QP: %.1f bit-rate: %.2f bits/pixel PSNR: %.2fdB\n', qScale, final_rate, final_psnr)

%% Result:
% 0.5663 30.8928
% 0.6619 32.38
% 0.8036 33.4920 dB
% 0.99 34.48 dB
% 1.22 35.4383 dB
% 2.6698 40
