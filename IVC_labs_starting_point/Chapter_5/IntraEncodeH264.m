function [dst, modesPred] = IntraEncodeH264(image, QP, EoB)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, 1xN)

imageYCbCr_dct = zeros(size(image));
for depth = 1:size(image, 3)
    [imageYCbCr_dct(:, :, depth), modesPred(:, :, depth)] = Intra4x4Enc(image(:, :, depth), QP);
end

imageYCbCr_zigzag = blockproc(imageYCbCr_dct, [4, 4], @(block_struct) ZigZag4x4(block_struct.data));

dst = ZeroRunEnc(imageYCbCr_zigzag(:));

end