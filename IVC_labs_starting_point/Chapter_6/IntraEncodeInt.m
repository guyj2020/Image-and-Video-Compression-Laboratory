function dst = IntraEncodeInt(image, qScale, EoB, zr_setter, ycbcr)
%  Function Name : IntraEncode.m
%  Input         : image (Original RGB Image)
%                  qScale(quantization scale)
%  Output        : dst   (sequences after zero-run encoding, 1xN)

    if ~ycbcr
        imageYCbCr = ictRGB2YCbCr(image);
    else
        imageYCbCr = image;
    end
    
%     imageYCbCr_dct = blockproc(imageYCbCr, [4, 4], @(block_struct) Int4x4(block_struct.data));
    imageYCbCr_dct = blockproc(imageYCbCr, [8, 8], @(block_struct) DCT8x8(block_struct.data));
     
    imageYCbCr_quant = blockproc(imageYCbCr_dct, [8, 8], @(block_struct) Quant8x8(block_struct.data, qScale));
    imageYCbCr_zigzag = blockproc(imageYCbCr_quant, [8, 8], @(block_struct) ZigZag8x8(block_struct.data));
    if isequal(zr_setter, 0)
        dst = ZeroRunEnc_EoB(imageYCbCr_zigzag, EoB);
    else
        dst = ZeroRunEnc(imageYCbCr_zigzag(:));
    end
end