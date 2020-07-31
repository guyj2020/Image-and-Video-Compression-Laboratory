function zz = ZigZag4x4(quant)
%  Input         : quant (Quantized Coefficients, 4x4x3)
%
%  Output        : zz (zig-zag scaned Coefficients, 16x3)
    ZigZag4x4_Mat = [1     2    6    7  ;
                     3     5    8    13 ;
                     4     9    12   14 ;
                     10    11   15   16 ];
    zz = zeros([size(quant, 1)*size(quant, 2), size(quant, 3)]);
    for depth = 1:size(quant, 3)
        quantImg = quant(:, :, depth);
        zz(ZigZag4x4_Mat(:), depth) = quantImg(:);
    end
    
end
