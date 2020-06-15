% %%
% image = double(imread('lena_small.tif'));
% bits         = 8;
% epsilon      = 0.1;
% bsize   = 2;

%%

function [clusters, Temp_clusters] = VectorQuantizer(image, bits, epsilon, bsize)
    %% Lloyd Max
    M = 2^(bits);
    uniform_t_q = linspace(0, 1, M+1) * 256;
    uniform_x_q = uniform_t_q(1:end-1) + (uniform_t_q(2:end)-uniform_t_q(1:end-1))/2;

    clusters = [repmat(uniform_x_q', [1, 4]), zeros(length(uniform_x_q), 5)];
    dist = [1; zeros(length(uniform_x_q)-1, 1)];
    
    % Create Blocks of size bsizexbsize -> vec those blocks
    image1D = [image(:, :, 1), image(:, :, 2), image(:, :, 3)]; 
    N1 = bsize*ones(1,size(image1D, 1)/bsize);
    N2 = bsize*ones(1,size(image1D, 2)/bsize);

    cellImage1D = mat2cell(image1D, N1, N2);
    vecFCN = @(blk) blk(:);
    matImage1DVec = cell2mat(cellfun(vecFCN, cellImage1D, 'UniformOutput', false));
    vecImg = reshape(matImage1DVec(:), [4, numel(image1D)/4])';
    %%
    
    while true
        old_dist = dist;
        [I, D]   = knnsearch(clusters(:, 1:4), vecImg, 'Distance', 'euclidean');
        
        for rep = 1:size(clusters, 1)
            clusters(rep, 9) = length(find(I==rep));
            if clusters(rep, 9) > 0
                clusters(rep, 5:8) = sum(vecImg(find(I==rep), :));
                clusters(rep, 1:4) = 1./clusters(rep, 9) .* clusters(rep, 5:8);
            end
            dist(rep) = sum(D(find(I==rep)).^2)/length(D);
        end
        %% Cell Spliting
        zeroClusters = find(clusters(:, 9) == 0);
        for idx = 1:length(zeroClusters)
            idxBiggestCluster = find(clusters(:, 9) == max(clusters(:, 9)));
            clusters(zeroClusters(idx), :) = clusters(idxBiggestCluster(1), :);
            clusters(zeroClusters(idx), 4) = clusters(zeroClusters(idx), 4) +1;
            clusters(zeroClusters(idx), 9) = floor(max(clusters(:, 9))/2);
            clusters(idxBiggestCluster(1), 9) = ceil(clusters(idxBiggestCluster(1), 9)/2);
        end
        
        %%
        if abs(sum(dist) - sum(old_dist))/sum(old_dist) < epsilon 
            break;
        else
            clusters(:, 5:8) = zeros(length(uniform_x_q), 4);
            clusters(:, 9) = zeros(length(uniform_x_q), 1);
        end

    end
    clusters(:, 5:end) = [];
    Temp_clusters = 0;

end

