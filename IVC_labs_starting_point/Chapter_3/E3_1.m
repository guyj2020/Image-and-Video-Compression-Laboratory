imageLena_small = double(imread('lena_small.tif'));
imageLena = double(imread('lena.tif'));

qImage = {};
qImage_small = {};
bits = 1 : 1 : 7;
for bit = bits
    qImage{end+1} = UniQuant(imageLena, bit);
    qImage_small{end+1} =  UniQuant(imageLena_small, bit);
end

recImage = {};
recImage_small = {};
for bit = bits
    recImage{end+1} = InvUniQuant(qImage{bit}, bit);
    recImage_small{end+1} = InvUniQuant(qImage_small{bit}, bit);
end

all_PSNR = [];
for i = 1:length(recImage) 
    PSNR = calcPSNR(imageLena, recImage{i});
    all_PSNR(end+1) = PSNR;
    fprintf("lena.tf - M/colorplane= %d  PSNR =  %.2f dB\n", [i, PSNR]);
end

all_PSNR_small = [];
for i = 1:length(recImage_small) 
    PSNR_small = calcPSNR(imageLena_small, recImage_small{i});
    all_PSNR_small(end+1) = PSNR_small;
    fprintf("lena_small.tf - M/colorplane= %d  PSNR = %.2f dB\n", [i, PSNR_small]);
end



figure;
subplot(1,2,1)
plot(bits, all_PSNR_small, 'rx')
y_PSNR_Small = interp1(bits, all_PSNR_small, 1:0.01:bits(end), 'spline');
hold on;
plot(1:0.01:bits(end), y_PSNR_Small, 'b')

title("E3.1-d: R-D Curve Lena Small")
xlabel("Rate [bit/pixel]")
ylabel("PSNR[dB]")


subplot(1,2,2)
plot(bits, all_PSNR, 'rx')
y_PSNR = interp1(bits, all_PSNR, 1:0.01:bits(end), 'spline');
hold on;
plot(1:0.01:bits(end), y_PSNR, 'b')

title("E3.1-d: R-D Curve Lena")
xlabel("Rate [bit/pixel]")
ylabel("PSNR[dB]")