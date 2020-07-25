function coeff = Int4x4(block)
%  Input         : block    (Original Image block, 4x4x3)
%
%  Output        : coeff    (Integer DCT coefficients after transformation, 4x4x3)
% https://www.vcodex.com/h264avc-4x4-transform-and-quantization/

    H = [1,  1,  1,  1;
         2,  1, -1, -2;
         1, -1, -1,  1;
         1, -2,  2, -1];
     
%     S = [1/4,  1/(2*sqrt(10)),  1/4,  1/(2*sqrt(10));
%          1/(2*sqrt(10)),  1/10, 1/(2*sqrt(10)), 1/10;
%          1/4, 1/(2*sqrt(10)), 1/4,  1/(2*sqrt(10));
%          1/(2*sqrt(10)), 1/10,  1/(2*sqrt(10)), 1/10];
%               
%     coeff = zeros(size(block));
    for depth = 1:size(block, 3)
        coeff(:, :, depth) = (H * block(:, :, depth) * H'); % * S;
    end
end