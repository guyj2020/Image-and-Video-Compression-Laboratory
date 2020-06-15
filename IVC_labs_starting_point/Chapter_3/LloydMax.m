function [qImage, clusters] = LloydMax(image, bits, epsilon)
%  Input         : image (Original RGB Image)
%                  bits (bits for quantization)
%                  epsilon (Stop Condition)
%  Output        : qImage (Quantized Image)
%                  clusters (Quantization Table)
    M = 2^(bits);
    uniform_t_q = linspace(0, 1, M+1) * 256;
    uniform_x_q = uniform_t_q(1:end-1) + (uniform_t_q(2:end)-uniform_t_q(1:end-1))/2;

    clusters = [uniform_x_q', zeros(length(uniform_x_q), 2)];
    dist = [1; zeros(length(uniform_x_q)-1, 1)];
    a = [1; zeros(length(uniform_x_q)-1, 1)];

    imageVec = image(:);

    while true
        old_dist = dist;
        [D, I] = pdist2(clusters(:, 1), imageVec, 'euclidean', 'Smallest', 1);  
        for rep = 1:size(clusters, 1)
            clusters(rep, 2) = sum(imageVec(find(I==rep)));
            clusters(rep, 3) = length(find(I==rep));
            
            dist(rep) = sum(D(find(I==rep)).^2);
        end

        if abs(sum(dist) - sum(old_dist))/sum(old_dist) < epsilon 
            break;
        else
            clusters(:, 1) = 1./clusters(:, 3) .* clusters(:, 2);
            clusters(:, 2) = zeros(length(uniform_x_q), 1);
            clusters(:, 3) = zeros(length(uniform_x_q), 1);
            
        end

    end
    qImage = reshape(I, size(image));
    clusters(:, 2:3) = [];
end