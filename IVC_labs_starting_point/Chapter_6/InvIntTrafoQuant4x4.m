function coeff = InvIntTrafoQuant4x4(block, QP)
%  Function Name : IInt4x4.m
%  Input         : coeff (Integer DCT Coefficients) 4*4*3
%  Output        : block (original image block) 4*4*3
% https://www.vcodex.com/h264avc-4x4-transform-and-quantization/

    Ci = [  1,   1,    1,    1;
           1, 0.5, -0.5,   -1;
           1,  -1,   -1,    1;
         0.5,  -1,    1, -0.5];
     
    Si = [1/4,  1/(sqrt(10)),  1/4,  1/(sqrt(10));
         1/(sqrt(10)),  2/5, 1/(sqrt(10)), 2/5;
         1/4, 1/(sqrt(10)), 1/4,  1/(sqrt(10));
         1/(sqrt(10)), 2/5,  1/(sqrt(10)), 2/5];

    v = [10 16 13; ...
         11 18 14; ...
         13 20 16; ...
         14 23 18; ...
         16 25 20; ...
         18 29 23];
 
    a = v(rem(QP,6)+1,1);
    b = v(rem(QP,6)+1,2);
    c = v(rem(QP,6)+1,3);

    Vi = [a c a c; ...
          c b c b; ...
          a c a c; ...
          c b c b];
  
    coeff = zeros(size(block));
    for depth = 1:size(block, 3)
        coeff(:, :, depth) = round(Ci' * (block(:, :, depth) .* Vi) * 2^floor(QP/6) * 1/2^6 * Ci);

%         coeff(:, :, depth) = round(Ci' * (block(:, :, depth) .* Vi) * 2^floor(QP/6) * 1/2^6 * Ci);
    end

    
% %      coeff = H' * (block*S) * H;      
%     coeff = zeros(size(block));
%     for depth = 1:size(block, 3)
%         coeff(:, :, depth) = (Ci' * (block(:, :, depth) * Si) * Ci);
%     end

end