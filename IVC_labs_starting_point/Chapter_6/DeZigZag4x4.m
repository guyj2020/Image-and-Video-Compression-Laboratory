function coeffs = DeZigZag4x4(zz)
%  Function Name : DeZigZag8x8.m
%  Input         : zz    (Coefficients in zig-zag order)
%
%  Output        : coeffs(DCT coefficients in original order)
    ZigZag8x8_Mat = [1     2    6    7   ;
                     3     5    8    13  ;
                     4     9    12   14  ;
                     10    11   15   16];
    
    coeffs = zeros([sqrt(size(zz, 1)), sqrt(size(zz, 1)), size(zz, 2)]);
    for depth = 1:size(zz, 2)
        zzVec = zz(:, depth);
        coeffs(:, :, depth) = reshape(zzVec(ZigZag8x8_Mat(:)), sqrt(size(zz, 1)), sqrt(size(zz, 1)));
    end
end