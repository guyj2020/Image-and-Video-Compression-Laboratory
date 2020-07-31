clear
clc

scales = 1:4:40;
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

rate_cell = {};
psnr_cell = {};


for s = 1:numel(scales)
    QP = scales(s);
    for i = 1:length(frames)
        im = double(imread(fullfile(directory, frames(i).name)));
        im1 = ictRGB2YCbCr(im);
        [PSNR, BPP, ref_rgb_im] = h246IntraVidScript(im1, QP, EoB);
        still_im_rate(i) = BPP;
        still_im_psnr(i) = PSNR;
    end
    rate_cell{s} = still_im_rate;
    psnr_cell{s} = still_im_psnr;


    final_still_rate(s) = mean(still_im_rate);
    final_still_psnr(s) = mean(still_im_psnr);
end

hold on;
plot(final_still_rate, final_still_psnr, 'rx-')
% set(gca,'XTick', 0.0:0.5:6);
