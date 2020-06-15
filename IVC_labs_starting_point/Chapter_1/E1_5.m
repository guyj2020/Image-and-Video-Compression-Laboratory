imageLena = double(imread('lena.tif'));
I_YCbCr = ictRGB2YCbCr(imageLena);
rgb = ictYCbCr2RGB(I_YCbCr);
imshow(uint8(rgb))



function yuv = ictRGB2YCbCr(rgb)
% Input         : rgb (Original RGB Image)
% Output        : yuv (YCbCr image after transformation)
% YOUR CODE HERE
r = rgb(:,:,1);
g = rgb(:,:,2);
b = rgb(:,:,3);
yuv(:,:,1) = 0.299 * r + 0.587*g + 0.114*b;
yuv(:,:,2) = -0.169 * r -0.331* g + 0.5 *b;
yuv(:,:,3) = 0.5*r - 0.419*g -0.081*b;
end

function rgb = ictYCbCr2RGB(yuv)
% Input         : yuv (Original YCbCr image)
% Output        : rgb (RGB Image after transformation)
% YOUR CODE HERE
rgb(:,:,1) = yuv(:,:,1) + 1.402*yuv(:,:,3);
rgb(:,:,2) = yuv(:,:,1) - 0.344*yuv(:,:,2) - 0.714*yuv(:,:,3);
rgb(:,:,3) = yuv(:,:,1) + 1.772*yuv(:,:,2);
end