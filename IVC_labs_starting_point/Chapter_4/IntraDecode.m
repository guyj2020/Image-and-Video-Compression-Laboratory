function dst = IntraDecode(image, img_size , qScale, EoB, zr_setter, ycbcr)
%  Function Name : IntraDecode.m
%  Input         : image (zero-run encoded image, 1xN)
%                  img_size (original image size)
%                  qScale(quantization scale)
%  Output        : dst   (decoded image)

if isequal(zr_setter, 1)
    enc_dec = reshape(ZeroRunDec(image), [img_size(1)*8, prod(img_size)/(img_size(1)*8)]);
else
    enc_dec = reshape(ZeroRunDec_EoB(image, EoB), [img_size(1)*8, prod(img_size)/(img_size(1)*8)]);
end
enc_zigzag = blockproc(enc_dec, [64, 1], @(block_struct) DeZigZag8x8(block_struct.data));

% reshape
enc_zigzag_reshaped = zeros(img_size);
int_im1 = [];
int_im2 = [];
int_im3 = [];
for j = 0:7
    int_im1 = [int_im1, (1:img_size(3)*8:prod(img_size)/img_size(1))+j];
    int_im2 = [int_im2, (9:img_size(3)*8:prod(img_size)/img_size(1))+j];
    int_im3 = [int_im3, (17:img_size(3)*8:prod(img_size)/img_size(1))+j];
end
enc_zigzag_reshaped(:, :, 1) = enc_zigzag(:, sort(int_im1));
enc_zigzag_reshaped(:, :, 2) = enc_zigzag(:, sort(int_im2));
enc_zigzag_reshaped(:, :, 3) = enc_zigzag(:, sort(int_im3));

rec_imageYCbCr_dequant = blockproc(enc_zigzag_reshaped, [8, 8], @(block_struct) DeQuant8x8(block_struct.data, qScale));
rec_imageYCbCr_Idct = blockproc(rec_imageYCbCr_dequant, [8, 8], @(block_struct) IDCT8x8(block_struct.data));
if ~ycbcr
    dst = ictYCbCr2RGB(rec_imageYCbCr_Idct);
else
    dst = rec_imageYCbCr_Idct;
end

end