function [resImage, pmfRes, H_res] = predictiveCod(imageLenaSmall)
    yuvLena = ictRGB2YCbCr(imageLenaSmall);

    reconImage = zeros(size(yuvLena));
    resImage   = zeros(size(yuvLena));

    for yuv_dim = 1:3
        reconImage(1, :, yuv_dim) = yuvLena(1, :, yuv_dim);
        resImage(1, :, yuv_dim) = yuvLena(1, :, yuv_dim);
        reconImage(:, 1, yuv_dim) = yuvLena(:, 1, yuv_dim);
        resImage(:, 1, yuv_dim) = yuvLena(:, 1, yuv_dim);
    end

    alpha_Y = [-1/2; 7/8; 5/8; 0];
    alpha_CbCr = [-1/4; 3/8; 7/8; 0];

    for dim = 1:size(yuvLena, 3)
        if isequal(dim, 1)
            alpha = alpha_Y;
        else
            alpha = alpha_CbCr;
        end
        for x = 2:size(yuvLena, 1)
            for y = 2:size(yuvLena, 2)
                get_values = reshape(reconImage(x-1:x, y-1:y, dim), [], 1);
                pred = sum(alpha .* get_values);
                resImage(x, y, dim) = round(yuvLena(x, y, dim) - pred);
                reconImage(x, y, dim) = pred + resImage(x, y, dim);
            end
        end
    end
    % % get the PMF of the residual image
    pmfRes    = stats_marg(resImage, -255:255);
    % calculate the entropy of the residual image
    H_res     = calc_entropy(pmfRes); 
end
