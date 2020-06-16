function block = IDCT8x8(coeff)
%  Function Name : IDCT8x8.m
%  Input         : coeff (DCT Coefficients) 8*8*3
%  Output        : block (original image block) 8*8*3
%     block = zeros(size(coeff));
%     for depth = 1:size(coeff, 3)
%         block(:, :, depth) = idct(idct(coeff(:, :, depth)).').';
%     end
    block = permute(idct(permute(idct(coeff),[2 1 3])), [2, 1, 3]);
end