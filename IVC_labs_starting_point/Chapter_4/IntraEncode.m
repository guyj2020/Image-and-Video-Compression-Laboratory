function dst = IntraEncode(image, qScale)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, 1xN)

imageYCbCr = ictRGB2YCbCr(image);
imageYCbCr_dct = blockproc(imageYCbCr, [8, 8], @(block_struct) DCT8x8(block_struct.data));
imageYCbCr_quant = blockproc(imageYCbCr_dct, [8, 8], @(block_struct) Quant8x8(block_struct.data, qScale));
imageYCbCr_zigzag = blockproc(imageYCbCr_quant, [8, 8], @(block_struct) ZigZag8x8(block_struct.data));
dst = ZeroRunEnc_EoB(imageYCbCr_zigzag, 1000);
end