% Read Image
imageLena = double(imread('lena.tif'));
% Calculate Joint PMF
pmfLena  = stats_joint(imageLena);
% Calculate Joint Entropy
Hjoint    =  calc_entropy(pmfLena);
fprintf('H_joint = %.2f bit/pixel pair\n', Hjoint);

% Put all sub-functions which are called in your script here.
function pmf = stats_joint(image)

    tmp1 = reshape(image(:, :, 1).',1,[]);
    tmp2 = reshape(image(:, :, 2).',1,[]);
    tmp3 = reshape(image(:, :, 3).',1,[]);
    im = [tmp1'; tmp2'; tmp3'];
    im1 = im(1:2:end);
    im2 = im(2:2:end);
    pmf = zeros(256, 256);
    
    cc = [im1, im2];
    for i = 1:length(cc(:, 1))
        if or(~isequal(pmf(cc(i, 1)+1, cc(i, 2)+1), 0), eq(cc(i), 0))
            continue;
        else
            a = find(cc(:, 1) == cc(i, 1));
            b = find(cc(:, 2) == cc(i, 2));
            c = intersect(a, b);
            pmf(cc(i, 1)+1, cc(i, 2)+1) = length(c);
            cc(c) = 0;
        end
    end
    pmf = pmf./sum(pmf(:));
end

function H = calc_entropy(pmf)
%  Input         : pmf   (Probability Mass Function)
%
%  Output        : H     (Entropy in bits)
    pmf = pmf./sum(pmf(:));
    H = -sum(nonzeros(pmf(:)).*log2(nonzeros(pmf(:))));
%     H = -sum(nonzeros(norm_pmf(:)).*log2(nonzeros(norm_pmf(:))));
end


