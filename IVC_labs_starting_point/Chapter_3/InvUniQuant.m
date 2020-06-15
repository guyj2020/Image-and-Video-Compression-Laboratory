function image = InvUniQuant(qImage, bits)
%  Input         : qImage (Quantized Image)
%                : bits (bits available for representatives)
%
%  Output        : image (Mid-rise de-quantized Image)
    indMax = 2^(bits);
    image =  round((qImage+0.5) * 256/indMax);
end