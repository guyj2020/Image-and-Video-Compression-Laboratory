function coeff = IntTrafo4x4(block, QP)
%  Input         : block    (Original Image block, 4x4x3)
%
%  Output        : coeff    (Integer DCT coefficients after transformation, 4x4x3)
% https://www.vcodex.com/h264avc-4x4-transform-and-quantization/

    Cf = [1,  1,  1,  1;
         2,  1, -1, -2;
         1, -1, -1,  1;
         1, -2,  2, -1];
    
    % literally got baited into writing this in
    % Sf = [1/4,  1/(2*sqrt(10)),  1/4,  1/(2*sqrt(10));  
    %       1/(2*sqrt(10)),  1/10, 1/(2*sqrt(10)), 1/10;
    %       1/4, 1/(2*sqrt(10)), 1/4,  1/(2*sqrt(10));
    %       1/(2*sqrt(10)), 1/10,  1/(2*sqrt(10)), 1/10];
    
    m = [13107 5243 8066; ...
         11916 4660 7490; ...
         10082 4194 6554; ...
         9362  3647 5825; ...
         8192  3355 5243; ...
         7282  2893 4559];
    
    a = m(rem(QP, 6)+1, 1);
    b = m(rem(QP, 6)+1, 2);
    c = m(rem(QP, 6)+1, 3);
    
    Mf = [a c a c; ...
          c b c b; ...
          a c a c; ...
          c b c b];
              
    coeff = zeros(size(block));
    for depth = 1:size(block, 3)
%         coeff(:, :, depth) = (Cf * block(:, :, depth) * Cf') * Sf;
        coeff(:, :, depth) = round((Cf * block(:, :, depth) * Cf') .* Mf/(2^(floor(QP/6)+15))) ;
    end
end