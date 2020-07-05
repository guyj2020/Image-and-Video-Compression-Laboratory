clear
clc
close

% qScale = 0.07;
scales = 0.2;
% scales = [0.07, 0.2, 0.4, 0.8, 1.0, 1.5, 2, 3, 4, 4.5]; %    % Problem: 0.2 and i == 9
EoB = 4000;

directory = fullfile('../../sequences', 'foreman20_40_RGB');
path(path, directory)
frames = dir(fullfile(directory,'*.bmp'));

psnr = zeros(length(frames), 1);
rate = zeros(length(frames), 1);

final_rate = zeros(size(scales, 2), 1);
final_psnr = zeros(size(scales, 2), 1);

still_im_rate = zeros(size(scales, 2), 1);
still_im_psnr = zeros(size(scales, 2), 1);

for s = 1:numel(scales)
    qScale = scales(s);
    for i = 1:length(frames)
        im = double(imread(fullfile(directory, frames(i).name)));
        im1 = ictRGB2YCbCr(im);
        if i == 1     % Encode and decode the 1st frame

            [PSNR, BPP, ref_im_RGB, BinCodeImg, CodelengthsImg, BinaryTreeImg, k_small] = dctScript(im, qScale, EoB);
            psnr(i) = PSNR;
            rate(i) = BPP;
            still_im_rate(s) = BPP;
            still_im_psnr(s) = PSNR; %PSNR;
            ref_im = ictRGB2YCbCr(ref_im_RGB);
            continue;
        end
        mv_indices = SSD(ref_im(:,:,1), im1(:,:,1));
        rec_im= SSD_rec(ref_im, mv_indices);
        err_im = im1-rec_im;   
    
        [PSNR, BPP, dec_err_im, BinCode, Codelengths, BinaryTree] = dctVidScript(err_im, qScale, EoB, BinCodeImg, CodelengthsImg, BinaryTreeImg);
        
        bpp2 = (numel(bytestream2)*8) / (numel(im)/3);
        rate(i) = BPP + bpp2;

        ref_im = dec_err_im + rec_im;
        img_rec = ictYCbCr2RGB(ref_im);
        
        psnr(i) = PSNR;
    end

    final_rate(s) = mean(rate);
    final_psnr(s) = mean(psnr);
    fprintf('Final Results: \n');
    fprintf('QP: %.1f bit-rate: %.3f bits/pixel PSNR: %.2fdB\n', qScale, final_rate(s), final_psnr(s))
    
end


plot(final_rate, final_psnr, 'bx-')
xlabel("bpp");
ylabel('PSNR [dB]');

hold on;
plot(still_im_rate, still_im_psnr, 'rx-')
set(gca,'XTick', 0:0.5:6);
