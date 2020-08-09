function dst = IntraDecodeH264(image, img_size, modesPredY, modesPredCbCr, QP, EoB)
%  Function Name : IntraDecode.m
%  Input         : image (zero-run encoded image, 1xN)
%                  img_size (original image size)
%                  qScale(quantization scale)
%  Output        : dst   (decoded image)

enc_dec = reshape(ZeroRunDec(image), [img_size(1)*8, prod(img_size)/(img_size(1)*8)]);
enc_dec_s0 = enc_dec(1:size(enc_dec, 1)/2, :);
enc_dec_s1 = enc_dec(size(enc_dec, 1)/2+1:end, :);
iv = 1:2:size(enc_dec, 2)*2;
enc_dec_reshaped = zeros(size(enc_dec, 1)/2, size(enc_dec, 2)*2);
enc_dec_reshaped(:, iv) =  enc_dec_s0;
enc_dec_reshaped(:, iv+1) =  enc_dec_s1;

% enc_dec_reshaped2 = zeros(size(enc_dec_reshaped));
% iv2 = 1:3:size(enc_dec_reshaped, 2);
% enc_dec_reshaped2(:, 1:length(iv2)) = enc_dec_reshaped(:, iv2);
% enc_dec_reshaped2(:, length(iv2)+1:length(iv2)*2) = enc_dec_reshaped(:, iv2+1);
% enc_dec_reshaped2(:, length(iv2)*2+1:end) = enc_dec_reshaped(:, iv2+2);


% enc_zigzag = blockproc(enc_dec, [16, 1], @(block_struct) DeZigZag4x4(block_struct.data));%
enc_zigzag = blockproc(enc_dec_reshaped, [16, 1], @(block_struct) DeZigZag4x4(block_struct.data));
% enc_zigzag = reshape(enc_zigzag, [img_size(1), img_size(2)*img_size(3)]);
% enc_zigzag = [enc_zigzag(1:img_size(1), :), enc_zigzag(img_size(1)+1:end, :)];
% reshape
enc_zigzag_reshaped = zeros(img_size);
int_im1 = [];
int_im2 = [];
int_im3 = [];
for j = 0:3
    int_im1 = [int_im1, (1:img_size(3)*4:prod(img_size)/img_size(1))+j];  % sicher nicht img_size(2)?
    int_im2 = [int_im2, (5:img_size(3)*4:prod(img_size)/img_size(1))+j];
    int_im3 = [int_im3, (9:img_size(3)*4:prod(img_size)/img_size(1))+j];
end
enc_zigzag_reshaped(:, :, 1) = enc_zigzag(:, sort(int_im1));
enc_zigzag_reshaped(:, :, 2) = enc_zigzag(:, sort(int_im2));
enc_zigzag_reshaped(:, :, 3) = enc_zigzag(:, sort(int_im3));


dst = zeros(size(enc_zigzag_reshaped));
dst(:, :, 1) = Intra4x4Dec(enc_zigzag_reshaped(:, :, 1), QP, modesPredY);
dst(:, :, 2) = Intra8x8CbCrDec(enc_zigzag_reshaped(:, :, 2), QP, modesPredCbCr(:, :, 1));
dst(:, :, 3) = Intra8x8CbCrDec(enc_zigzag_reshaped(:, :, 3), QP, modesPredCbCr(:, :, 2));


end