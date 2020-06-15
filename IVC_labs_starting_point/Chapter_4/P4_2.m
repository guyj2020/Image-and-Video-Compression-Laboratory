image = double(imread('lena.tif'));
YCbCr = ictRGB2YCbCr(image);
qImage = zeros(size(YCbCr));
bsize = 8;
for depth = 1:size(qImage, 3)
    if depth == 1
        Quant = L;
    else
        Quant = C;
    end
    for x = 1:bsize:size(qImage, 2)
        for y = 1:bsize:size(qImage, 2)
            block = round(YCbCr(x:x+bsize-1, y:y+bsize-1, depth)./Quant);
            qImage(x:x+bsize-1, y:y+bsize-1, depth) = block;
        end
    end
end


ZigZag8x8 = [1     2    6    7    15   16   28   29;
             3     5    8    14   17   27   30   43;
             4     9    13   18   26   31   42   44;
             10    12   19   25   32   41   45   54;
             11    20   24   33   40   46   53   55;
             21    23   34   39   47   52   56   61;
             22    35   38   48   51   57   60   62;
             36    37   49   50   58   59   63   64];
         
Input_8x8 = image(1:8, 1:8, 1);   
Output_1x64(ZigZag8x8(:)) = Input_8x8(:);
% deZigZag2x8 = Output_1x64(ZigZag8x8(:));
% deZigZag2x8 = reshape(deZigZag2x8, 8, 8);