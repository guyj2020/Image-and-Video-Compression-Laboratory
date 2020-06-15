function pic_pre = prefilterlowpass2d(picture, kernel)
% YOUR CODE HERE
pic_pre = zeros(size(picture));
kernel = kernel/sum(kernel(:));
for i = 1:size(picture, 3)
    pic_pre(:, :, i) = conv2(picture(:, :, i), kernel, 'same');
end
end