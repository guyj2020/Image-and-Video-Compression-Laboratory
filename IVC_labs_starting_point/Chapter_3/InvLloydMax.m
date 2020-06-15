function image = InvLloydMax(qImage, clusters)
%  Input         : qImage   (Quantized Image)
%                  clusters (Quantization Table)
%  Output        : image    (Recovered Image)
    image= zeros(size(qImage));
    for rep = 1:length(clusters)
        image(find(qImage == rep)) = clusters(rep);
    end
%     Q = @(x) clusters(x);
%     image = arrayfun(Q, qImage);
end