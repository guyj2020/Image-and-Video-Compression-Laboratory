Image_lena = double(imread('lena_small.tif'));
PMF = hist(Image_lena(:), 0:255);
[FrequencyPMF, uniquePMF] = hist(PMF, unique(PMF));

