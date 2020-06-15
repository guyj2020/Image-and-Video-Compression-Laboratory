imageLena = double(imread('lena.tif'));
H         = stats_cond(imageLena);
fprintf('H_cond = %.2f bit/pixel\n',H);

fprintf("The syntax of the code seems to be correct, next run the assessment to verify the correctness");


function H = stats_cond(image)
%  Input         : image (Original Image)
%
%  Output        : H   (Conditional Entropy)
    marg_pmf = stats_marg(image, 0:255);
    joint_pmf = stats_joint(image);
    H_tmp = zeros(size(joint_pmf, 1), 1);
    for i = 1:size(joint_pmf, 1)
        nnz_elemts = find(joint_pmf(i, :) ~= 0);
        if isempty(nnz_elemts)
            continue;
        end
        H_tmp(i) = sum(nonzeros(joint_pmf(i, :))' .* log2(nonzeros(joint_pmf(i, :))'./marg_pmf(nnz_elemts)));
    end
    H = -sum(H_tmp);
end

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

function pmf = stats_marg(image, range)
    PMF = hist(image(:), range);
    pmf = PMF/sum(PMF);
end
