clear 
clc
close 

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

figure;
plot(final_rate, final_psnr, 'bx-')
xlabel("bpp");
ylabel('PSNR [dB]');

hold on;
plot(final_still_rate, final_still_psnr, 'rx-')
set(gca,'XTick', 0.0:0.5:6);