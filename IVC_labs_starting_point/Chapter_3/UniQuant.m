function qImage = UniQuant(image, bits)
%  Input         : image (Original Image)
%                : bits (bits available for representatives)
%
%  Output        : qImage (Quantized Image)
%%
    imageDouble = double(image);
    indMax = 2^(bits);
    qImage = floor(imageDouble/256 *indMax);
end