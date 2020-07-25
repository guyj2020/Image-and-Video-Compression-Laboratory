function coeff = IInt4x4(block)
%  Function Name : IInt4x4.m
%  Input         : coeff (Integer DCT Coefficients) 4*4*3
%  Output        : block (original image block) 4*4*3
% https://www.vcodex.com/h264avc-4x4-transform-and-quantization/

    Hinv = [  1,   1,    1,    1;
           1, 0.5, -0.5,   -1;
           1,  -1,   -1,    1;
         0.5,  -1,    1, -0.5];
     
%     S = [1/4,  1/(sqrt(10)),  1/4,  1/(sqrt(10));
%          1/(sqrt(10)),  2/5, 1/(sqrt(10)), 2/5;
%          1/4, 1/(sqrt(10)), 1/4,  1/(sqrt(10));
%          1/(sqrt(10)), 2/5,  1/(sqrt(10)), 2/5];

%      coeff = H' * (block*S) * H;      
    coeff = zeros(size(block));
    for depth = 1:size(block, 3)
        coeff(:, :, depth) = (Hinv' * (block(:, :, depth)) * Hinv);
    end

end