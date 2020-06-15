image = double(imread('lena.tif'));
YCbCr = ictRGB2YCbCr(image);
L = magic(8);
C = magic(8);
qImage = zeros(size(YCbCr));
for depth = 1:size(qImage, 3)
    if depth == 1
        Quant = L;
    else
        Quant = C;
    end
    for x = 1:size(L, 1):size(qImage, 2)
        for y = 1:size(L, 2):size(qImage, 2)
            block = round(YCbCr(x:x+size(L, 1)-1, y:y+size(L, 2)-1, depth)./Quant);
            qImage(x:x+size(L, 1)-1, y:y+size(L, 2)-1, depth) = block;
        end
    end
end