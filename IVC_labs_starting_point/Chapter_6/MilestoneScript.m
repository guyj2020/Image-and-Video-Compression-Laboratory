clear
clc

scales = 1;%:4:40;
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
    QP = scales(s);
    for i = 1:length(frames)
        i
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Reverse this chagne
        im = double(imread(fullfile(directory, frames(i).name)));
        im1 = ictRGB2YCbCr(im);
        [PSNR, BPP, ref_rgb_im] = h246IntraVidScript(im1, QP, EoB);
        still_im_rate(i) = BPP;
        still_im_psnr(i) = PSNR;
            
        if i == 1     % Encode and decode the 1st frame
            psnr(i) = PSNR;
            rate(i) = BPP;
            ref_im = ictRGB2YCbCr(ref_rgb_im);            
            continue;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % For Luma Part % 0 for 16x16; 1 for 8x8; 3 for 16x8 and 2 for 8x16
        [MV_choice, mv_indices8x16, mv_indices16x8, mv_indices16x16, mv_indices8x8] = SSD_h264(ref_im(:, :, 1), im1(:, :, 1));
        mv_indices = cut_motion_vect_mat(MV_choice, mv_indices16x16, mv_indices8x8, mv_indices8x16, mv_indices16x8);

        rec_im = SSDRec_h264(ref_im, MV_choice, mv_indices16x16, mv_indices);
        % TODO: ONLY MV_INDICES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        err_im = im1-rec_im;

        %%%%%%%%%%%%%%%%%%%%
        
        [zeroRun, modesPredY, modesPredCbCr]= IntraEncodeH264(err_im, QP, EoB);
        
%         if isequal(i, 2) 
        pmfMVChoice = stats_marg(MV_choice, min(MV_choice(:)):max(MV_choice(:)));
        [BinaryTreeMV, ~, BinCodeMV, CodelengthsMV] = buildHuffman(pmfMVChoice);

        pmfMV= stats_marg(mv_indices, min(mv_indices(:)):max(mv_indices(:)));
        [BinaryTreeMVInd, ~, BinCodeMVInd, CodelengthsMVInd] = buildHuffman(pmfMV);
%         end

        pmfZR = stats_marg(zeroRun, min(zeroRun(:)):max(zeroRun(:)));
        [BinaryTreeZR, ~, BinCodeZR, CodelengthsZR] = buildHuffman(pmfZR);
        
        pmfmodesPredY = stats_marg(modesPredY, min(modesPredY(:)):max(modesPredY(:)));
        [BinaryTreemodesPredY, ~, BinCodemodesPredY, CodelengthsmodesPredY] = buildHuffman(pmfmodesPredY);

        pmfmodesPredCbCr = stats_marg(modesPredCbCr, min(modesPredCbCr(:)):max(modesPredCbCr(:)));
        [BinaryTreemodesPredCbCr, ~, BinCodemodesPredCbCr, CodelengthsmodesPredCbCr] = buildHuffman(pmfmodesPredCbCr);


        off_setZR = -min(zeroRun(:))+1;
        off_setMV = -min(MV_choice(:))+1;
        off_setMVInd= -min(mv_indices(:))+1;
        
        off_setModePredY = -min(modesPredY(:))+1;
        off_setModePredCbCr= -min(modesPredCbCr(:))+1;
        
        bytestream1 = enc_huffman_new(zeroRun+off_setZR, BinCodeZR, CodelengthsZR);
        bytestream2 = enc_huffman_new(MV_choice+off_setMV, BinCodeMV, CodelengthsMV);
        bytestream3 = enc_huffman_new(mv_indices+off_setMVInd, BinCodeMVInd, CodelengthsMVInd);

        bytestream4 = enc_huffman_new(modesPredY+off_setModePredY, BinCodemodesPredY, CodelengthsmodesPredY);
        bytestream5 = enc_huffman_new(modesPredCbCr+off_setModePredCbCr, BinCodemodesPredCbCr, CodelengthsmodesPredCbCr);

        dec_bytestream1 = double(reshape(dec_huffman_new(bytestream1, BinaryTreeZR, max(size(zeroRun(:)))), size(zeroRun)))-off_setZR;
        dec_bytestream2 = double(reshape(dec_huffman_new(bytestream2, BinaryTreeMV, max(size(MV_choice(:)))), size(MV_choice)))-off_setMV;
        dec_bytestream3 = double(reshape(dec_huffman_new(bytestream3, BinaryTreeMVInd, max(size(mv_indices(:)))), size(mv_indices)))-off_setMVInd;

        dec_bytestream4 = double(reshape(dec_huffman_new(bytestream4, BinaryTreemodesPredY, max(size(modesPredY(:)))), size(modesPredY)))-off_setModePredY;
        dec_bytestream5 = double(reshape(dec_huffman_new(bytestream5, BinaryTreemodesPredCbCr, max(size(modesPredCbCr(:)))), size(modesPredCbCr)))-off_setModePredCbCr;

        bpp1 = (numel(bytestream1)*8) / (numel(im)/3);
        bpp2 = (numel(bytestream2)*8) / (numel(im)/3);        
        bpp3 = (numel(bytestream3)*8) / (numel(im)/3);

        bpp4 = (numel(dec_bytestream4)*8) / (numel(im)/3);
        bpp5 = (numel(dec_bytestream5)*8) / (numel(im)/3);

        dec_err_im = IntraDecodeH264(dec_bytestream1, size(err_im), dec_bytestream4, dec_bytestream5, QP, EoB);
        dec_rec_im = SSDRec_h264(ref_im, dec_bytestream2, mv_indices16x16, dec_bytestream3);
        
        ref_im = dec_err_im + dec_rec_im;
        img_rec = ictYCbCr2RGB(ref_im);

        rate(i) = bpp1 + bpp2 + bpp3 + bpp4 + bpp5;
        psnr(i) = calcPSNR(im, img_rec);

    end

    final_still_rate(s) = mean(still_im_rate);
    final_still_psnr(s) = mean(still_im_psnr);
    
    final_rate(s) = mean(rate);
    final_psnr(s) = mean(psnr);
    fprintf('Final Results: \n');
    fprintf('QP: %.1f bit-rate: %.3f bits/pixel PSNR: %.2fdB\n', QP, final_rate(s), final_psnr(s))

end

figure;
hold on
plot(final_rate, final_psnr, 'bx-')
xlabel("bpp");
ylabel('PSNR [dB]');


plot(final_still_rate, final_still_psnr, 'rx-')
% set(gca,'XTick', 0.0:0.5:6);

legend("Inter Mode", "Intra Mode")
