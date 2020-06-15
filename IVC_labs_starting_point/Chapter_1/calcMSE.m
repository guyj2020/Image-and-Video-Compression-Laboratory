function MSE = calcMSE(Image, recImage)
% Input         : Image    (Original Image)
%                 recImage (Reconstructed Image)
% Output        : MSE      (Mean Squared Error)
Image = double(Image);
recImage = double(recImage);

dif_image = (Image-recImage).^2;
MSE = mean(dif_image(:));
end