function [dst, modesPredY, modesPredCbCr] = IntraEncodeH264(image, QP, EoB)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, 1xN)

imageYCbCr_dct = zeros(size(image));
[imageYCbCr_dct(:, :, 1), modesPredY] = Intra4x4Enc(image(:, :, 1), QP);
[imageYCbCr_dct(:, :, 2), modesPredCbCr(:, :, 1)] = Intra8x8CbCrEnc(image(:, :, 2), QP);
[imageYCbCr_dct(:, :, 3), modesPredCbCr(:, :, 2)] = Intra8x8CbCrEnc(image(:, :, 3), QP);

imageYCbCr_zigzag = blockproc(imageYCbCr_dct, [4, 4], @(block_struct) ZigZag4x4(block_struct.data));

dst = ZeroRunEnc(imageYCbCr_zigzag(:));

end