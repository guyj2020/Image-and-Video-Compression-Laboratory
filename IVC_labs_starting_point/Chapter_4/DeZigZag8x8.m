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