function coeff = DCT8x8(block)
%  Input         : block    (Original Image block, 8x8x3)
%
%  Output        : coeff    (DCT coefficients after transformation, 8x8x3)
%     coeff = zeros(size(block));
%     for depth = 1:size(block, 3)
%         coeff(:, :, depth) = dct(dct(block(:, :, depth)).').';
%     end
    coeff = permute(dct(permute(dct(block),[2 1 3])), [2, 1, 3]);
end